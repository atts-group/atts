---
title: "Go Context 在 HTTP 传播"
date: 2019-03-31T22:12:54+08:00
draft: false
---

Go 1.7 引入了一个内置的 context 类型，在系统中可以使用 Context 来传递元数据，例如不同函数或者不同线程甚至进程的传递 Request ID。

Go 将 Context 包引入标准库以统一 context 的使用。在此之前每个框架或者库都有自己的 context 。它们之间还无法兼容，导致了碎片化，最终在各处 context 的传播上就有不少的麻烦。

虽然在同一个处理过程中有一个通用的 context 传播机制是非常有用的，但是 Go 的 Context 包并没有提供该功能。就像上面描述的，context 会在网络中被不同的处理过程传递。例如在多服务架构中，一个请求往往会在多个地方被处理 (多个微服务，消息队列，数据库等)，直到最后响应给用户。能够在多个处理过程中传递 context 显得尤为重要。

如果你要在 HTTP 中传播 context ，需要你对 context 进行序列化处理。类似的，在接收端也要解析，同时把值放入当前的 context 中。假设我们希望在 context 中传递 request ID。

```go
package request
import "context"

// WithID 把 request ID 放入当前的 context 中
func WithID(ctx context.Context, id string) context.Context {
	return context.WithValue(ctx, contextIDKey, id)
}

// IDFromContext 返回从 context 中获取的 request ID
// 如果 context 中没有定义就返回空值
func IDFromContext(ctx context.Context) string {
	v := ctx.Value(contextIDKey)
    if v == nil {
    		return ""
    }
	return v.(string)
}

type contextIDType struct{}

var contextIDKey = &contextIDType{}

// ...
```

 WithID 允许我们把 request ID 设置到 context 中，IDFromContext 可以从 context 中读取 request ID。一旦我们有在多个处理过程，就需要手动把到 context 设置到传输中，同时在接受端解析然后写入 context。

在 HTTP 中我们可以从 header 中获取 request ID。大多数的 context 都可以通过 header 来传播。一些传输层可能不支持 headers 或者 headers 不是传输标准 (例如有大小限制或者缺少加密措施)。在这种情况下，由具体实现来决定如何传递上下文。

## HTTP 传播

目前没有直接的方法可以在 HTTP reuqest 中的值放入 context 中。由于无法遍历出 context 的值，因此也无法一次性转换整个上下文。

```go
const requestIDHeader = "request-id"

// Transport 把 request context 序列化到 request headers
type Transport struct {
    // Base 是构建请求的真实 round tripper
    // 如果没有被设置，默认使用 http.DefaultTransport
	Base http.RoundTripper
}


// RoundTrip 转换 request context 到 headers 中
// 同时构建请求
func (t *Transport) RoundTrip(r *http.Request) (*http.Response, error) {
	r = cloneReq(r) // per RoundTrip interface enforces
    
	rid := request.IDFromContext(r.Context())
    if rid != "" {
    	r.Header.Add(requestIDHeader, rid)
    }
    
    base := t.Base
    if base == nil {
    	base = http.DefaultTransport
    }
    return base.RoundTrip(r)
}
```

在上面的 Transport 中，如果 request ID 存在就会被当做 "request-id" header 进行传递。

类似的方法可以解析请求，把  "request-id" 放入请求的上下文中。

```go
// Handler 从 request headers 反序列化到 request context 中
type Handler struct {
    // Base 是完成反序列化调用的真实方法
    Base http.Handler
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    rid := r.Header.Get(requestIDHeader)
    if rid != "" {
        r = r.WithContext(request.WithID(r.Context(), rid))
    }
    h.Base.ServeHTTP(w, r)
}
```

为了继续传播 context ，请确保在你的方法中把当前的 context 传递到下一个 request 。传入的 context 将会随着 request 传播到 https://endpoint。

```go
http.Handle("/", &Handler{
    Base: http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        req, _ := http.NewRequest("GET", "https://endpoint", nil)
        // 传播当前的 context
        req = req.WithContext(r.Context()) 
        // Make the request.
    }),
})
```

