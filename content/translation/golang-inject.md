---
title: "「译」Golang 使用高阶函数实现依赖注入"
date: 2019-04-29T00:05:35+08:00
draft: false
---

> [原文地址](https://stein.wtf/posts/2019-03-12/inject/)

你可以在 github.com/steinfletcher/func-dependency-injection-go 找到完整的代码。这个例子包含了一个完整的 REST 的 HTTP 服务器。

## 简介

在这篇文章中介绍了一种在 go 的实现依赖注入的方法——使用高阶函数和闭包

下面是一个返回用户 profile 的接口。

```go
func GetUserProfile(id string) UserProfile {
    rows, err := db.Query("SELECT ...")
    ...
    return profileText
}
```

我们希望将处理用户数据的代码和访问数据库的代码分开。在这个例子中我们希望对业务逻辑代码进行单元测试，同时为访问数据库提供 mock。让我们把这些问题分开，以满足单一原则。

```go
// domain layer function containing any business logic or mapping code
func GetUserProfile(id string) User {
    ...
}

// database access layer function
func SelectUserByID(id string) UserProfile {
    ...
}
```

我们可以复用 `SelectUserByID` 函数在其他接口中。为了要对 `GetUserProfile` 进行单元测试和 mock 访问数据库，我们需要一种把 `SelectUserByID` 注入到 `GetUserProfile` 中的方法。一种方法利用 `go` 中对函数定义的类型别名实现。

## Type aliases

使 `GetUserProfile` 依赖于一种抽象意味着我们可以在测试中注入 mock 的数据库访问。在 `go` 中实现这种操作的两中方法是 interface 机制或者 type alias。type alias 比较简单，不需要生成 struct，我们将这两个函数定义成另一种类型。

```go
type SelectUserByID func(id string) User

type GetUserProfile func(id string) UserProfile

func NewGetUserProfile(selectUser SelectUserByID) GetUserProfile {
    return func(id string) string {
        user := selectUser(id)
        return user.ProfileText
    }
}

func selectUser(id string) User {
    ...
    return User{ProfileText: userRow.ProfileText}
}
```

`SelectUserByID` 是一个函数通过参数 user ID 返回 User 结构。我们不需要定义它的实现。`NewGetUserProfile` 是一个工厂方法依赖于参数 `selectUser`，然后返回一个可调用的函数。这种模式使用了闭包，让内部的函数可以从外部的函数中获取依赖项。闭包可以捕获上下文中变量和常量，这被称为对那些变量或者常量的 `closing over`。

然后我们可以像这样使用这些函数

```go
// wire dependencies somewhere in the application
getUser := NewGetUserProfile(selectUser)

user := getUser("1234")
```

## 另一种观点

如果你熟悉像 Java 这样的语言，在创建累的时候将依赖类注入构造函数，然后在调用方法的时候调用依赖的方法。这些方法不存在功能上的差别 —— 你认为这是一个拥有单个抽象方法的函数 type alias，在 Java 中在构造函数中注入依赖。

```java
interface DB {
    User SelectUser(String id)
}

public class UserService {
    private final DB db;
    
    public UserService(DB db) { // inject dependency into constructor
        this.DB = db;
    }

    public UserProfile getUserProfile(String id) { // access method
        User user = this.DB.SelectUser(id);
        ...
        return userProfile;
    }
}
```

在 `go` 使用高阶函数等价的是

```go
type SelectUser func(id string) User

type GetUserProfile func(id string) UserProfile

func NewGetUserProfile(selectUser SelectUser) { // factory method to inject dependency
    return func(id string) UserProfile { // access method
        user := selectUser(id)
        ...
        return userProfile        
    } 
}
```

## 测试

我们现在可以对接口进行单元测试，为数据库访问提供 mock。

```go
func TestGetUserProfile(t *testing.T) {
    selectUserMock := func(id string) User {
        return User{name: "jan"}
    }
    getUser := NewGetUserProfile(selectUserMock)

    user := getUser("12345")

    assert.Equal(t, UserProfile{ID: "12345", Name: "jan"}, user)
}
```

你可以在 https://github.com/steinfletcher/func-dependency-injection-go 上找到更全面的代码示例。该示例包含一个 REST 的 http 服务器。