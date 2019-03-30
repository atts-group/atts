---
title: "Spark累加器和广播变量"
date: 2019-03-30T11:21:36+08:00
draft: false
---

## 累加器
累加器提供将工作节点的值聚合到驱动器程序中的功能，且实现语法简单。

示例图：

![累加器示例图](http://pp0miv3mb.bkt.clouddn.com/20190330115622.png)

```python
#python中累加空行
file = sc.textFile(inputfile)
blankLines = sc.accumulator(0)  # 创建Accumulator(Int)

def extractCallSigns(line):
    global blankLines
    if line == "":
        blankLines += 1
    return line.split(' ')

callSigns = file.flatMap(extractCallSigns)
callSigns.saveAsTextFile(outputPath)
print('blank Lines : %d' %blankLines.value)
```

**实际使用中可以创建多个累加器进行计数**
```python
validSignCount = sc.Accumulator(0)
invalidSignCount = sc.Accumulator(0)
```

## 广播变量
### 简介
正常情况中，spark的task会在执行任务时，将变量进行拷贝。当每个task都从主节点拷贝时，程序的通信和内存负担很重。
使用广播变量后，主节点会将变量拷贝至工作节点，任务从工作节点获得变量，而不用再次拷贝，此时变量被拷贝的次数取决于工作节点的个数。

```python
#在Python中使用广播变量
signPrefixes = sc.broadcast(loadCallSignTable())

def processSignCount(sign_count, signPrefixes):
    country = lookupCountry(sign_count[0], signPrefixes.value)
    count = sign_count[1]
    return (country, count)

countryContactCounts = (contactCounts.map(processSignCount).reduceByKey((lambda x, y:x+y)))

countryContactCounts.saveAsTextFile(ooutputPath)
```


## 基于分区进行操作
基于分区对数据进行操作可以让我们避免为每个数据元素进行重复的配置工作。
Spark提供基于分区的map和foreach。

### Python基于分区操作
```python
def func(file):
    pass

def fetchCallSigns(input):
    return input.mapPartitions(lambda x: func(file=x))  #使用mapPartitons执行对分区的操作

do_func = fetchCallSigns(inputfile)
```

常见分区操作函数

| 函数名                   | 调用所提供的                           | 返回的             | 对于RDD[T]的函数签名               |
| ------------------------ | -------------------------------------- | ------------------ | ---------------------------------- |
| mapPartitions()          | 该分区中元素的迭代器                   | 返回的元素的迭代器 | f:(Iter ator[T]——>Iterator[U])     |
| mapPartitionsWithIndex() | 分区序号，以及每个分区中的元素的迭代器 | 返回的元素的迭代器 | f:(Int, Iterator[T]——>Iterator[U]) |
| forceachPartitions()     | 元素迭代器                             | 无                 | f:(Iterator[T]——>Unit)             |

## 数值RDD的操作
### 简介
Spark对包含数据的RDD提供了一些描述性的操作。
Spark的数据操作是通过流式算法实现的，允许以每次一个元素的方式构建模型。这些统计数据会在调用stats()时通过一次遍历计算出来，并以StatsCounter对象返回。

### 数值操作
StatsCounter中可用的汇总统计数据

| 方法             | 含义                 |
| ---------------- | -------------------- |
| count()          | RDD中的元素的个数    |
| mean()           | 元素的平均值         |
| sum()            | 总和                 |
| max()            | 最大值               |
| min()            | 最小值               |
| variance()       | 元素的方差           |
| sampleVariance() | 从采样中计算出的方差 |
| stdev()          | 标准差               |
| sampleStdev()    | 采用的标准差         |


Python中使用数据操作

```python
distanceNumerics = distances.map(lambda s: float(s))
stats = distanceNumerics.stats()
stdev = stats.stdev()  #计算标准差
mean = stats.mean()
resonableDistances = distanceNumerics.filter(lambda x: math.fabs(x - mean)<3 * stdev)
print(resonableDistances.collet())
```
