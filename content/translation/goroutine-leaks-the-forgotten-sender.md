---
title: "Goroutine 泄露——被遗忘的发送者"
date: 2019-05-06T00:05:52+08:00
draft: false
---

> [原文地址](https://www.ardanlabs.com/blog/2018/11/goroutine-leaks-the-forgotten-sender.html)

## 简介

并发编程允许开发者使用多个执行者去解决问题，这么做通常可以提高性能。并发并不意味着多个执行者同时运行，意味着执行的顺序从有序变成无序。在过去这种编程方法（并发编程）一般是由标准库或者第三方开发者为主导。

在 Go 中类似 Gotoutines 和 channels 的并发特性都是集成语言中同时减少乃至移除了对库的依赖，这就造成了在 Go 中写并发编程很容易的错觉。在决定使用并发的时候还是需要谨慎，如果没有正确的使用还是会带来一些特别的副作用和陷阱。如果你不小心，这些陷阱会产生复杂和令人厌恶的错误。

我将在这篇文章中讨论 Goroutine 泄露带来的陷阱。

## Goroutine 泄露

在内存管理方面 Go 屏蔽了许多细节。Go 编译器使用 [逃逸分析](https://www.ardanlabs.com/blog/2017/05/language-mechanics-on-escape-analysis.html) 确定变量在内存中的位置，在运行时使用 [GC](https://blog.golang.org/ismmkeynote) 来跟踪和管理堆的分配。虽然这些机制可以不能完全避免 [内存泄露](https://en.wikipedia.org/wiki/Memory_leak)，但是极大的降低了发生的概率。

一种常见的内存泄露类型就是 Goroutine 泄露。如果你启动了一个你希望它终止但是它不会终止的 Goroutine，这时候它已经泄露了。它会一直存在程序的生命周期中，并且无法释放为 Goroutine 分配的内存，这也是 “[Never start a goroutine without knowing how it will stop](https://dave.cheney.net/2016/12/22/never-start-a-goroutine-without-knowing-how-it-will-stop)” 建议的主要原因之一。

要说明基本的 Goroutine 泄露，看下面代码：

### Listing 1

https://play.golang.org/p/dsu3PARM24K

```go
31 // leak is a buggy function. It launches a goroutine that
32 // blocks receiving from a channel. Nothing will ever be
33 // sent on that channel and the channel is never closed so
34 // that goroutine will be blocked forever.
35 func leak() {
36     ch := make(chan int)
37 
38     go func() {
39         val := <-ch
40         fmt.Println("We received a value:", val)
41     }()
42 }
```

Listing 1 定义了一个函数命名为 `leak`。这个函数在第 36 行创建了一个通道，允许 Goroutines 传递整型数据。然后在 38 行创建了一个被阻塞的 Gotoutine，这是因为在 39 行一直在等待从 channel 中获取值。这个 Goroutine 一直在等待，但是 `leak` 函数返回了。程序的其他部分无法通过 channel 发送数据，Goroutine 在 39 行无限的等待，第 40 行的 `fmt.Println` 永远不会被调用。

在这个例子中，Goroutine 泄露很容易在 code review 中被发现。但是我无法列出 Goroutine 泄露的所有可能，但是这篇文章可以详细说可能遇到的一种 Goroutine 泄露：

## 被遗忘发送者的泄露

**这个泄露的例子，将会看到被无限阻塞的 Goroutine，等待发送值到 channel 中**

程序根据一些搜索词找到一条记录然后打印出来，该程序围绕着一个名为 `search` 函数构建：

### Listing 2

https://play.golang.org/p/o6_eMjxMVFv

```go
29 // search simulates a function that finds a record based
30 // on a search term. It takes 200ms to perform this work.
31 func search(term string) (string, error) {
32     time.Sleep(200 * time.Millisecond)
33     return "some value", nil
34 }
```

`search` 函数在 Listing 2 的第 31 行，mock 了一个模拟在数据库中查询或者 web 调用的长耗时操作，这里硬编码成 200 ms。

该程序调用 `search` 函数在 Listing 3 中显示如下：

### Listing 3

https://play.golang.org/p/o6_eMjxMVFv

```golang
17 // process is the work for the program. It finds a record
18 // then prints it.
19 func process(term string) error {
20     record, err := search(term)
21     if err != nil {
22         return err
23     }
24
25     fmt.Println("Received:", record)
26     return nil
27 }
```

在 Listing 3 的 19 行，定义了一个函数 `process`，这个函数接受一个 `string` 类型的参数作为搜索词。在 20 行，这个参数传入 `search` 函数返回一个结果或者错误。如果发生了错误，这个错误会在 22 行被返回，如果没有错误结果会在 25 行被打印出来。

对于某些应用程序，顺序调用搜索的延时是不能接受的。假设无法使搜索运行的更快，可以将 `process` 函数改成不由 `search` 函数影响的延迟。

为此可以使用 Goroutine，如下 Listing 4 所示。不幸的是，这是一次错误的尝试，造成了潜在的 Goroutine 泄露。

### Listing 4

https://play.golang.org/p/m0DHuchgX0A

```go
38 // result wraps the return values from search. It allows us
39 // to pass both values across a single channel.
40 type result struct {
41     record string
42     err    error
43 }
44 
45 // process is the work for the program. It finds a record
46 // then prints it. It fails if it takes more than 100ms.
47 func process(term string) error {
48 
49     // Create a context that will be canceled in 100ms.
50     ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
51     defer cancel()
52 
53     // Make a channel for the goroutine to report its result.
54     ch := make(chan result)
55 
56     // Launch a goroutine to find the record. Create a result
57     // from the returned values to send through the channel.
58     go func() {
59         record, err := search(term)
60         ch <- result{record, err}
61     }()
62 
63     // Block waiting to either receive from the goroutine's
64     // channel or for the context to be canceled.
65     select {
66     case <-ctx.Done():
67         return errors.New("search canceled")
68     case result := <-ch:
69         if result.err != nil {
70             return result.err
71         }
72         fmt.Println("Received:", result.record)
73         return nil
74     }
75 }
```

在 listing 4 的第 50 行，重写了 `process` 函数，创建了一个 `Context` 用于 100ms 后可以被 canceled。更多有关如何使用 `Context` 的内容可以参考 [golang.org blog post](https://blog.golang.org/context)。

在 54 行，改程序创建了一个无缓冲的 channel，允许 Goroutine 通过这个 channel 传送 `result` 类型的数据。第 58 行到 61 行是一个匿名的 Goroutine 函数。这个 Goroutine 调用 `search` 函数，尝试通过 channel 发送它的返回值在第 60 行。

在第 66 行的 case 中接受来自 `ctx.Done()` 的 channel。这个部分会在 `Context` 被 cancled（超过 100 ms 的时间）时被执行，如果该部分被执行 `process` 函数返回一个错误说明放弃在 67 行等待的 `search` 函数。

另外在 68 行的 case 接收来自 `ch` channel 的值，把值赋给变量 `result`。实现的和之前一样，在 69 行和 70 行检查错误，如果没有错误在 72 行打印结果，然后返回 `nil` 表示成功。

这次重构设置了 `process` 函数等待 `search` 函数的最长时间，可是在这个实现中埋下了 Goroutine 泄露的隐患。考虑一下 Goroutine 在代码中的运行情况，在第 60 行往 channel 中发送，此 channel 会阻塞发送直到另一个 Goroutine 做

好接收的准备。在超时的情况下，接受者将会停止从 Goroutine 接受的等待，继续运行。这将导致 Goroutine 永远被阻塞直到一个新的接受者出现，当然这个永远不会发送，这就发生了 Goroutine 泄露。

## Fix：多一点空间

解决这个泄露最简单的办法就是将 channel 从无缓存改成容量为 1 的缓存通道。

### Listing 5

https://play.golang.org/p/u3xtQ48G3qK

```go
53     // Make a channel for the goroutine to report its result.
54     // Give it capacity so sending doesn't block.
55     ch := make(chan result, 1)
```

现在 timeout 后，程序继续运行，搜索的 Goroutine 将结果发送到 channel 后返回。Goroutine 和 channel 的所占用的内存会很自然地被回收。

在 [The Behavior of Channels](https://www.ardanlabs.com/blog/2017/10/the-behavior-of-channels.html) 中 William Kennedy 提供几个有关 channel 行为的几个例子，同时说明了它们其中的原理。文章中最后一个例子 Listing 10 也提到类似的超时例子。阅读这篇文章获得更多有关使用缓冲 channel 和合适的大小的建议。

## 总结

虽然 Go 可以很容易使用 Goroutine，但是我们有责任更恰当的使用它们。在这篇文章中我举了一个错误使用 Goroutine 的例子。还有很多 Gotoutine 泄露的例子，以及在并发编程中还有可能碰到其他的陷阱。在以后的文章中，我将提供更多有关 Goroutine 泄漏和其他并发陷阱的例子。现在我会给你这个建议，任何时候你开始 Goroutine 你必须问自己：

- 它什么时候会终止？
- 什么会阻止它终止？

**并发是一种有用的工具，但必须谨慎使用。**