---
title: "更详细的 Go 性能测试"
date: 2019-04-07T20:22:05+08:00
draft: false
---

我一直在优化我的 go 代码并且一直优化我的性能测试方案。

让我们先看一个简单的例子：

```go
func BenchmarkReport(b *testing.B) {
    runtime.GC()
    for i := 0; i < b.N; i++ {
        r := fmt.Sprintf("hello, world %d", 123)
        runtime.KeepAlive(r)
    }
}
```

执行 `go test -beach .` 会看到这样子的结果：

```
BenchmarkReport-32      20000000               107 ns/op
```

这可能可以初略的估计性能表现，但是彻底的优化需要更详细的结果。

将所有的内容压缩成一个数字必然是简单的。

![](https://static.zhengxiaowai.cc/2019-04-05-111610.png)

让我向你们介绍我写的 **hrtime** 包，以便于获取更详细的性能测试结果。

## 直方图

第一个推荐使用的是 `hrtime.NewBeachmark`，重写上面的简单例子：

```go
func main() {
    bench := hrtime.NewBenchmark(20000000)
    for bench.Next() {
        r := fmt.Sprintf("hello, world %d", 123)
        runtime.KeepAlive(r)
    }
    fmt.Println(bench.Histogram(10))
}
```

它会输出：

```go
  avg 372ns;  min 300ns;  p50 400ns;  max 295µs;
  p90 400ns;  p99 500ns;  p999 1.8µs;  p9999 4.3µs;
      300ns [ 7332554] ███████████████████████
      400ns [12535735] ████████████████████████████████████████
      600ns [   18955]
      800ns [    2322]
        1µs [   20413]
      1.2µs [   34854]
      1.4µs [   25096]
      1.6µs [   10009]
      1.8µs [    4688]
        2µs+[   15374]
```

我们可以看出 P99 是 500ns，表示的是 1% 的测试超过 500ns，我们可以分配更小的字符串来优化：

```go
func main() {
    bench := hrtime.NewBenchmark(20000000)
    var back [1024]byte
    for bench.Next() {
        buffer := back[:0]
        buffer = append(buffer, []byte("hello, world ")...)
        buffer = strconv.AppendInt(buffer, 123, 10)
        runtime.KeepAlive(buffer)
    }
    fmt.Println(bench.Histogram(10))
}
```

结果如下：

```go
  avg 267ns;  min 200ns;  p50 300ns;  max 216µs;
  p90 300ns;  p99 300ns;  p999 1.1µs;  p9999 3.6µs;
      200ns [ 7211285] ██████████████████████▌
      300ns [12658260] ████████████████████████████████████████
      400ns [   81076]
      500ns [    3226]
      600ns [     343]
      700ns [     136]
      800ns [     729]
      900ns [    8108]
        1µs [   15436]
      1.1µs+[   21401]
```

现在可以看到 99% 的测试已经从 500ns 降到了 300ns。

如果你眼神犀利，可能已经注意到 go beachmark 给出了 107ns/op 但是 hrtime 给了 372ns/op。
这是获取更多测试信息的副作用，他们总是会有开销的。最终结果包括这种开销。

## Stopwatch

有时候我们还行测试并发操作，这时候可能需要 Stopwatch。

假如你想在测试一个多竞争 channel 的持续时间。当然这是一个认为的例子，大致描述了如何从一个 goroutine 开始在另一个 goroutine 结束并且打印结果。

```go
func main() {
    const numberOfExperiments = 1000
    bench := hrtime.NewStopwatch(numberOfExperiments)
    ch := make(chan int32, 10)
    wait := make(chan struct{})
    // start senders
    for i := 0; i < numberOfExperiments; i++ {
        go func() {
            <-wait
            ch <- bench.Start()
        }()
    }
    // start one receiver
    go func() {
        for lap := range ch {
            bench.Stop(lap)
        }
    }()
    // wait for all goroutines to be created
    time.Sleep(time.Second)
    // release all goroutines at the same time
    close(wait)
    // wait for all measurements to be completed
    bench.Wait()
    fmt.Println(bench.Histogram(10))
}
```
## hrtesting

当然重写所有的测试用例是不现实的。为此有 `github.com/loov/hrtime/hrtesting` 为测试提供 `testing.B`。

```go
func BenchmarkReport(b *testing.B) {
    bench := hrtesting.NewBenchmark(b)
    defer bench.Report()
    for bench.Next() {
        r := fmt.Sprintf("hello, world %d", 123)
        runtime.KeepAlive(r)
    }
}
```

会打印出 P50、P90、P99：

```
BenchmarkReport-32               3000000               427 ns/op
--- BENCH: BenchmarkReport-32
    benchmark_old.go:11: 24.5µs₅₀ 24.5µs₉₀ 24.5µs₉₉ N=1
    benchmark_old.go:11:  400ns₅₀  500ns₉₀ 12.8µs₉₉ N=100
    benchmark_old.go:11:  400ns₅₀  500ns₉₀  500ns₉₉ N=10000
    benchmark_old.go:11:  400ns₅₀  500ns₉₀  600ns₉₉ N=1000000
    benchmark_old.go:11:  400ns₅₀  500ns₉₀  500ns₉₉ N=3000000
```

在 Go 1.12 中将会打印出所有的 Beachmark 而不是最后一个，但是在 Go 1.13 中可以输出的更好：

```
BenchmarkReport-32   3174566  379 ns/op  400 ns/p50  400 ns/p90 ...
```

获得的结果也可以和 beachstat 进行比较。

## hrpolt

最后载介绍一下 `github.com/loov/hrtime/hrplot`，使用我实验性质的绘图包，我决定添加一种方便的方法来绘制测试结果。

```go
func BenchmarkReport(b *testing.B) {
    bench := hrtesting.NewBenchmark(b)
    defer bench.Report()
    defer hrplot.All("all.svg", bench)

    runtime.GC()
    for bench.Next() {
        r := fmt.Sprintf("hello, world %d", 123)
        runtime.KeepAlive(r)
    }
}
```

将会创建一个 SVG 文件 `all.svg`。其中包括线性图，显示了每次迭代所花费的时间；第二个就是密度图，显示了测量时间的分布图，以及最后一个百分位的详情。

![](https://static.zhengxiaowai.cc/2019-04-05-122821.jpg)

## Conclusion

性能优化很有趣，但是有更好的根据可以变得更加有趣。

去尝试 github.com/loov/hrtime 让我知道你更多的想法。
