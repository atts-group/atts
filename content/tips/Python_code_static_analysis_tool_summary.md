---
title: "Python_code_static_analysis_tool_summary"
date: 2019-03-30T13:03:10+08:00
draft: false
---

## 1.Pylint

> Pylint是Python代码的一个静态检查工具，它能够检测一系列的代码错误，代码坏味道和格式错误。

> Pylint使用的编码格式类似于PEP-8。

> 它的最新版本还提供代码复杂度的相关统计数据，并能打印相应报告。

> 不过在检查之前，Pylint需要先执行代码。

> 具体可以参考http://pylint.org



## 2. Pyflakes

> Pyflakes相对于Pylint而言出现的时间较晚，不同于Pylint的是，它不需要在检查之前执行代码来获取代码中的错误。

> Pyflakes不检查代码的格式错误，只检查逻辑错误。

> 具体可以参考http://launchpad.net/pyflakes



## 3. McCabe

> McCabe是一个脚本，根据McCabe指标检查代码复杂性并打印报告。

> 具体可以参考<https://pypi.org/project/mccabe/>



## 4. Pycodestyle

> Pycodestyle是一个按照PEP-8的部分内容检查Python代码的一个工具

> 这个工具之前叫PEP-8。

> 具体可以参考[https://github.com/pycqa/pycodestyle](https://github.com/PyCQA/pycodestyle)



## 5. Flake8

> Flake8封装了Pyflakes、McCabe和Pycodestyle工具，它可以执行这三个工具提供的检查

> 具体可以参考<https://github.com/pycqa/flake8>



## 6. Pychecker

> PyChecker是Python代码的静态分析工具，它能够帮助查找Python代码的bug，而且能够对代码的复杂度和格式等提出警告。

> PyChecker会导入所检查文件中包含的模块，检查导入是否正确，同时检查文件中的函数、类和方法等。

> 具体可以参考<https://pypi.org/project/PyChecker/>



## 7. Black

> Black 号称是不妥协的 Python 代码格式化工具。之所以成为“不妥协”是因为它检测到不符合规范的代码风格直接就帮你全部格式化好，根本不需要你确定，直接替你做好决定。而作为回报，Black 提供了快速的速度。



> Black 通过产生最小的差异来更快地进行代码审查。



> Black 的使用非常简单，安装成功后，和其他系统命令一样使用，只需在 black 命令后面指定需要格式化的文件或者目录即可。

> 具体可以参考<https://atom.io/packages/python-black>