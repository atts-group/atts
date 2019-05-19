---
title: "Goroutine 泄露——被遗弃的接受者"
date: 2019-05-12T21:42:51+08:00
draft: false
---

[原文地址](https://www.ardanlabs.com/blog/2018/12/goroutine-leaks-the-abandoned-receivers.html)

## 简介

Goroutine 泄露在 Go 编程中是很常见的问题。在我的前一篇文章中，我介绍了 Goroutine 泄露的问题，并提供一个许多开发者都会犯的错误。这篇文章继续前文，讨论另一个关于 Goroutine 泄露的场景。

## 被遗弃接收者的泄露

**在这个例子中，你将可以看到多个 Goroutine 被阻塞，等待永远不会被发送的值**

文章中的这个程序启动了多个 Goroutine 来处理文件中一批数据。每个 Goroutine 从输入 channel 接受值，然后通过输出 channel 发送新值。

**Listing 1**

https://play.golang.org/p/Jtpla_UvrmN

```go
35 // processRecords is given a slice of values such as lines
36 // from a file. The order of these values is not important
37 // so the function can start multiple workers to perform some
38 // processing on each record then feed the results back.
39 func processRecords(records []string) {
40 
41     // Load all of the records into the input channel. It is
42     // buffered with just enough capacity to hold all of the
43     // records so it will not block.
44 
45     total := len(records)
46     input := make(chan string, total)
47     for _, record := range records {
48         input <- record
49     }
50     // close(input) // What if we forget to close the channel?
51 
52     // Start a pool of workers to process input and send
53     // results to output. Base the size of the worker pool on
54     // the number of logical CPUs available.
55 
56     output := make(chan string, total)
57     workers := runtime.NumCPU()
58     for i := 0; i < workers; i++ {
59         go worker(i, input, output)
60     }
61 
62     // Receive from output the expected number of times. If 10
63     // records went in then 10 will come out.
64 
65     for i := 0; i < total; i++ {
66         result := <-output
67         fmt.Printf("[result  ]: output %s\n", result)
68     }
69 }
70 
71 // worker is the work the program wants to do concurrently.
72 // This is a blog post so all the workers do is capitalize a
73 // string but imagine they are doing something important.
74 //
75 // Each goroutine can't know how many records it will get so
76 // it must use the range keyword to receive in a loop.
77 func worker(id int, input <-chan string, output chan<- string) {
78     for v := range input {
79         fmt.Printf("[worker %d]: input %s\n", id, v)
80         output <- strings.ToUpper(v)
81     }
82     fmt.Printf("[worker %d]: shutting down\n", id)
83 }
```

在第 39 行定义了一个名为 processRecords 的函数。该函数接收一个 string 的 slice 值。在第 46 行创建了一个名为 `input` 缓存的 channel。在 47 和 48 行循环把 slice 中的 string 值发送到 channel 中。创建的输入通道具有足够的容量来保存 slice 中的每个值，因此在 48 行中的发送都不会阻塞。这个 channel 作为一个 pipeline 分布在多个 Groutine 中。

接下来的 56 到 60 行，程序创建了一个 Goroutine 池来从 pipeline 中接收值。56 行创建了一个名为 `output` 的缓存 channel，每个 Goroutine 都会把值发送到这个 channel。57 行到 59 行用 `worker` 函数创建等同于逻辑 CPU 数量的 Goroutine，传入循环变量 i、`input` channel、`output` channel。

`woker` 函数被定义在第 77 行，函数的签名定义 `input` 为 `<- chan string`，意味着这是一个只读 channel；另一个参数 `output` 是 `chan<- string`，意味着是只写 channel。

在这个函数的 78 行中，Goroutine 使用 `range` 循环从 `input` 中接收值，使用 `range` 从 channel 中接收值直到 channel 被关闭同时再也读不出值为止。每次循环中接收到的值赋给迭代变量 `v`，同时在 79 行打印出来。然后第 80 行，`worker` 函数将 `v` 传给 `strings.ToUpper` 函数返回一个新的 `string`。这个 worker 立即把这个 string 发送到 `output` channel 中。

回到 `processRecords` 函数中，现在已经执行到第 65 行。正在运行着一个循环，直到从 `output` channel 接收并处理了所有值。在 66 行 `processRecords` 函数等待接收来自另一个 Goroutine 的值，接收到的值在 67 行打印出来。当该程序接收到每个 input 值，他会退出循环并终止改功能。

运行这个程序打印转换后的数据，看起来视乎很正常的工作，其实正在泄露多个 Goroutine，实际上程序永远不会到达 82 行，这行打印这个 worker 已经。及时 `processRecords` 函数已经返回，每个 worker 的 Goroutine 仍然在 78 行等待 input 中的值。实际上 channel 的接收者一直等待到 channel 关闭并且 channel 为空。这个问题就在于程序从来没有去关闭 channel。


## FIX：通知完成

修复这个泄露只需要一行代码 `close(input)`。关闭 channel 是表示 “不在发送数据” 的一种方式。关闭 channel 最合适的地方应该是在第 50 行发送完最后一个值之后，如 Listing 2 所示：

**Listing 2**

https://play.golang.org/p/QNsxbT0eIay

```go
45     total := len(records)
46     input := make(chan string, total)
47     for _, record := range records {
48         input <- record
49     }
50     close(input)
```

关闭一个缓冲 channel 后，channal 中的值仍然是有效的，channel 被仅仅是关闭发送而不是接收。worker Goroutine 运行 `range input` 将会得到缓冲 channel 已经被关闭的信号，这可以让 worker 在程序退出前终止循环退出。

## 结论

正如前一篇文章中所提到的，Go 中使用 Goroutine 变得简单，但是你有责任好好的使用它们。在这篇文章中我展示了另一个使用 Goroutine 很容易犯的错误。还是有更多使用 Goroutine 并发泄露的陷阱。未来的文章我们会继续这些陷阱。和以前一样，我将继续重复这一建议 “[永远不要启动一个你不知道如何停止的 Goroutine](https://dave.cheney.net/2016/12/22/never-start-a-goroutine-without-knowing-how-it-will-stop)”。

**并发是一种有用的工具，但必须谨慎使用。**
