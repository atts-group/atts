---
title: "golang 类型检测"
date: 2019-04-07T16:01:27+08:00
draft: false
---

类型直接转换：

```go
v := value.(*TypeA)
```

类型检测+转换：

```go
v, isTypeB := value.(*TypeB)
```

类型检测 + switch:

```go
switch v.(*Type) {
    case TypeA:
    	//...
    case TypeB:
    	//...
	default:
    	//...
}
```

