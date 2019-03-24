---
title: "Go tool pptof"
date: 2019-03-24T23:50:03+08:00
draft: false
---

使用 `go tool pptof` 可以 debug 程序

需要在程序中先 import

```golang
import _ "net/http/pprof"
```

然后启动一个 goroutine 用于远程访问

```golang
go func() {
	log.Println(http.ListenAndServe("localhost:6060", nil))
}()
```

最后我们就可使用 http 抓取一些关键指标

- go tool pprof http://localhost:6060/debug/pprof/heap
- go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
- go tool pprof http://localhost:6060/debug/pprof/block
- wget http://localhost:6060/debug/pprof/trace?seconds=5
- go tool pprof http://localhost:6060/debug/pprof/mutex
