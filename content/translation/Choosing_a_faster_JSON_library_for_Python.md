---
title: "为Python选择一个快速的JSON库"
date: 2019-05-06T01:23:42+08:00
draft: false
---

原文链接：https://pythonspeed.com/articles/faster-json-library/

使用JSON越多，就越可能遇到JSON编码或解码作为瓶颈的情况。Python的内置库也不错，但是有多个更快的JSON库可用：您如何选择使用哪一个？
事实上，没有一个正确的答案，也没有一个最快的JSON库来管理它们：


* “快速JSON库”对于不同的人来说意味着不同的东西，因为他们的使用模式不同。
* 速度不是万能的，还有其他你可能关心的事情，比如安全和定制。

为了帮助您根据需要选择最快的JSON库，我想分享一下我为Python选择快速JSON库所经历的过程。您可以使用此过程选择最适合您特定需求的库：

* 确保确实存在问题。
* 定义基准。
* 根据附加要求进行过滤。
* 对其余的候选人进行基准测试。



## 步骤1：您真的需要一个新的JSON库吗？
仅仅因为使用了JSON并不意味着它是一个相关的瓶颈。在花时间考虑哪个JSON库之前，您需要一些证据表明，Python的内置JSON库在您的特定应用程序中确实是一个问题。
在我的例子中，我从我的因果日志库Eliot的基准中了解到这一点，它表明JSON编码占用了生成消息所用CPU时间的25%。我能得到的最快的加速是以33%的速度运行（如果JSON编码时间变为零），但是这是一个足够大的时间块，它迟早会排在列表的最前面。

## 步骤2：定义基准
如果您查看各种JSON库的基准页，他们将讨论如何处理各种不同的消息。然而，这些消息并不一定符合您的用法。他们经常测量非常大的消息，在我的例子中，至少我关心小消息。

因此，您需要想出一些与您的特定使用模式相匹配的度量标准：

* 你在乎编码，解码，还是两者兼而有之？
* 您使用的是小消息还是大消息？
* 典型的消息是什么样子的？


在我的例子中，我主要关心对小消息进行编码，这是由Eliot生成的日志消息的特殊结构。基于一些真实的日志，我提出了以下示例消息： 

```json
{
    "timestamp": 1556283673.1523004,
    "task_uuid": "0ed1a1c3-050c-4fb9-9426-a7e72d0acfc7",
    "task_level": [1, 2, 1],
    "action_status": "started",
    "action_type": "main",
    "key": "value",
    "another_key": 123,
    "and_another": ["a", "b"],
}
```


## 步骤3：基于附加要求的过滤器
性能并不是所有的事情，还有其他你可能关心的事情。在我看来：

* 安全性/抗崩溃性：日志消息可以包含来自不受信任源的数据。如果JSON编码器在坏数据上崩溃，那么这对可靠性或安全性都不好。
* 自定义编码：Eliot支持自定义JSON编码，因此您可以序列化其他类型的Python对象。一些JSON库支持这一点，其他的则不支持。
* 跨平台：在Linux、MacOS、Windows上运行。
* 维护：我不想依赖一个没有得到积极支持的库。


我考虑的库有orjson、rapidjson、ujson和hyperjson。

我根据上述标准筛选出了其中一些：

* ujson有许多关于崩溃的bug文件，甚至那些已经修复的崩溃也不总是可用的，因为自2016年以来还没有发布过。
* hyperjson只有MacOS的软件包，而且总体上看起来还很不成熟。 



## 步骤4：基准测试
最后的两个竞争者是rapidjson和orjson。我进行了以下基准测试：
```python
import time
import json
import orjson
import rapidjson

m = {
    "timestamp": 1556283673.1523004,
    "task_uuid": "0ed1a1c3-050c-4fb9-9426-a7e72d0acfc7",
    "task_level": [1, 2, 1],
    "action_status": "started",
    "action_type": "main",
    "key": "value",
    "another_key": 123,
    "and_another": ["a", "b"],
}

def benchmark(name, dumps):
    start = time.time()
    for i in range(1000000):
        dumps(m)
    print(name, time.time() - start)

benchmark("Python", json.dumps)
# orjson only outputs bytes, but often we need unicode:
benchmark("orjson", lambda s: str(orjson.dumps(s), "utf-8"))
benchmark("rapidjson", rapidjson.dumps)
```
结果是：
```python
$ python jsonperf.py 
Python 4.829106330871582
orjson 1.0466396808624268
rapidjson 2.1441543102264404
```
即使需要额外的Unicode解码，orjson也是最快的（对于这个特定的基准！）.


像往常一样，存在着权衡。orjson的用户比rapidjson少（比较orjson PyPi stats和rapidjson PyPi stats），而且没有conda包，所以我必须自己打包它以用于conda-forge。但它肯定要快得多。

## 你的用例，你的选择

你应该用orjosn吗？不一定。您可能有不同的需求，并且您的基准可能不同，例如，您可能需要解码大型文件。

关键在于过程：找出您的特定需求、性能等，并选择最能满足您需求的库。