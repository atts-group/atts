---
title: "[Go]Exercise of a Tour of Go"
date: 2019-03-24T22:58:30+08:00
draft: false
---

这周学了学 golang，做个记录

学习网站：https://tour.golang.org

对应的中文版：https://tour.go-zh.org

这周主要学习内容是刷了一遍上面这个教程，虽然够官方，但讲解并不细致，很多需要自行 google

顺便，第一次打开教程和在线运行代码都需要科学上网，但打开一次后所有内容就都被缓存下来了，火车上都可以翻页学习。也不方便的话可以用中文版，或者本地安装，教程上也都有说。

## 知识点记录

#### go 项目结构

1. 必须要有 package
2. import 用的是字符串
3. 首字母大写的是导出名(exported name)，可以被别的包使用，有点类似于 python 的 __all__
4. 只有 `package main` 可以被直接运行
5. 运行入口 `func main() {}`

#### 基础部件

1. 函数以 `func` 定义，每个参数后必须带类型，必须规定返回值类型，可返回多个值，返回值可预先命名，函数是第一类对象(first class object)
2. 变量以 `var` 定义，定义时必须规定类型，可在定义时赋值，函数内的变量可以不用 `var` 而用 `:=` 来[定义+赋值](此时可不明确指定类型)
3. 常量以 `const` 定义，不能使用 `:=` 语法，仅支持基础类型
4. 基础类型是 bool, string 和各种数字，byte = uint8, tune = int32
5. 类似于 null, None 的，是 `nil` 

#### 语法

1. if 不需要小括号，但必须有大括号；if 中可以有一条定义变量的语句，此变量仅在 if 和 else 中可用
2. for 是唯一的循环结构，用法基本等同于 Java 里的 for + while，同样没有小括号，但有大括号，`for {}` 是无限循环
3. switch 的每个 case 后等同于自带 break，但可以用 `fallthrough` 直接跳过判断而执行下一条 case 内的语句；没有匹配到任何一个 case 时会运行 default 里的内容；没有条件的 switch 可以便于改写 if-elseif-else
4. defer 可将其后的函数推迟到外层函数返回之后再执行，多个 defer 会被压入栈中，后进先出执行
5. select-case 语句可同时等待多个 chan，并在所有准备好的 case 中随机选一个执行
6. for-range 可以对 array, map, slice, string, chan 进行遍历
7. make 可用来为 slice, map, chan 类型分配内存及初始化对象，返回一个引用，对这三种类型使用make时，后续参数含义均不同

#### 其他数据类型

1. pointer 类似 C，没有指针运算
2. struct 内的字段使用 `.` 访问
3. array 必须有长度，且内部所有值类型必须相同
4. slice 类似数组的引用，可动态调整长度，有 len 和 cap 两个属性，零值是 nil，用 append 函数可以追加元素及自动扩展 cap
5. map 在获取值的时候可以用 `value, ok = m[key]` 来校验 key 是否存在
6. method 与 function 略有不同，需要有一个 receiver，若 receiver 为指针，则可以在方法中修改其指向的值。只能为定义在当前包的类型定义 method
7. interface 类型被实现时无需显示说明，任何类型只要实现了其所有方法就认为其实现了此接口，没有 `implements` 关键字；可以用空接口来接收任意值 `interface{}`
8. interface value 是一个tuple(value, type)，可以用 `t, i = i.(T)` 来校验类型，switch 中可以用 `v := i.(type)` 来判断其类型
9. channel 用来在 goroutines 直接传递信息，被 close 后可以用 for-range 遍历
10. 常见 interface: stringer, error, reader, writer

#### goroutine

1. 用 `go` 来启动一个 goroutine
2. 用 chan 来在不同 goroutine 之间交流
3. select-case 语句可以同时等待多个 chan，并在所有准备好的 case 中随机选一个运行
4. sync.Mutex 互斥锁可用来保证多个 goroutine 中每次只有一个能够访问共享的变量

#### 其他规则

1. 所有的大括号里，前括号不允许单独成一行
2. 推荐使用 tab 而非空格
3. 没有 class 概念，用 struct + method 实现
4. 变量定义了就必须要使用，否则通不过编译

---

A Tour of Go 里的内容大概就这些，可能还有些遗漏的细节，我也不打算再去补充上了

这里还提供了 11 个练习，我也顺着做了过来，感觉就跟上学时的课后习题一样，熟悉的感觉让人感动

我的解答以及相关内容放到了 [WokoLiu/go-tour-exercise](https://github.com/WokoLiu/go-tour-exercise)

如果有朋友要学 golang 的话，希望能有些帮助



