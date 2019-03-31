---
title: "TiDB Proposal: Support Skyline Pruning"
date: 2019-03-31T13:31:09+08:00
draft: false
---

原文链接：[Proposal: Support Skyline Pruning](https://github.com/pingcap/tidb/blob/master/docs/design/2019-01-25-skyline-pruning.md)，翻译如下：

## 摘要

这篇建议引入了一些启发式规则和一个针对消除访问路径 (access path) 的通用框架。通过它的帮助，优化器可以避免选择一些错误的访问路径。

## 背景

目前，访问路径的选择很大程度上取决于统计信息。我们可能会因为过期的统计信息而选择错误的索引。然而，很多错误的选择是可以通过简单的规则来消除的，比如：当主键或者唯一性索引能够完全匹配的时候，我们可以直接选择它而不管统计信息。

## 建议 (Proposal)

目前在选择访问路径时最大的因素是需要扫描的数据行数，是否满足物理属性 (physical property) ，以及是否需要两次扫描。在这三个因素当中，只有扫描行数依赖统计信息。那么在没有统计信息的情况下我们能够怎样比较扫描行数呢？让我们来看一下下面这个例子：

```sql
create table t(a int, b int, c int, index idx1(b, a), index idx2(a));
select * from t where a = 1 and b = 1;
```

从查询和表结构上，我们能够看到使用索引 idx1 扫描能够覆盖 idx2，通过索引 idx1 扫描的数据行数不会比使用 idx2 多，所以在这个场景中，idx1 要比 idx2 好。

我们如何综合这三个因素来消除访问路径呢？假如有两条访问路径 x 和 y，如果 x 在这几个方面都不比 y 差并且某个因素上 x 还好于 y，那么在使用统计数据之前，我们可以消除 y，因为 x 在任何情况下都一定比 y 更好。这就是所谓的 skyline pruning。

## 基本原理 (Rationale)

Skyling pruing 已经在其他数据库中实现，包括 MySQL 和 OceanBase。要是没有它，我们可能会在一些简单场景下选择错误的访问路径。

## 兼容性

Skyling pruning 并不影响兼容性。

## 实现

在为数据寻找最好的查询方式时，由于我们要决定使用哪一个满足物理条件的访问路径，我们需要使用 skyling pruning。大部分情况下不会有太多索引，一个简单的嵌套循环算法就足够了。任何两个访问路径的比较方式已经在 Proposal 章节里介绍过了。

## 引用

* [The Skyline Operator](http://skylineresearch.in/skylineintro/The_Skyline_Operator.pdf)