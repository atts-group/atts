---
title: "Tidb Proposal: A new aggregate function execution framework"
date: 2019-04-07T16:09:38+08:00
draft: false
---

原文链接 [Proposal: A new aggregate function execution framework](https://github.com/pingcap/tidb/blob/master/docs/design/2018-07-01-refactor-aggregate-framework.md)

##摘要

这篇 proposal 提出了一种的聚合计算执行框架，用来提高聚合函数的执行性能。

## 背景

在 release-2.0 版本中，聚合计算框架在 expression/aggregation 模块中。在这个框架中，所有的聚合函数都实现了 `Aggregation` 接口。所有的聚合函数使用 `AggEvaluateContext` 来保存聚合计算的中间结果(partial result）。`AggEvaluateContext`  中的 `DistinctChecker` 字段使用 byte 数组作为 key，用来对相同分组中的数据进行去重。在执行过程中， `Update` 接口会被调，为每行数据计算和更新中间结果。在执行过程中，它为每个聚合函数枚举每种可能的聚合状态，这回带来大量的 CPU 分支检测。

在这个框架下，可以很简单的实现一个新的聚合函数。但是它也有很多缺点：

* `Update` 方法会为每条数据被调用。每次调用中都可能会带来大量开销，特别是执行过程中包含了上万条数据的时候。
* `Update` 方法会为每种计算状态调用，这也会带来大量的 CPU 分支检测。比如， `AVG` 函数在 `Partial1` 和 `Final` 状态下行为是不一样的，`Update` 方法不得不使用 switch 语句来处理所有可能的状态。
* `GetResult` 方法返回 `types.Datum` 类型作为每个分组的最终结果。在执行阶段，TiDB 目前使用 `Chunk` 来保存数据。使用了 aggregation 框架，不得不将返回的 `Datum` 类型转换成 `Chunk` ，这会带来大量的数据转换和内存分配工作。
* `AggEvaluateContext` 用来保存每组分组数据的最终结果，相比实际所需，这会消耗更多的内存。比如 `COUNT` 函数原本只需要一个 `int64`  字段来保存行数。
* `distinctChecker` 用来为数据去重，它使用的是 byte 数组作为 key。针对输入数据的 encoding 和 decoding 操作会带来大量的 CPU 开销，其实这个问题可以通过直接使用输入数据作为 key 来避免掉。

## 方案

在这个 PR 中 [https://github.com/pingcap/tidb/pull/6852](https://github.com/pingcap/tidb/pull/6852) ，提出了一个新的框架。新框架在 `executor/aggfuncs` 模块中。

在新的执行框架中，每个聚合函数实现了 `AggFunc` 接口。使用 `PartialResult` 作为每个聚合函数的中间结果，`PartialResult` 实际是 `unsafe.Pointer` 类型。`unsafe.Pointer` 允许中间结果可以使用任何数据类型。

`AggFunc` 接口包含以下函数：

* `AllocPartialResult` 分配和初始化某种特定数据结构来保存中间结果，将它转换成 `PartialResult` 类型并返回。聚合操作的实现，比如流式聚合 (Stream Aggregation) 要保存分配的 `PartialResult` ，用在后续和中间结果有关的操作上，比如 `ResetPartialResult` ，`UpdatePartialResult` 等等。
* `ResetPartialResult` 为聚合函数重置中间结果。将输入的 `PartialResult` 转换成某种数据结构，用来存中间结果，并将每个字段重置成初始状态。
* `UpdatePartialResult` 根据属于相同分组的输入数据计算并更新中间结果。
* `AppendFinalResult2Chunk` 完成最终的计算并将最终结果直接添加到输入的 `chunk` 当中。像其他操作一样，它把 `PartialResult` 先转换成某种数据结构，计算最终的结果，然后将最终结果添加到提供的 `chunk` 当中。
* `MergePartialResult` 使用输入的 `PartialResults` 计算最终结果。假设输入的 `PartialResults` 名称分别是`dst` 和 `srt`，它先把 `dst` 和 `src` 转换相同的数据结构，合并中间结果，将结果保存在 `dst` 中。

新的框架使用 `Build()` 函数来构建可执行的聚合函数。输入参数是：

* `aggFuncDesc` ：在查询优化器层表示聚合函数的数据结构
* `ordinal`：聚合函数的序号。这也是相应的聚合操作输出的 `chunk` 中输出列的顺序

`Build()` 方法为具体某种输入参数类型和聚合状态 (aggregate state) 构建可执行的聚合函数，输入数据类型、聚合状态等等信息越具体越好。

## 原理

优点：

* 在新框架下，中间结果可以是任何类型。聚合函数可以根据实际需要来分配内存，不会造成浪费。当用在 hash aggregation 时，OOM 的风险也会被降低。
* 中间结果可以是任何类型，这意味着，聚合函数可以使用 map，并以具体某种输入类型作为 key。比如，使用 `map[types.MyDecimal` 来对输入的数值进行去重。通过这种方式，旧框架中 decoding 和 encoding 带来的开销被降低了。
* `UpdatePartialResult` 被用来调用批量处理一组输入数据。为每条记录上而调用函数所带来的开销被节省掉了。由于所有的计算都使用 `Chunk` 来保存输入数据，在 `Chunk` 中相同列的数据在内存当中被连续存储，聚合函数会一个挨一个的执行，充分利用 CPU 缓存，减少缓存未命中（cache miss），从而提高执行性能。
* 对于每一种聚合状态和任何输入类型，都要实现对应的一个聚合函数来支持。这意味着在聚合状态和输入类型上面的 CPU 分支检测运算可以在 `UpdatePartialResult` 执行过程中被减少，更好的利用 CPU pipeline，提供执行速度。
* `AppendFinalResult2Chunk` 直接将最终结果加入到 chunk 当中，不需要将数据转成 `Datum` 再将 `Datum` 转换回 `Chunk`。这减少了大量的对象分配，降低了 golang gc worker 的开销，避免了 `Datum` 和 `Chunk` 之间不必要的数据转换。

缺点：

* 每种聚合函数要分别为每一种可能的聚合状态和输入类型，实现对应的计算函数。这可能会带来大量的开发工作。需要做更多的编码工作来支持新的聚合函数。

## 兼容性

目前，新的框架只支持了流式聚合。如果 `Build()` 方法返回 `nil` ，那么系统会使用旧的框架。

所以，这个新框架可以在开发过程中测试，所有的结果应该和旧框架一样。