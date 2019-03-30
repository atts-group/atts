---
title: "Intro to Python Lambda Functions"
date: 2019-03-30T17:14:57+08:00
draft: false
---

原文地址: https://www.pythonforthelab.com/blog/intro-to-python-lambda-functions/


不久前，Python在其语法中引入了使用lambda而不是def来定义函数的可能性。这些函数称为匿名函数同，在其它语言(如javascript)中非常常见。然后，在Python中，它们看起来有点晦涩，经常被忽略或误用。在本文中，我们将介绍labda函数，并讨论在何处以及如何使用它。
    
要定义一个函数，可以使用以下语法：

```python
    def average(x, y):
        return (x + y) / 2
```


然后，如果要计算两个数字的平均值，只需执行以下操作


```python
 avg = average(2, 5)
```

 在这种情况下，平均值将为3.5。我们也可以这样定义平均值：

 ```python
 average = lambda x, y: (x + y) / 2
 ```

如果你测试此函数，您将看到输出完全一样。必须指出，def和lambda之间语法非常不同。首先，我们定义不带括号的参数x, y。然后，我们定义要应用的操作。注意，当使用lambda函数时，返回是隐式的。
    
然而，还有更根本的区别。lambda函数只能在一行上表示，并且没有docstring。如果对上面的每个定义尝试help(average)，您将看到输出非常不同，此外，无法记录average的第二版的实际操作。
    
从功能上讲，定义平均值的两种方法都给出了相同的结果。到目前为止，他们之间的差异非常微妙。lambda（或匿名）函数的主要优点是它们不需要名称。此外，像我们上面所做的那样指定一个名字被认为是不好的做法，我们稍后将讨论。现在让我们看看您希望在什么上下文中使用lambda函数而不是普通函数。

大多数教程都侧重于lambda函数来对列表进行排序。在讨论其他主题之前，我们也可以这样做。假设您有以下列表：

```python
var=[1，5，-2，3，-7，4]
```

假设您希望对值进行排序，可以执行以下操作：

```Python
sorted_var = sorted(var)
#[-7，-2，1，3，4，5]
```


这很容易。但是，如果您希望根据到给定数字的距离对值进行排序，会发生什么情况呢？如果要计算到1的距离，需要对每个数字应用一个函数，例如abs（x-1），并根据输出对值进行排序。幸运的是，排序后，您可以使用关键字参数key=执行此操作。我们可以做到：

```Python
def distance(x):
    return abs(x - 1)

sorted_var = sorted(var, key=distance)
# [1, 3, -2, 4, 5, -7]
```


另一种选择是使用lambda函数：

```Python
sorted_var = sorted(var, key=lambda x: abs(x-1))
```


这两个例子将产生完全相同的输出。在使用def或lambda定义函数之间没有功能差异。我可以说第二个例子比第一个稍微短一些。此外，它使代码更具可读性，因为您可以立即看到对每个元素（abs（x-1））所做的操作，而不是通过代码挖掘来查看定义的距离。



另一种可能是与map结合使用。map是将函数应用于列表中的每个元素的一种方法。例如，基于上面的示例，我们可以执行以下操作：

```Python
list(map(distance, var))
# [0, 4, 3, 2, 8, 3]
```

或者，使用lambda表达式
```Python
list(map(lambda x: abs(x-1), var))
# [0, 4, 3, 2, 8, 3]
```


它给出了完全相同的输出，同样，人们可以争论哪一个更容易阅读。上面的示例是您在其他教程中可能看到的。如果通过stackoverflow，可能会看到。其中一种可能是结合Pandas使用lambda函数。



**pandas和lambda函数**

示例数据受此示例的启发，可以在此处找到。创建包含以下内容的文件示例**example_data.csv**：
```
animal,uniq_id,water_need 
elephant,1001,500 
elephant,1002,600 
elephant,1003,550 
tiger,1004,300 
tiger,1005,320 
tiger,1006,330 
tiger,1007,290 
tiger,1008,310 
zebra,1009,200 
zebra,1010,220 
zebra,1011,240 
zebra,1012,230 
zebra,1013,220 
zebra,1014,100 
zebra,1015,80 
lion,1016,420 
lion,1017,600 
lion,1018,500 
lion,1019,390 
kangaroo,1020,410 
kangaroo,1021,430 
kangaroo,1022,410
```


