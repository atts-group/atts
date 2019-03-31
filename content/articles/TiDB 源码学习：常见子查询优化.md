---
title: "TiDB 源码学习：常见子查询优化"
date: 2019-03-31T13:19:47+08:00
draft: false
---

根据 [TiDB 中的子查询优化技术](https://pingcap.com/blog-cn/tidb-optimization-for-subquery) 这篇文章的介绍，TiDB 在处理关联子查询时引入了 Apply 算子。然后使用关系代数将 Apply 算子等价转换成其他算子，从而达到去关联化的目的。理论上，所有的关联子查询都可以去关联化，具体的理论知识可以看这篇博客：[SQL 子查询的优化](https://zhuanlan.zhihu.com/p/60380557)。

本文从代码角度，梳理一下常见关联子查询的优化。处理过程主要有两个阶段：

1. 重写阶段：在将语法树转换成逻辑查询计划时，将子查询重写成带有 Apply 算子的查询计划，这部分主要是由 [expressionRewriter](https://github.com/pingcap/tidb/blob/v2.0.9/plan/expression_rewriter.go#L110) 负责
2. 去关联化：在优化逻辑查询计划时，尝试将 Apply 算子替换成其他算子，从而去关联化，这部分主要有 [decorrelateSolver](https://github.com/pingcap/tidb/blob/v2.0.9/plan/decorrelate.go#L115) 负责 

## expressionRewriter 简介

expressionRewriter 负责将子查询重语法树写成带有 Apply 算子的查询计划。为了实现这一功能，需要能够遍历语法树，expressionRewriter 实现了 [Visitor](https://github.com/pingcap/tidb/blob/v2.0.9/ast/ast.go#L196) 接口，能够遍历语法树中的各个节点，在遍历过程当中完成重写工作，它的核心的方法主要是 [Enter](https://github.com/pingcap/tidb/blob/v2.0.9/plan/expression_rewriter.go#L221) 和 [Leave](https://github.com/pingcap/tidb/blob/v2.0.9/plan/expression_rewriter.go#L688)。

Visitor 接口一般会被这样使用：

```go
func (n *CompareSubqueryExpr) Accept(v Visitor) (Node, bool) {
  newNode, skipChildren := v.Enter(n)
  if skipChildren {
    return v.Leave(newNode)
  }
  n = newNode.(*CompareSubqueryExpr)
  node, ok := n.L.Accept(v)
    //...
  n.L = node.(ExprNode)
  node, ok = n.R.Accept(v)
  //...
  n.R = node.(ExprNode)
  return v.Leave(n)
}
```

每个语法树节点通过调用 Accept、Enter 和 Leave 方法来实现对整个语法树节点的遍历。

## Q1

```sql
select t1.a from t t1 
  where 1000 in (select t2.b from t t2 where t2.a = t1.a)
```

Q1 是最简单常见的一种子查询，通过对 Q1 的分析，我们能够理解子查询优化的框架。

### 重写阶段

在 Q1 中，子查询出现在 where 当中，在构建逻辑查询计划时，会被 expressionRewriter 重写。

构建 select 查询计划过程中，主要会执行以下几个方法，分别用来构建 DataSource、Selection、Aggregation 等逻辑查询节点：

- [buildSelect](https://github.com/pingcap/tidb/blob/v2.0.9/plan/logical_plan_builder.go#L1570)
  - [buildResultSetNode](https://github.com/pingcap/tidb/blob/v2.0.9/plan/logical_plan_builder.go#L129)
  - [resolveGbyExprs](https://github.com/pingcap/tidb/blob/v2.0.9/plan/logical_plan_builder.go#L1470)
  - [resolveHavingAndOrderBy](https://github.com/pingcap/tidb/blob/v2.0.9/plan/logical_plan_builder.go#L1068)
  - **[buildSelection](https://github.com/pingcap/tidb/blob/v2.0.9/plan/logical_plan_builder.go#L455)**
  - [buildAggregation](https://github.com/pingcap/tidb/blob/v2.0.9/plan/logical_plan_builder.go#L67)
  - [buildProjection](https://github.com/pingcap/tidb/blob/v2.0.9/plan/logical_plan_builder.go#L580)

buildSelect 中被调用的这些函数都使用了 expressionRewriter ，在 Q1 中，子查询重写发生在 buildSelection 当中：

```go
func (b *planBuilder) buildSelection(p LogicalPlan, where ast.ExprNode, AggMapper map[*ast.AggregateFuncExpr]int) LogicalPlan {
  //...
  conditions := splitWhere(where)
    //...
  for _, cond := range conditions {
    expr, np, err := b.rewrite(cond, p, AggMapper, false)
    //...
  }
  //...
}
```

Q1 的 where 部分比较简单，只包含了一个子查询 和 in 组成条件，对应的是 PatternInExpr 类型，先简单了解一下 [PatternInExpr](https://github.com/pingcap/tidb/blob/v2.0.9/ast/expressions.go#L543)：

```go
type PatternInExpr struct {
  exprNode
  // Expr is the value expression to be compared.
  Expr ExprNode
  // List is the list expression in compare list.
  List []ExprNode
  // Not is true, the expression is "not in".
  Not bool
  // Sel is the subquery, may be rewritten to other type of expression.
  Sel ExprNode
}
```

在关联子查询中主要用到了 `Sel` 和 `Expr` 属性，`Sel` 对应的是子查询 `select t2.b from t t2 where t2.a = t1.a` ，`Expr` 对应的是常量 1000。



根据 expressionRewriter 的 Enter 方法，处理逻辑主要在 handleInSubquery 当中。

```go
// Enter implements Visitor interface.
func (er *expressionRewriter) Enter(inNode ast.Node) (ast.Node, bool) {
  switch v := inNode.(type) {
  //...
  case *ast.PatternInExpr:
    if v.Sel != nil {
      return er.handleInSubquery(v)
    }
    //...
  //...
  }
  return inNode, false
}
```

expressionRewriter 还有 handleCompareSubquery、handleExistSubquery、handleScalarSubquery 等方法分别用来处理其他几种子查询。

分析 handleInSubquery 代码，简化后的代码如下：

```go
func (er *expressionRewriter) handleInSubquery(v *ast.PatternInExpr) (ast.Node, bool) {
  //...
  lexpr := er.ctxStack[len(er.ctxStack)-1]
  subq, ok := v.Sel.(*ast.SubqueryExpr) 
  //...
  np := er.buildSubquery(subq) // 构建子查询
  //...
  var rexpr expression.Expression
  //...
  checkCondition, err := er.constructBinaryOpFunction(lexpr, rexpr, ast.EQ) // 构建查询条件
  //...
  er.p = er.b.buildSemiApply(er.p, np, expression.SplitCNFItems(checkCondition), asScalar, v.Not) // 创建 Apply 算子
  //...
  return v, true
}
```

expressionRewriter 先构建子查询的查询计划，然后根据 In 条件参数创建 Apply 的 conditions，最后调用 buildSemiApply 方法构建 Apply 查询计划。

#### 小结

为 Q1 构建查询计划过程中，与子查询重写有关的函数调用过程大致如下，expressionRewriter 简写成 er。

- buildSelect() <= 创建 Select 语句的查询计划
  - buildSelection() <= 创建 Selection 节点
    - rewrite() <= 重写 Q1 的子查询
      - **exprNode.Accept(er)**  <= expressionRewriter 从这里开始遍历语法树
        - er.Enter()
          - er.handleInSubquery()
            - er.buildSubquery()
            - er.constructBinaryOpFunction()
            - **er.b.buildSemiApply()** <= 创建 Apply 算子

最终得到的查询计划大致如下：

![](/tidb-subquery-optimization/Q1-logical-plan.png)

注意，图中的 Apply 是 SemiApply。

#### LogicalApply 类型

TiDB 使用 LogicalApply 来表示 Apply 算子：

```go
type LogicalApply struct {
  LogicalJoin

  corCols []*expression.CorrelatedColumn
}
```

从数据结构上也能看出，LogicalApply 和 LogicalJoin 很像，Apply 类型其实也是通过 JoinType 类型设置的（比如，SemiJoin、LeftOuterJoin、InnerJoin 等）。

### 去关联化

去关联化是在逻辑查询优化过程中完成的，代码逻辑主要看 [decorrelateSolver](https://github.com/pingcap/tidb/blob/v2.0.9/plan/decorrelate.go#L115) 。

优化的思路是：**尽可能把 Apply 往下推、把 Apply 下面的算子向上提**，通过这一方式将关联变量变成普通变量，从而去关联化。虽然这一过程可能看起来会让查询计划的效率降低，但是去关联化以后再通过谓词下推等优化规则可以重新对整个查询计划进行优化。

Q1 涉及到的代码如下：

```go
// optimize implements logicalOptRule interface.
func (s *decorrelateSolver) optimize(p LogicalPlan) (LogicalPlan, error) {
  if apply, ok := p.(*LogicalApply); ok {
    outerPlan := apply.children[0]
    innerPlan := apply.children[1]
    apply.extractCorColumnsBySchema()
    if len(apply.corCols) == 0 { // <= 如果关联变量都被消除，可以将 Apply 转换成 Join
      join := &apply.LogicalJoin
      join.self = join
      p = join
    } else if sel, ok := innerPlan.(*LogicalSelection); ok { // <= 在这个分支中消除 Selection 节点
      newConds := make([]expression.Expression, 0, len(sel.Conditions))
      for _, cond := range sel.Conditions {
        newConds = append(newConds, cond.Decorrelate(outerPlan.Schema()))
      }
      apply.attachOnConds(newConds)
      innerPlan = sel.children[0]
      apply.SetChildren(outerPlan, innerPlan)
      return s.optimize(p) // Selection 被消除以后，重新对 Apply 优化，在 Q1 中会触发 Apply 被转换成 Join
    } else if m, ok := innerPlan.(*LogicalMaxOneRow); ok {
      //...
    } else if proj, ok := innerPlan.(*LogicalProjection); ok {
      //...
    } else if agg, ok := innerPlan.(*LogicalAggregation); ok {
      //...
    }
  }
  //...
  return p, nil
}
```

参考上面提供的查询计划示意图，代码执行过程中：

1. 寻找 Apply 节点，找到 Apply 节点以后，尝试对 innerPlan 子节点中的算子往上提，在 Q1 中：
   1. 将 Selection(t1.a=t2.a) 节点中的条件提到 Apply 上，消除 Selection 节点
   2. 完成这一步以后，Apply 的关联变量就被消除了，这样就可以把 Apply 转换成一个普通的 Join 了，Q1 的去关联化过程也基本完成。

整个过程如下图所示：

![](/tidb-subquery-optimization/Q1-logical-plan-transformation.png)

## Q2

```sql
select t1.a from t t1 
  where 1000 < (select min(t2.b) from t t2 where t2.a = t1.a)
```

Q2 相对 Q1，子查询稍微复杂了一点，多了聚合函数。

### 重写阶段

重写阶段和 Q1 很类似，区别主要在于查询条件不再是 PatternInExpr，变成了 BinaryOperationExpr，重写逻辑主要发生在 handleScalarSubquery 当中：

```go
func (er *expressionRewriter) handleScalarSubquery(v *ast.SubqueryExpr) (ast.Node, bool) {
   np, err := er.buildSubquery(v)
   //...
   np = er.b.buildMaxOneRow(np)
   if len(np.extractCorrelatedCols()) > 0 {
      er.p = er.b.buildApplyWithJoinType(er.p, np, LeftOuterJoin)
      //...
      return v, true
   }
   //...
}
```

另外一点不同是，Apply 类型变成了 LeftOuterJoin （如何选择 Apply 的类型，可以参考开头的几篇文章）。重写完以后得到的查询计划大致如下：

![](/tidb-subquery-optimization/Q2-logical-plan.png)

### 去关联化

和 Q1 相比，由于有 Aggregation 节点，Q2 的去关联化逻辑更复杂一些。对于 Q2 这类带有 aggr 的查询，decorrelateSolver 尽可能将 Aggregation 向上拉：

```go
func (s *decorrelateSolver) optimize(p LogicalPlan) (LogicalPlan, error) {
  if apply, ok := p.(*LogicalApply); ok {
    outerPlan := apply.children[0]
    innerPlan := apply.children[1]
    apply.extractCorColumnsBySchema()
    if len(apply.corCols) == 0 {
      //...
    } else if sel, ok := innerPlan.(*LogicalSelection); ok {
      //...
    } else if m, ok := innerPlan.(*LogicalMaxOneRow); ok {
      //...
    } else if proj, ok := innerPlan.(*LogicalProjection); ok {
      //...
    } else if agg, ok := innerPlan.(*LogicalAggregation); ok {
      if apply.canPullUpAgg() && agg.canPullUp() { // 尝试将 Aggregation 上提
        //...
      }
      // 如果 Aggregation 不能上提，尝试将 Aggregation 下面的 Selection 上提，去掉关联变量
      if sel, ok := agg.children[0].(*LogicalSelection); ok && apply.JoinType == LeftOuterJoin {
        var (
          eqCondWithCorCol []*expression.ScalarFunction
          remainedExpr     []expression.Expression
        )
        // 解析 Selection 中的关联条件
        for _, cond := range sel.Conditions {
          if expr := apply.deCorColFromEqExpr(cond); expr != nil {
            eqCondWithCorCol = append(eqCondWithCorCol, expr.(*expression.ScalarFunction))
          } else {
            remainedExpr = append(remainedExpr, cond)
          }
        }
        if len(eqCondWithCorCol) > 0 {
          //...
          if len(apply.corCols) == 0 {
            join := &apply.LogicalJoin
            join.EqualConditions = append(join.EqualConditions, eqCondWithCorCol...)
                        for _, eqCond := range eqCondWithCorCol {
                            // 对于被上提的筛选条件，如果 Aggregation 没有包含对应列的分组的话
                            // 需要在 Aggregation 中添加上分组
              clonedCol := eqCond.GetArgs()[1].Clone()
              // If the join key is not in the aggregation's schema, add first row function.
              if agg.schema.ColumnIndex(eqCond.GetArgs()[1].(*expression.Column)) == -1 {
                newFunc := aggregation.NewAggFuncDesc(apply.ctx, ast.AggFuncFirstRow, []expression.Expression{clonedCol}, false)
                agg.AggFuncs = append(agg.AggFuncs, newFunc)
                agg.schema.Append(clonedCol.(*expression.Column))
              }
              // If group by cols don't contain the join key, add it into this.
              if agg.getGbyColIndex(eqCond.GetArgs()[1].(*expression.Column)) == -1 {
                agg.GroupByItems = append(agg.GroupByItems, clonedCol)
              }
            }
            //...
            agg.collectGroupByColumns()
            if len(sel.Conditions) == 0 { // <= Selection 的条件都被删除，那么节点可以被消除了
              agg.SetChildren(sel.children[0])
            }
            //...
            return s.optimize(p) // Selection 被消除以后重新对 Apply 节点进行优化，触发 Apply 转换成 Join 的逻辑
          }
          //...
        }
      }
    }
  }
  //...
  return p, nil
}
```

可惜的是，Q2 中的 Aggregation 是无法 pull up 的，貌似 TiDB 并没有完全按照开头文章中提到的方式去做子查询优化。虽然 Aggregation 无法上提，但是 decorrelator 会尝试将子节点 Selection 中的条件合并到 Apply 中，这个过程和 Q1 很像。如果 Selection 中的条件都被合并到 Apply 当中，那么 Selection 节点可以被消除了。

在 Q2 中 Selection 节点删除后，子查询不再包含关联变量，Apply 可以被转换为 Join。去关联以后得到的查询计划大致如下：

![](/tidb-subquery-optimization/Q2-logical-plan-decorrelated.png)