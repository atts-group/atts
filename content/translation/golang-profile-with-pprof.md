---
title: "Golang Profile With Pprof"
date: 2019-04-21T21:43:08+08:00
draft: false
---

原文链接：[Profile your golang benchmark with pprof](https://medium.com/@felipedutratine/profile-your-benchmark-with-pprof-fb7070ee1a94)

golang 自带的工具非常有用，我们可以使用 go 自带的 pprof 来做性能分析。

我们用 [Dave Cheney](https://dave.cheney.net/2013/06/30/how-to-write-benchmarks-in-go) 当中的例子

```go
package bench
import "testing"
func Fib(n int) int {
    if n < 2 {
      return n
    }
    return Fib(n-1) + Fib(n-2)
}
func BenchmarkFib10(b *testing.B) {
    // run the Fib function b.N times
    for n := 0; n < b.N; n++ {
      Fib(10)
    }
}
```

在我们的终端中：

```bash
go test -bench=. -benchmem -cpuprofile profile.out
```

我们同样可以做内存分析：

```bash
go test -bench=. -benchmem -memprofile memprofile.out -cpuprofile profile.out
```

然后我们可以使用 pprof 做分析：

```
go tool pprof profile.out
File: bench.test
Type: cpu
Time: Apr 5, 2018 at 4:27pm (EDT)
Duration: 2s, Total samples = 1.85s (92.40%)
Entering interactive mode (type "help" for commands, "o" for options)
(pprof) top
Showing nodes accounting for 1.85s, 100% of 1.85s total
      flat  flat%   sum%        cum   cum%
     1.85s   100%   100%      1.85s   100%  bench.Fib
         0     0%   100%      1.85s   100%  bench.BenchmarkFib10
         0     0%   100%      1.85s   100%  testing.(*B).launch
         0     0%   100%      1.85s   100%  testing.(*B).runN
```

在这个例子里，我用的是 profile.out，但是你也可以使用 memprofile.out 做同样的事情。

然后你也可以使用 list 命令来检查函数当中哪些地方很占时间。

```
(pprof) list Fib
     1.84s      2.75s (flat, cum) 148.65% of Total
         .          .      1:package bench
         .          .      2:
         .          .      3:import "testing"
         .          .      4:
     530ms      530ms      5:func Fib(n int) int {
     260ms      260ms      6:   if n < 2 {
     130ms      130ms      7:           return n
         .          .      8:   }
     920ms      1.83s      9:   return Fib(n-1) + Fib(n-2)
         .          .     10:}
```

或者通过 web 命令生成一张图(也可以使用 png、pdf，都支持的)

```
(pprof) web
```

![img](https://cdn-images-1.medium.com/max/800/1*jWEWWVzUk18Jl1CDTzuROw.png)

**PS：**

如果你只想运行基准测试，不想运行程序中的单元测试，你可以执行下面的命令：

```bash
go test -bench=. -run=^$ . -cpuprofile profile.out
```

使用 `-run=^$` 表示运行所有符合正则表达是的测试用例，但是 `^$` 不会匹配到任何测试。所以它只运行基准测试。