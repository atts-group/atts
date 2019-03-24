---
title: "golang 项目添加 debug 日志的小技巧"
date: 2019-03-24T18:57:21+08:00
draft: false
---

之所以整理这方面的小技巧，主要是 golang 的开源项目都是像 TiDB、etcd 这种偏低层的分布式服务。用 debugger 来跟踪代码是比较困难的，容易出错，而且还容易遇到坑，比如：有的 golang 版本无法正确输出调试信息，mac 上有些开源项目调试模式无法正常运行等等。用日志的话，更简单直接，不容易遇到坑。只不过，在查看变量、查看调用栈方面是真不太方便，下面几个小技巧能够弥补一些吧。

**查看调用栈**

可以使用 debug.Stack() 方法获取调用栈信息，比如像下面这样：

```go
log.Printf("stack of function xxx: %v", string(debug.Stack()))
```

不过，在日志中打印调用栈的方法还是要慎用，输出内容有时候太长了，影响日志的连贯性。可以考虑将栈信息再做一下处理，只保留最上面几层的调用信息。

**查看变量类型**

可以使用 `%T` 来查看变量类型，很多时候可以像下面这样简单查看一下变量的类型和取值：

```go
log.Printf("DEBUG: node type: %T, value: %v", n, n)
```

**使用 buffer 来收集要查看的变量信息**

有的时候，我们需要查看的不是一个变量，可能是多个变量或者一个复杂数据结构中的一部分字段，如果代码中没有给出满足需求的 String 方法的话，可以考虑用 buffer，自己一点点收集，就像下面这样：

```go
buf := bytes.NewBufferString()
fmt.Fprintf(buf, "a: %v, ", a)
fmt.Fprintf(buf, "b.child: %v, ", b)
fmt.Fprintf(buf, "c.parent: %v, ", c.parent)
log.Printf("%v", buf.String())
```

