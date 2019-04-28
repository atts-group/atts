---
title: "TiDB 源码学习：列裁剪"
date: 2019-04-21T21:51:04+08:00
draft: false
---

今天整理 TiDB 的一种常见优化手段：列裁剪 (column pruning)

列裁剪是很常见的一种优化手段，除了能够降低网络开销以外，也能够降低数据库的内存开销和 cpu 开销。比如下面这个查询：

```sql
select t1.id from t1, t2 where t1.id == t2.t1_id where t2.state = 1;
```

这个查询比较极端，t2 表在 join 之后，没有任何一列会再需要被使用。假如 t2 表里有十多个字段，而查询没有做列裁剪的话。那这十几个字段要在在整个查询树上流动，内存开销就得大出好几倍。

代码中，是通过递归调用各个 LogicalPlan 子类的 PruneColumns 来完成列裁剪的，PruneColumns 方法会代用上层节点要求使用的列信息，子节点根据上层节点要使用的列信息以及自己要使用的列信息（比如：上个例子中 的 t2.t1_id 和 t2.state ，上层节点不会使用但是连接过程要使用）来计算哪些列可以被裁剪掉。

Join 的 [PruneColumns](https://github.com/pingcap/tidb/blob/v2.0.9/plan/column_pruning.go#L222) 方法

```go
func (p *LogicalJoin) extractUsedCols(parentUsedCols []*expression.Column) (leftCols []*expression.Column, rightCols []*expression.Column) {
	for _, eqCond := range p.EqualConditions {
		parentUsedCols = append(parentUsedCols, expression.ExtractColumns(eqCond)...)
	}
	for _, leftCond := range p.LeftConditions {
		parentUsedCols = append(parentUsedCols, expression.ExtractColumns(leftCond)...)
	}
	for _, rightCond := range p.RightConditions {
		parentUsedCols = append(parentUsedCols, expression.ExtractColumns(rightCond)...)
	}
	for _, otherCond := range p.OtherConditions {
		parentUsedCols = append(parentUsedCols, expression.ExtractColumns(otherCond)...)
	}
	lChild := p.children[0]
	rChild := p.children[1]
	for _, col := range parentUsedCols {
		if lChild.Schema().Contains(col) {
			leftCols = append(leftCols, col)
		} else if rChild.Schema().Contains(col) {
			rightCols = append(rightCols, col)
		}
	}
	return leftCols, rightCols
}

func (p *LogicalJoin) PruneColumns(parentUsedCols []*expression.Column) {
	leftCols, rightCols := p.extractUsedCols(parentUsedCols)
	lChild := p.children[0]
	rChild := p.children[1]
	lChild.PruneColumns(leftCols)
	rChild.PruneColumns(rightCols)
	p.mergeSchema()
}
```

代码逻辑：

* 将 parentUsedCols 拆分出 leftChild 和 rightChild 中的列
  * extractUsedCols 方法除了将 parentUsedCols 拆分以外，还会将 join 相关条件中的列信息拆分出来。
* 递归调用子节点的 PruneColumns
* 调用 mergeSchema 重新生成 join 的 schema (Schema 主要用来保存列信息)

Aggregation 的 [PruneColumns](https://github.com/pingcap/tidb/blob/v2.0.9/plan/column_pruning.go#L85) 方法：

```go
// PruneColumns implements LogicalPlan interface.
func (la *LogicalAggregation) PruneColumns(parentUsedCols []*expression.Column) {
	child := la.children[0]
	used := getUsedList(parentUsedCols, la.Schema())
	for i := len(used) - 1; i >= 0; i-- {
		if !used[i] {
			la.schema.Columns = append(la.schema.Columns[:i], la.schema.Columns[i+1:]...)
			la.AggFuncs = append(la.AggFuncs[:i], la.AggFuncs[i+1:]...)
		}
	}
	var selfUsedCols []*expression.Column
	for _, aggrFunc := range la.AggFuncs { // 从聚合函数中解析需要使用的列
		selfUsedCols = expression.ExtractColumnsFromExpressions(selfUsedCols, aggrFunc.Args, nil)
	}
	if len(la.GroupByItems) > 0 { // 从分组表达式中解析需要使用的列
		for i := len(la.GroupByItems) - 1; i >= 0; i-- {
			cols := expression.ExtractColumns(la.GroupByItems[i])
			if len(cols) == 0 {
				la.GroupByItems = append(la.GroupByItems[:i], la.GroupByItems[i+1:]...)
			} else {
				selfUsedCols = append(selfUsedCols, cols...)
			}
		}
		// If all the group by items are pruned, we should add a constant 1 to keep the correctness.
		// Because `select count(*) from t` is different from `select count(*) from t group by 1`.
		if len(la.GroupByItems) == 0 {
			la.GroupByItems = []expression.Expression{expression.One}
		}
	}
	child.PruneColumns(selfUsedCols)
}
```

除了 parentUsedCols，Aggregation 需要从聚合函数和分组表达式解析出聚合查询需要使用的列。然后递归调用子节点的 PruneColumns 方法。

