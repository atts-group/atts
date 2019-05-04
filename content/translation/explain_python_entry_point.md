---
title: "Explain_python_entry_point"
date: 2019-05-04T23:21:00+08:00
draft: false
---

原文链接：https://stackoverflow.com/a/9615473/7537990

[EntryPoints](https://setuptools.readthedocs.io/en/latest/pkg_resources.html#entry-points) 提供了一个基于文件系统的，持久化的对象名称注册机制，以及一个基于名称的直接对象导入机制（由 [setuptools](http://pypi.python.org/pypi/setuptools) 包实现）

它们将一个 Python 对象的名称与自由格式标识符相关联。因此只要是使用了当前 Python 安装环境并且知道此标识符，任何代码都可以通过这个关联了的名称访问对应的对象，无论这个对象在什么地方被定义。**这个被关联的名称可以是存在于一个 Python 模块的任意一个名称**；例如一个类名，函数名，或者变量名。Entry point 机制并不在乎这个名称指向什么，只要它是可以被导入的。

举个例子吧，我们写一个函数，以及一个有完全合格的名称的虚拟 python 模块“myns.mypkg.mymodule”：

```
def the_function():
   "function whose name is 'the_function', in 'mymodule' module"
   print "hello from the_function"
```

Entry points 通过 setup.py 里的 `entry_points` 声明来注册。要把 `the_function` 注册到 `my_ep_func` 这个 entrypoint 上，我们可以这样：

```
	entry_points = {
        'my_ep_group_id': [
            'my_ep_func = myns.mypkg.mymodule:the_function'
        ]
    },
```

在上面的例子中，entry points 是分组写的；有一个对应的 API 可以找到一个分组下的所有 entry points（如下示例）。

在 package 被安装时（例如运行 `python setup.py install`），上面的声明会被传递给 setuptools。然后它会把传递过来的信息写到一个特殊的文件里。在那之后，我们就可以使用 [pkg_resources_API](https://setuptools.readthedocs.io/en/latest/pkg_resources.html#api-reference)（setuptools 的一部分）通过被关联的名称来查找 entry point 并且访问相应的对象了。

```
import pkg_resources

named_objects = {}
for ep in pkg_resources.iter_entry_points(group='my_ep_group_id'):
   named_objects.update({ep.name: ep.load()})
```

在这里，setuptools 读取了写到特殊文件里的 entry point 信息，找到了 entry point，导入了对应的模块（myns.mypkg.mymodule），并且在调用 `pkg_resources.load()` 时检索到了在那里被定义的 `the_function`。

假设这个分组内没有其他 entry point 被注册，那么调用 `the_function` 就会非常简单：

```
>>> named_objects['my_ep_func']()
hello from the_function
```

因此，即使在刚开始可能有点难以掌握，但这个 entry point 机制确实简单易用。它为可插拔 Python 软件开发提供了一个有用的工具。