要将数据读取为数据帧，我们只需执行以下操作：

```Python
import pandas as pd 
df = pd.read_csv('example_data.csv', delimiter = ',') 
```


假设您希望将数据框中每个动物名称的第一个字母大写，您可以执行以下操作：
```Python
df['animal']=df['animal'].apply((lambda x:x.capitalize())
print(df.head())
```
你会看到结果。当然，lambda函数可能变得更加复杂。您可以将它们应用于整个系列，而不是单个值，您可以将它们与其他库（如numpy或scipy）组合，并对数据执行复杂的转换。

lambda函数最大的优点之一是，如果您使用的是Jupyter notebools，那么您可以立即看到这些变化。你不需要打开另一个文件，运行一个不同的，单元格等。如果你去Pandas的文档，你会看到，lambdas经常被使用。



**Qt Slots**

使用lambdas的另一个常见示例是与qt库结合使用。我们过去写过一篇关于qt的介绍性文章。如果您不熟悉构建用户界面的工作方式，可以随意浏览它。一个非常简单的例子，只显示一个按钮，它看起来像这样：

```Python
from PyQt5.QtWidgets import QApplication, QPushButton
app = QApplication([])
button = QPushButton('Press Me')
button.show()
app.exit(app.exec())
```
如果要在按下按钮时触发某个操作，则必须将该操作定义为一个函数。如果我们想在按下按钮时将某些内容打印到屏幕上，我们只需在app.exit之前添加以下行：

```Python
button.clicked.connect(lambda x: print('Pressed!'))
```

如果您再次运行程序，每次按下按钮，您都会看到已按下！出现在屏幕上。同样，使用lambda函数作为信号的插槽可以加快编码速度，使程序更容易阅读。但是，lambda函数也需要谨慎考虑。



**lambda函数的使用位置**

lambda函数只能有一行。这迫使开发人员只能在没有复杂语法的情况下使用它们。在上面的示例中，您可以看到lambda函数非常简单。如果它需要打开一个套接字，交换一些信息，处理接收到的数据等，那么它可能不可能在一条线上完成。



可以使用lambda函数的自然情况是作为其他需要可调用参数的函数的参数。例如，应用pandas数据帧需要一个函数作为参数。连接qt中的信号还需要一个函数。如果我们要应用或执行的函数很简单，并且我们不打算重复使用它，那么将其编写为匿名函数可能是一种非常方便的方法。



**不使用lambda函数的位置**

lambda函数是匿名的，因此，如果您要为其分配名称，例如在执行以下操作时：

```Python
average = lambda x，y:（x+y）/2
```


这意味着你做错了什么。如果需要为函数指定一个名称，以便在程序的不同位置使用它，请使用标准的def语法。在这个博客中有一个关于Python中lambda函数滥用的冗长讨论。我经常看到的，尤其是刚学过lambdas的人，是这样的：

```Python
sorted_var = sorted(var, key=lambda x: abs(x))
```
如果这是第一次看到lambda函数，那么这个无辜的示例可能很难包装起来。但是，您所拥有的是将一个函数（abs）包装在另一个函数中。它应该是这样的：

```Python
def func(x):
    return abs(x)
```

与仅仅做abs（x）相比有什么优势？实际上，没有优势，这意味着我们也可以这样
```Python
sorted_var = sorted(var, key=abs)
```
如果您注意我们前面开发的示例，我们使用abs（x-1）来避免这种冗余。



**结论**

lambda（或匿名）函数是一种在Python程序中逐渐流行的工具。这就是为什么你能理解它的含义是非常重要的。您必须记住，lambda语法不允许您这样做，没有它们是不可能做到的。更重要的是它的方便性、语法经济性和可读性。

在其他编程语言（如javascript）中，匿名函数的使用频率非常高，并且具有比Python更丰富的语法。我不相信Python也会这样做，但无论如何，它们是一种工具，不仅可以帮助您使用当前的程序，而且还可以帮助您了解如果您修补其他语言的话会发生什么。