---
title: "Tidb 源码学习：关于 join 性能优化"
date: 2019-04-14T20:41:10+08:00
draft: false
---

最近在尝试自己写数据库查询模块，满足 http://sigmod18contest.db.in.tum.de/task.shtml 的功能要求。一边看着 TiDB 的代码，一边写… 这个过程中发现了一些 TiDB 优化点。

## join reorder

每个数据库系统基本都要实现 join reorder，修改表连接的顺序，从而提高 join 的性能，比如下面这个查询：

```sql
select a.id, b.id, c.id 
from a, b, c 
where a.id = b.a_id and a.id = c.a_id;
```

查询要连接 a/b/c 三张表，可以先连接 a 和 b，也可以先连接 a 和 c，当然如果你想不开的话，也可以先连接 a 和 c。如果 a join b 产生的数据比 a join c 产生的数据多，那么先计算 a join c 一般性能会更好。

很多数据库在表少的时候会使用动态规划来解决这个问题，比如 [这篇文章](https://github.com/pingcap/tidb/blob/master/docs/design/2018-10-20-join-reorder-dp-v1.md) 中介绍的算法。大致思路是根据表和用来连接的条件看做是一个无环图，表是节点，筛选条件是边。要计算最优的连接顺序，就是根据这张图计算出一个 sJoin Tree，Join Tree 除叶子节点以外其他的节点都是 Join。动规的过程是将图拆分成各种子图的组合并从中找出最优组合。

下面是 TiDB 中 join reorder 的主体代码：

```go
func (s *joinReorderDPSolver) solve(joinGroup []LogicalPlan, conds []expression.Expression) (LogicalPlan, error) {
	// joinGroup 可以简单认为是要连接的 table 列表，代码中先计算出图的邻接表的结构和“边”列表
	adjacents := make([][]int, len(joinGroup))
	totalEdges := make([]joinGroupEdge, 0, len(conds))
	addEdge := func(node1, node2 int, edgeContent *expression.ScalarFunction) {
		totalEdges = append(totalEdges, joinGroupEdge{
			nodeIDs: []int{node1, node2},
			edge:    edgeContent,
		})
		adjacents[node1] = append(adjacents[node1], node2)
		adjacents[node2] = append(adjacents[node2], node1)
	}
	// Build Graph for join group
	for _, cond := range conds { // 根据筛选条件的列，找到每个条件中连接的表，记录表之间的连接关系
		sf := cond.(*expression.ScalarFunction)
		lCol := sf.GetArgs()[0].(*expression.Column)
		rCol := sf.GetArgs()[1].(*expression.Column)
		lIdx, err := findNodeIndexInGroup(joinGroup, lCol) 
		//...
		rIdx, err := findNodeIndexInGroup(joinGroup, rCol)
    //...
		addEdge(lIdx, rIdx, sf)
	}
	visited := make([]bool, len(joinGroup))
	nodeID2VisitID := make([]int, len(joinGroup))
	var joins []LogicalPlan
	// BFS the tree.
	// 使用 BFS 计算出联通子图，如果存在多个子图，子图之间没有连接关系，子图之间 join 结果是他们的笛卡尔乘积
	for i := 0; i < len(joinGroup); i++ { 
		if visited[i] {
			continue
		}
		visitID2NodeID := s.bfsGraph(i, visited, adjacents, nodeID2VisitID)
		// Do DP on each sub graph.
		// 使用 DP 算法找到每个子图的最优 join 顺序
		join, err := s.dpGraph(visitID2NodeID, nodeID2VisitID, joinGroup, totalEdges)
		if err != nil {
			return nil, err
		}
		joins = append(joins, join)
	}
	// Build bushy tree for cartesian joins.
	return s.makeBushyJoin(joins), nil
}
```

下面是 bp 部分的代码，算法使用位图来表示不同的子图，使用了自下而上的方式，从小到大的计算每个子图的最优 join 顺序，从而最终计算出整个图的最优解。算法中使用了位图，拆分子图和判断子图之间是否连接的代码感觉很棒，非常的简洁高效。

```go
func (s *joinReorderDPSolver) dpGraph(newPos2OldPos, oldPos2NewPos []int, joinGroup []LogicalPlan, totalEdges []joinGroupEdge) (LogicalPlan, error) {
	// 使用位图来表示不同子图，使用自下而上的方式计算每个子图的最优 join 顺序
	nodeCnt := uint(len(newPos2OldPos))
	bestPlan := make([]LogicalPlan, 1<<nodeCnt)
	bestCost := make([]int64, 1<<nodeCnt)
	// bestPlan[s] is nil can be treated as bestCost[s] = +inf.
	for i := uint(0); i < nodeCnt; i++ {
		bestPlan[1<<i] = joinGroup[newPos2OldPos[i]]
	}
	// 从小到大罗列所有子图
	for nodeBitmap := uint(1); nodeBitmap < s << nodeCnt); nodeBitmap++ {
		if bits.OnesCount(nodeBitmap) == 1 {
			continue
		}
		// This loop can iterate all its subset.
		for sub := (nodeBitmap - 1) & nodeBitmap; sub > 0; sub = (sub - 1) & nodeBitmap {
			remain := nodeBitmap ^ sub
			if sub > remain {
				// 由于是无向图，所有相同两个子图的组合，只计算一遍
				continue
			}
			// 如果 sub/remain 这两个子图中某一个不是强连通的，不继续计算
			if bestPlan[sub] == nil || bestPlan[remain] == nil {
				continue
			}
			// Get the edge connecting the two parts.
			usedEdges := s.nodesAreConnected(sub, remain, oldPos2NewPos, totalEdges)
			if len(usedEdges) == 0 {
				// 如果 sub 和 remain 是不连通的，也不再继续计算
				continue
			}
			join, err := s.newJoinWithEdge(bestPlan[sub], bestPlan[remain], usedEdges)
			if err != nil {
				return nil, err
			}
			// 更新 nodeBitmap 所代表的子图中最优的 join 顺序
			if bestPlan[nodeBitmap] == nil || bestCost[nodeBitmap] > join.statsInfo().Count()+bestCost[remain]+bestCost[sub] {
				bestPlan[nodeBitmap] = join
				bestCost[nodeBitmap] = join.statsInfo().Count() + bestCost[remain] + bestCost[sub]
			}
		}
	}
	return bestPlan[(1<<nodeCnt)-1], nil
}
```

需要注意的是，bp 算法中需要估算每个 join 的代价，评估代价的过程当中需要使用统计信息，统计信息有的时候会不准确，这会影响 bp 算法的结果。

**补充知识**

从上面的代码可以看到，评估 join 代价的时候主要还是看 join.StatsInfo().Count() 的数值大小，这个数值表示 join 会产生的数据条数。评估 join 的数据条数和评估单表的数据条数的计算方法不同，这块的知识可以看一下 [数据库概念](https://book.douban.com/subject/10548379/) 13.3.3 的讲解和 [TiDB 的代码实现](https://github.com/pingcap/tidb/blob/v2.0.9/plan/stats.go#L270)。

## 复用 Chunk

为了提高查询执行器的执行速度，特别是在数据量比较大的情况下，TiDB 使用了 chunk。在执行查询的过程中，执行器每次不再只返回一条数据，而是返回一组数据。

除了使用 Chunk 以外，TiDB 的执行器还增加了 Chunk 复用的逻辑，有效的降低了内存的开销。在做一个数据量很大的 HashJoin 时（比如外表有几百万条数据），TiDB 会启动多个 worker 来计算 join 结果，worker 之间通过 Chunk 分发任务、接收计算结果。如果没有复用 Chunk 的话，查询过程会差生大量的 Chunk，GC 势必会影响性能。

TiDB 中当 worker 使用完了 chunk 以后，会通过特定的 channel 将 chunk 还回从而实现 Chunk 的复用。这块的代码不易拆分出来，暂略。









