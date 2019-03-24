---
title: "Group by and Aggregation Elimination"
date: 2019-03-21T11:31:17+08:00
draft: false
---

原文链接：[Group-by and Aggregation Elimination](https://blogs.oracle.com/optimizer/group-by-and-aggregation-elimination) 是一篇关于数据库查询优化的文章，有几句话实在不知道咋翻译好，也影响不大，直接留下原句了。翻译如下：

I get a fair number of questions on query transformations, and it’s especially true at the moment because we’re in the middle of the [Oracle Database 12c Release 2 beta program](https://www.oracle.com/corporate/pressrelease/db12r2-beta-oow-102615.html). 有时用户可能会发现在一个执行计划里有些环节消失了或者有些反常，然后会意识到查询发生了转换 (transformation) 。举个例子，有时你会惊讶的发现，查询语句里的表和它的索引可能压根就没有出现在查询计划当中，这是连接消除 (Join Elimination) 机制在起作用。

我相信，你已经发现查询转换是查询优化中很重要的一环，因为它经常能够通过消除一些像连接（join）、排序（sort）的步骤来降低查询的代价。有时修改查询的形式可以让查询使用不同的访问路径（access path），不同类型的连接和甚至完全不同的查询方式。在每个发布版本附带的优化器白皮书中（比如 [Oracle 12c One](https://www.oracle.com/technetwork/database/bi-datawarehousing/twp-optimizer-with-oracledb-12c-1963236.pdf) 的），我们都介绍了大多数的查询转换模式。

在 Oracle 12.1.0.1 中，我们增加了一种新的转换模式，叫做 *Group-by and Aggregation Elimination* ，之前一直没有提到。它在 Oracle 优化器中是最简单的一种查询转换模式了，很多人应该都已经很了解了。你们可能在 [Mike Dietrich’s upgrade blog](https://blogs.oracle.com/UPGRADE/) 中看到过关于它的介绍。让我们来看一下这种转换模式到底做了什么。

很多应用都有用过这么一种查询，这是一种单表分组查询的形式，数据是由另一个底层的分组查询形成的视图来提供的。比如下面这个例子：

```sql
SELECT v.column1, v.column2, MAX(v.sm), SUM(v.sm)
FROM (SELECT t1.column1, t1.column2, SUM(t1.item_count) AS sm
      FROM   t1, t2
      WHERE  t1.column4 > 3
      AND    t1.id = t2.id
      AND    t2.column5 > 10
      GROUP BY t1.column1, t1.column2) V
GROUP BY v.column1, v.column2;
```

如果没有查询转换，这个语句可能是下面这样的查询计划。每张表里有十万行数据，查询要运行 2.09 秒:

```
------------------------------------------------------
   Id | Operation             | Name | Rows  | Bytes |
------------------------------------------------------
|   0 | SELECT STATEMENT      |      |       |       |
|   1 |  HASH GROUP BY        |      | 66521 |  1494K|
|   2 |   VIEW                |      | 66521 |  1494K|
|   3 |    HASH GROUP BY      |      | 66521 |  2143K|
|   4 |     HASH JOIN         |      | 99800 |  3216K|
|   5 |      TABLE ACCESS FULL| T2   | 99800 |   877K|
|   6 |      TABLE ACCESS FULL| T1   | 99998 |  2343K|
------------------------------------------------------
```

从上面的计划中，你会看到有两个 Hash Group By 步骤，一个是为了视图，一个是为了外层的查询。我用的是 12.1.0.2 版本的数据库，通过设置隐藏参数 `_optimizer_aggr_groupby_elim` 为 false 的方式禁用了查询转换。

下面我们看一下查询转换生效时被转换的查询，你会发现只有一个 Hash Group By 步骤。查询时间也少了很多，只有 1.29 秒：

```
----------------------------------------------------
   Id | Operation           | Name | Rows  | Bytes |
----------------------------------------------------
|   0 | SELECT STATEMENT    |      |       |       |
|   1 |  HASH GROUP BY      |      | 66521 |  2143K|
|   2 |   HASH JOIN         |      | 99800 |  3216K|
|   3 |    TABLE ACCESS FULL| T2   | 99800 |   877K|
|   4 |    TABLE ACCESS FULL| T1   | 99998 |  2343K|
----------------------------------------------------
```

上面这个例子是相对比较好理解的，因为在视图中分组查询的列信息和外层查询是一样的。不一定非要是这样的形式才行。有的时候即使外层的 Group By 是视图中 Group By 的子集也是可以的。比如下面这个例子：

```
SELECT v.column1, v.column3, MAX(v.column1), SUM(v.sm)
FROM (SELECT t1.column1, t1.column2, t1.column3, SUM(t1.item_count) AS sm
      FROM   t1, t2
      WHERE  t1.column4 > 3 AND
             t1.id = t2.id  AND
             t2.column5 > 10
      GROUP BY t1.column1, t1.column2, t1.column3) V
GROUP BY v.column1, v.column3;

----------------------------------------------------
   Id | Operation           | Name | Rows  | Bytes |
----------------------------------------------------
|   0 | SELECT STATEMENT    |      |       |       |
|   1 |  HASH GROUP BY      |      | 49891 |  1607K|
|*  2 |   HASH JOIN         |      | 99800 |  3216K|
|*  3 |    TABLE ACCESS FULL| T2   | 99800 |   877K|
|*  4 |    TABLE ACCESS FULL| T1   | 99998 |  2343K|
----------------------------------------------------
```

你不需要额外做什么操作来开启这个查询转换。它默认是被开启的，当某个查询符合条件的时候就会自动被转换。在实际的企业级系统中，这种方式一定会带来很多显著的优化。不过要注意，这种转换模式在使用了 rollup 和 cube 的分组函数时是不起作用的。

这种转换有没有什么问题呢？是有的（这也是 Mike Dietrich 提到它的原因）。为了做这个转换，Oracle 优化器必须判断出来什么时候可以用什么时候不可以用，这背后的逻辑可能会很复杂。The bottom line is that there were some cases where the transformation was being applied and it shouldn’t have been. Generally, this was where the outer group-by query was truncating or casting columns used by the inner group-by. This is now fixed and it’s covered by patch number [21826068](https://support.oracle.com/epmos/faces/DocumentDisplay?id=21826068.8). Please use [MOS](https://support.oracle.com/) to check availability for your platform and database version.