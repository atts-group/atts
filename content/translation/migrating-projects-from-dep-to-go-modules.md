---
title: "把项目从 Dep 迁移到 Go Modules"
date: 2019-03-24T23:48:57+08:00
draft: false
---

[原文地址](http://elliot.land/post/migrating-projects-from-dep-to-go-modules)

Go Modules 是 Go 管理的未来方向。已经在 Go 1.11 中可以试用，将会是 Go 1.13 中的默认行为。

我不会在这篇文章中描述包管理工具的工作流程。我会主要讨论的是如何把现有的项目中 dep 迁移的 Go Module。

在我的实例中，我会使用一个私有的仓库地址 `github.com/kuinta/luigi` ，它是使用 Go 语言编写，在好几个项目中被使用，是一个绝佳的候选人。

首先，我们需要初始化 Module：

```shell
cd github.com/kounta/luigi
go mod init github.com/kounta/luigi
```
完成后只会有两行输出：

```shell
go: create now go.mod: module github.com/kounta/luigi
go: copying requirments from Gopkg.lock
```

是的，这样就对了。这样就已经完成从 `dep` 迁移了。

现在你只要看一眼新生成的文件 `go.mod` 就像下面这样：

```
module github.com/kounta/luigi

go 1.12

require (
   github.com/elliotchance/tf v1.5.0
   github.com/gin-gonic/gin v1.3.0
   github.com/go-redis/redis v6.15.0+incompatible
)
```

其实在 `require` 中还有更多的内容，为了保持整洁我把他们删除了。

就像 `dep` 区分 `toml` 和 `lock` 文件一样。我们需要生成 `go.sum` 文件，只要执行：

```shell
go build
```

现在你可以删除 `Gopkg.lock` 和 `Gopkg.toml` 文件，然后提交 `go.mod` 和 `go.sum` 文件。

## Travis CI

如果你使用 Travis CI，你需要在 Go 1.13 之前通过设置环境变量来启用该功能。

```
GO111MODULE=on
```

## 私有仓库

如果你要导入私有仓库，你可以会发现这个错误：

```
invalid module version "v6.5.0": unknown revision v6.5.0
```

这是一个误导。它真正想说的，无法识别这个 URL (在这里是指的是 github.com)。无法找到这个仓库是因为 Github 没有权限确认仓库的存在。

修复这个问题也很简单：

1. 登录 Github 账号，然后到 Setting ->  Personal access tokens
2. 创建一个有访问私有仓库权限的 token
3. 然后执行

```shell
export GITHUB_TOKEN=xxx

git config --global url."https://${GITHUB_TOKEN}:x-oauth-basic@github.com/kounta".insteadOf "https://github.com/kounta"
```