---
title: "Python的函数式编程"
date: 2019-05-12T23:18:30+08:00
draft: false
---

 原文地址：https://julien.danjou.info/python-and-functional-programming/

许多Python开发人员不知道您可以在多大程度上使用Python中的函数式编程，这是一个遗憾：除了少数例外，函数式编程允许您编写更简洁和高效的代码。此外，Python对函数式编程的支持非常广泛。


在这里，我想谈一点关于如何真正使用我们最喜欢的语言进行编程的功能性方法。

##  纯函数

当您使用函数样式编写代码时，您的函数被设计为没有副作用：相反，它们接受输入并生成输出，而不保留状态或修改返回值中未反映的任何内容。遵循这个理想的函数被称为纯函数函数。


让我们从一个常规的、非纯函数的示例开始，该函数删除列表中的最后一项：

```Python
def remove_last_item(mylist):
    """Removes the last item from a list."""
    mylist.pop(-1)  # This modifies mylist
```

此函数不是纯函数：它在修改给定参数时有副作用。让我们将其重写为纯粹的函数：
```Python
def butlast(mylist):
    """Like butlast in Lisp; returns the list without the last element."""
    return mylist[:-1]  # This returns a copy of mylist
```

我们定义了一个butlast（）函数（如lisp中的butlast），该函数不修改原始列表而返回最后一个元素的列表。相反，它会返回一份已进行修改的列表副本，允许我们保留原始列表。使用函数式编程的实际优势包括：


* 模块性。以功能性的风格写作，在一定程度上分离在解决你的个别问题和使代码部分在其他环境中更容易重用。因为函数不依赖于任何外部变量或状态，从另一段代码调用它是直截了当。

* 简洁。函数式编程通常比其他范式更不冗长。

* 并发性。纯函数函数是线程安全的，可以运行同时地。有些函数语言会自动执行此操作，可以如果您需要扩展应用程序，这是一个很大的帮助，尽管这不是在python中是这样的。

* 可测试性。测试一个功能性程序非常简单：你所需要的一切是一组输入和一组预期输出。它们是等幂的，意思是用相同的参数反复调用相同的函数将始终返回相同的结果。


注意，Python中的列表理解等概念在其方法中已经具有了功能，因为它们的设计是为了避免副作用。下面我们将看到，python提供的一些功能函数实际上可以表示为列表理解！

## python函数式函数


在使用函数式编程操作数据时，您可能会反复遇到相同的一组问题。为了帮助您有效地处理这种情况，python包含了许多用于函数编程的函数。在这里，我们将快速概述一些内置函数，这些函数允许您构建完全功能的程序。一旦您了解了什么是可用的，我鼓励您进一步研究并尝试在您自己的代码中可能应用的函数。

### 将函数应用于带有映射的项
map（）函数采用形式map（function，iterable），并对iterable中的每个项应用函数，以返回iterable映射对象：
```Python
>>> map(lambda x: x + "bzz!", ["I think", "I'm good"])
<map object at 0x7fe7101abdd0>
>>> list(map(lambda x: x + "bzz!", ["I think", "I'm good"]))
['I thinkbzz!', "I'm goodbzz!"]
```

您还可以使用列表理解编写一个相当于map（）的函数，其中

如下所示：
```Python
>>> (x + "bzz!" for x in ["I think", "I'm good"])
<generator object <genexpr> at 0x7f9a0d697dc0>
>>> [x + "bzz!" for x in ["I think", "I'm good"]]
['I thinkbzz!', "I'm goodbzz!"]
```


### 用筛选器筛选列表
filter（）函数接受表单筛选器（function or none，iterable），并根据函数返回的结果筛选iterable中的项。这将返回ITerable筛选器对象：
```python
>>> filter(lambda x: x.startswith("I "), ["I think", "I'm good"])
<filter object at 0x7f9a0d636dd0>
>>> list(filter(lambda x: x.startswith("I "), ["I think", "I'm good"]))
['I think']
```

您还可以使用列表理解编写一个相当于filter（）的函数，比如:
```python
>>> (x for x in ["I think", "I'm good"] if x.startswith("I "))
<generator object <genexpr> at 0x7f9a0d697dc0>
>>> [x for x in ["I think", "I'm good"] if x.startswith("I ")]
['I think']
```


### 使用枚举获取索引
enumerate（）函数的形式为enumerate（iterable[，start]），并返回一个iterable对象，该对象提供一系列元组，每个元组由一个整数索引（从start开始，如果提供）和iterable中的相应项组成。当需要编写引用数组索引的代码时，此函数非常有用。例如，不要写：

```python
i = 0
while i < len(mylist):
    print("Item %d: %s" % (i, mylist[i]))
    i += 1
```

使用enumerate（）可以更有效地完成相同的任务，如：

```python
for i, item in enumerate(mylist):
    print("Item %d: %s" % (i, item))
```


### 对列表进行排序


sorted（）函数采用排序的形式（iterable，key=none，reverse=false），并返回iterable的排序版本。key参数允许您提供返回要排序的值的函数：

```python
>>> sorted([("a", 2), ("c", 1), ("d", 4)])
[('a', 2), ('c', 1), ('d', 4)]
>>> sorted([("a", 2), ("c", 1), ("d", 4)], key=lambda x: x[1])
[('c', 1), ('a', 2), ('d', 4)]
```


### 查找满足任何和所有条件的项


any（iterable）和all（iterable）函数都根据iterable返回的值返回布尔值。这些简单函数相当于以下完整的python代码：

```python
def all(iterable):
    for x in iterable:
        if not x:
            return False
    return True

def any(iterable):
    for x in iterable:
        if x:
            return True
    return False
```

这些函数用于检查iterable中的任何或所有值是否满足给定条件。例如，下面检查了两个条件的列表：


```python
mylist = [0, 1, 3, -1]
if all(map(lambda x: x > 0, mylist)):
    print("All items are greater than 0")
if any(map(lambda x: x > 0, mylist)):
    print("At least one item is greater than 0")
```


这里的关键区别在于，您可以看到，当至少一个元素满足条件时，any（）返回true，而all（）仅当每个元素满足条件时返回true。对于空的iterable，all（）函数也将返回true，因为所有元素都不是false。

### 将列表与zip组合

函数的形式是zip（iter1[，iter2[…]），它接受多个序列并将它们组合成元组。当需要将键列表和值列表组合到dict中时，这很有用。与这里描述的其他函数一样，zip（）返回iterable。这里有一个键列表，我们映射到值列表以创建字典：

```python
>>> keys = ["foobar", "barzz", "ba!"]
>>> map(len, keys)
<map object at 0x7fc1686100d0>
>>> zip(keys, map(len, keys))
<zip object at 0x7fc16860d440>
>>> list(zip(keys, map(len, keys)))
[('foobar', 6), ('barzz', 5), ('ba!', 3)]
>>> dict(zip(keys, map(len, keys)))
{'foobar': 6, 'barzz': 5, 'ba!': 3}
```


## 下一步是什么？


虽然Python经常被宣传为面向对象的，但它可以以非常实用的方式使用。它的许多内置概念，如生成器和列表理解，都是面向功能的，不会与面向对象的方法冲突。python提供了一组内置函数，可以帮助您保持代码不受任何副作用的影响。这也限制了对一个项目的全球状态的依赖，为了你自己的利益。