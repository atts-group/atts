---
title: "「译」Python 项目应该都有什么？"
date: 2019-04-14T21:59:43+08:00
draft: false
---


>   [原文地址](https://vladcalin.github.io/what-every-python-project-should-have.html#what-every-python-project-should-have)

Python 语言在过去的几年有着突飞猛进的发展，社区也在快速发展。在发展过程中，社区中出现了许多工具保持着资源的结构性和可获取性。在这篇文章中，我将提供一个简短列表，让每个 Python 项目中都具有可访问性和可维护性。

## requirements.txt

首先， `requirements.txt` 在安装项目时候是十分重要的，通常是一个纯文本文件，通过 `pip` 安装，每行一个项目的依赖。

真是简单又实用。

你也可以有多个用于不同目的 `requirements.txt`。例如，`requirements.txt` 是让项目正常启动的依赖，`requirements_dev.txt` 是用于开发模式的依赖，`requirements_docs.txt` 是生成文档的依赖（像 `Sphinx` 需要的主题）

## setup.py

`setup.py` 文件在通过 `pip` 安装时候时候是十分重要的。编写容易，很好的可配置性并且可以处理很多事情，例如导入，项目元数据，更新源，安装依赖项等等。

可以查看 [setuptools](https://setuptools.readthedocs.io/en/latest/) 文档获取更多的信息。

## 正确的项目结构 

项目结构至关重要。有了一个组织良好的结构，它会更容易组织的东西，找到某些源文件，并鼓励其他人贡献。

一个项目目录应具有类似的结构

```
root/
        docs/
        tests/
        mymodule/
        scripts/
        requirements.txt
        setup.py
        README
        LICENSE
```

当然，这不是组织项目的唯一方法，但这肯定是最常用的模板。

## 测试

单元测试对项目十分重要，可以保证代码的稳定性。我推荐 `unittest` 模块，因为它是内置的，并且足够灵活，完成正确工作。

还有其他可用于测试项目的库，例如 `test.py` 或 `nose`。

## 文档

如果你开发一个项目，我确信你不只是为你自己写。其他人也要必须知道如何使用你的项目。即使你只是为自己编写的项目（虽然是开源的目的），但是一段时间后不开发后，你一定不会记得你的代码中发生的任何事情（或API）。

因此，为了实现可重用的代码，你应该：

-   设计一个简单的API，易于使用和记忆
-   API应该足够灵活，容易配置
-   记录相关使用例子
-   例子不要追求 100% ，最合适的是覆盖 80％ 。

为了充分的记录你的代码，你应该使用特殊的工具开完成文档工作，例如 `Sphinx` 或者 `mkdocs` ，所以你可以使用一个流行的标记语言（rst或markdown）来生成具有适当引用链接的漂亮的文档。

## 结论

在熟悉上述话题之后，一定能够生成符合社区标准的漂亮的结构化项目和库。不要忘记总是使用PEP-8！


