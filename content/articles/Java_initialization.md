---
title: "JAVA初始化零碎知识点整理"
date: 2019-05-05T14:19:45+09:00
draft: false
---

**近期在学习Java语言，整理了部分初始化内容的知识点**

## 区分重载方法
当有多个方法拥有相同名字时，可以为每个方法设置不同的参数类型列表，从而实现方法的区分。

```java
public class Test{
    static f(String s, int i){
        System.out.println("String:" + s + ", int:" + i);
    }
    static f(String s, int i, int j){
        System.out.println("String:" + s + ", int:" + i + ", int:"+ j);
    }
}
```

同样可以通过改变参数顺序重载方法：
```java
public class Test{
    static f(String s, int i){
        System.out.println("String:" + s + ", int:" + i);
    }
    static f(int i, String s){
        System.out.println("String:" + s + ", int:" + i);
    }
}
```

## this关键字
1. **this：调用对象的引用**
```java
// Simple use of the "this" keyword
public class Leaf {
    private int i = 0;
    private Leaf increment(){
        i++;
        return this;  // 返回调用对象的引用
    }

    private void print(){
        System.out.println("i=" +i);
    }

    public static void main(String[] args) {
        Leaf x = new Leaf();
        x.increment().increment().increment().print();  //increment返回this，所以可以直接但语句多次调用方法
    }
}
```
2. **在构造器中调用构造器**
```java
// Calling constructors with "this"
public class Flower {
    private int petalCount = 8;
    private String s = "initial value";
    Flower(int petals){
        petalCount = petals;
        System.out.println("petalCount= "+petalCount);
    }
    
    Flower(String s, int petals){
        this(petals);  // 使用this调用构造器
        this.s = s;  // 使用this调用对象引用
        System.out.println("s: "+this.s+"petalCount: "+this.petalCount);
    }
}
```

## 可变参数列表
```java
class A{}

public class VarArgs {
    private static void printArray(Object... args){  // object... args 设置可变参数列表
        for(Object obj: args){
            System.out.println(obj+" ");
        }
        System.out.println();
    }

    public static void main(String[] args) {
        printArray(47, 3.14, 11.11);  // 直接传入参数
        printArray("one", "two", "three");
        printArray(new A(), new A(), new A());
    }
}
```
