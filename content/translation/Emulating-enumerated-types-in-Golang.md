---
title: "实现 Golang 枚举类型"
date: 2019-04-21T21:53:14+08:00
draft: false
---

[原文地址](https://stein.wtf/posts/2019-04-16/enums/)
在这篇文章中，我们将介绍使用 go generate 和 abstract 语法树遍历生成强大的枚举类型。

这篇文章描述用于生成的 CLI，[完全的原代码](https://github.com/steinfletcher/gonum) 可以在 Github 上找到。

## Go 中惯用法

Go 语言实际上没有对枚举类型提供完成的支持。定义枚举类型的其中一种方法就是把一类相关变量定义成一种类型。Iota 可以用于定义连续的递增的整数常量。我们可以像这样定义一个 Color 类型。

https://play.golang.org/p/1Zib29yiuFy

```go
package main

import "fmt"

type Color int

const (
    Red Color = iota // 0
    Blue             // 1
)

func main() {
    var b1 Color = Red
    b1 = Red
    fmt.Println(b1) // prints 0

    var b2 Color = 1
    fmt.Println(b2 == Blue) // prints true

    var b3 Color
    b3 = 42
    fmt.Println(b3)  // prints 42
}
```

这种写法在 Go 代码中很常见，虽然这种方法很常用，但是有一些缺点。因为任何整数都可以给 Color 赋值，所以无法进行使用静态检查。

-   缺乏序列化——虽然这个不经常使用(开发者想要序列化这个整数，用于传参或者记录到数据库)
-   缺乏可读性的值——我们需要将 const 值转化成代码中显示的值

了解一种语言的习惯用法以及何时该打破这种习惯很重要。习惯用法往往会限制我们的 "视野"，这有时候恰恰是缺乏创造力的原因。

## 设计枚举类型

简洁是 Go 语言最重要的特性之一，其他语言的开发者可以很快上手。从另一方面看，可能会产生约束，比如缺乏泛型机制导致许多重复的代码。为了克服这些缺点，社区已经使用代码生成作为定义更强大和灵活类型的机制。

我们就使用这种方法来定义枚举类型，这种方法是使用生成的枚举作为 struct。我们还可以添加方法到 struct 中，struct 还支持 tag，这对于定义显示值和描述很有用。

```go
type ColorEnum struct {
    Red  string `enum:"RED"`
    Blue string `enum:"BLUE"`
}
```

现在我们需要做的是给每个字段生成结构的实例。

```go
var Red  = Color{name: "RED"}
var Blue = Color{name: "BLUE"}
```

添加方法到 Color struct 支持 JSON 编码/解码，我们实现 Marshaler 的 interface 支持 JSON 的编码。

```go
func (c Color) MarshalJSON() ([]byte, error) {
    return json.Marshal(c.name)
}
```

在这个类型序列化时候将会调用我们的自定义实现。同样我们可以实现 Unmarshaler 的 interface，这将让我们可以在代码中使用类型——这允许我们直接在 API 的数据传输对象上定义枚举。

```go
func (c *Color) UnmarshalJSON(b []byte) error {
    return json.Unmarshal(b, c.name)
}
```

我们还可以定义一些辅助的方法来生成显示的值。

```go
// ColorNames returns the displays values of all enum instances as a slice
func ColorNames() []string { ... }
```

我们也希望从字符串生成枚举实例，所以添加还需要添加这个方法。

```go
// NewColor generates a new Color from the given display value (name)
func NewColor(value string) (Color, error) { ... }
```

这些行为都是可扩展的，你可以添加其他方法来返回名字，通过显示 Error() string 来支持错误，并且通过 String() string 来支持 Stringer。

## 生成代码

### 遍历抽象语法树

在渲染模板之前，我们需要在源码中解析出 ColorEnum 类型。两种常用的方法是使用 `reflet` 包和 `ast` 包。我们需要扫描包级别的 struct。`ast` 包具有生成抽象语法树的能力——一种可表示 Go 源码的可遍历数据结构。我们可以遍历语法树并且匹配提供的类型，然后可以解析类型和定义的 struct tag，并用在构建模型已生成模板。我们先加载一个 go 包。

```go
cfg := &packages.Config{
    Mode:  packages.LoadSyntax,
    Tests: false,
}
pkgs, err := packages.Load(cfg, patterns...)
```

`pkgs` 变量中包含每个文件的语法树。使用 `ast.Inspect` 方法来遍历 AST。它需要为每个遇到的节点调用一个函数，我们以此遍历每个文件并且处理该文件的语法树。

```go
for _, file := range pkg.files {
...
    ast.Inspect(file.file, func(node ast.Node) bool {
        // ...handle node, check if it's something we are interested in
    })
}
```

使用者应该定义这个函数，然后按照感兴趣的 token 类型进行过滤。你可以通过节点上的此检查来过滤。

```go
node.Tok == token.STRUCT { ... }
```

在我们的例子中，通过定义了 "enmu:" 标签的 struct 进行过滤。我们只是处理了源码中每个标记，并根据遇到的数据类型进行模型（自定义 Go struct）的构建。

### 生成源代码

有许多生成代码的方法。`Stringer` 工具使用 `fmt` 包标准输出。虽然这很容易实现，但是随着代码的生成的扩张，这将会变得难以操作和调试。更合理的方式是使用 `text/template` 包，并且使用 Go 强大的模板库。它允许从模板中分离生成模型的逻辑，从而可以关注点分离和让代码易于推理。生成的类型定义可能如下所示：

```go
// {{.NewType}} is the enum that instances should be created from
type {{.NewType}} struct {
    name  string
}

// Enum instances
{{- range $e := .Fields}}
var {{.Value}} = {{$.NewType}}{name: "{{.Key}}"}
{{- end}}

... code to generate methods
```

然后我们可以使从模型中渲染出源码

```go
t, err := template.New(tmpl).Parse(tmpl)
if err != nil {
    log.Fatal("instance template parse error: ", err)
}

err = t.Execute(buf, model)
```

当我们在制作模板时候不要担心格式化的问题。`format` 包中有一个方法，它将源码作为参数并且返回格式化的 Go 代码，所以应该应该 Go 帮你处理这个问题。

```go
func Source(src []byte) ([]byte, error) { ... }
```

## 总结

在这篇中文，我们研究了一种通过解析 Go 源码来生成枚举类型的方法。此方法可以作为模板来构建所需要的源码和作为其他代码的生成器。我们使用 Go 的 `text/template` 库可以维护的方式呈现源码。

可以在 Github 阅读 [完整的代码](https://github.com/steinfletcher/gonum)。