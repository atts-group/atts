---
title: "TiDB 源码学习：聚合查询"
date: 2019-04-07T15:53:09+08:00
draft: false
---

没了解过 Aggregation 的执行细节之前，感觉 Aggregation 比较神奇，它和普通的 SPJ 查询不太一样，Aggregation 会对数据分组并聚合计算，经过 Aggregation，整个数据的 schema 都会发生改变。

但其实，常见的 Aggregation 也并不复杂，从代码里看，和 Aggregation 相关的数据结构是这样的：

```go
// LogicalAggregation represents an aggregate plan.
type LogicalAggregation struct {
  logicalSchemaProducer

  AggFuncs     []*aggregation.AggFuncDesc
  GroupByItems []expression.Expression
  // groupByCols stores the columns that are group-by items.
  groupByCols []*expression.Column

  possibleProperties [][]*expression.Column
  inputCount         float64 // inputCount is the input count of this plan.
}


type basePhysicalAgg struct {
  physicalSchemaProducer

  AggFuncs     []*aggregation.AggFuncDesc
  GroupByItems []expression.Expression
}

// PhysicalHashAgg is hash operator of aggregate.
type PhysicalHashAgg struct {
  basePhysicalAgg
}

// PhysicalStreamAgg is stream operator of aggregate.
type PhysicalStreamAgg struct {
  basePhysicalAgg
}
```

无论是逻辑查询计划还是物理查询计划，聚合计算所需的关键信息都主要是聚合函数 (AggFuncs) 和分组规则 (GroupByItems) 。执行查询时，遍历子节点数据，根据 GroupByItems 将数据划分到不同的组中，然后调用聚合函数更新计算结果，直到子节点的数据全部消费完。

下面是 v2.0.9 版本 HashAggExec 的计算代码：

```go
// execute fetches Chunks from src and update each aggregate function for each row in Chunk.
func (e *HashAggExec) execute(ctx context.Context) (err error) {
  inputIter := chunk.NewIterator4Chunk(e.childrenResults[0])
  for {
    err := e.children[0].Next(ctx, e.childrenResults[0]) // 获取子节点数据
    // ...
    // no more data.
    if e.childrenResults[0].NumRows() == 0 {
      return nil
    }
    for row := inputIter.Begin(); row != inputIter.End(); row = inputIter.Next() {
      groupKey, err := e.getGroupKey(row) // 为每行数据计算 groupKey
      //...
      aggCtxs := e.getContexts(groupKey) // 根据 groupKey 获取对应的计算结果
      for i, af := range e.AggFuncs { // 遍历聚合函数，针对每行数据调用每一个聚合函数，更新聚合计算的结果
        err = af.Update(aggCtxs[i], e.sc, row)
        //...
      }
    }
  }
}
```

HashAggExec 是使用 HashTable 保存不同分组的中间计算结果 (PartialResult) ，等数据全部消费完以后，HashTable 中的结果则是最终结果了。上面代码的主要计算过程：

1. 遍历子节点数据（子节点可能是 Join、TableScan、Selection 等等）
2. 为每行数据计算 `groupKey` ，根据 groupKey 获取中间计算结果
3. 调用聚合函数，使用新遍历到的数据更新计算结果

下面以 avg 函数代码为例，分析一下聚合函数的代码逻辑：

```go
func (af *aggFunction) updateSum(sc *stmtctx.StatementContext, evalCtx *AggEvaluateContext, row types.Row) error {
  a := af.Args[0]
  value, err := a.Eval(row) // 计算每行数据对应的 value
  //...
  evalCtx.Value, err = calculateSum(sc, evalCtx.Value, value) // 更新总和
  //...
  evalCtx.Count++ // 更新数据行数
  return nil
}
```

**备注：**avg 函数相对特殊一点，和 sum/count 相比，计算过程中要记录 Sum 和 Count 作为中间数据。

**备注：**新版本为 HashAggExec 加入了并行计算功能，代码逻辑更加复杂，不过聚合计算逻辑没有太大变化。



[原文链接](http://localhost:4000/2019/04/07/TiDB-%E6%BA%90%E7%A0%81%E5%AD%A6%E4%B9%A0-%E8%81%9A%E5%90%88%E6%9F%A5%E8%AF%A2)

