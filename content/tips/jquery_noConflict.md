---
title: "jQuery NoConflict()"
date: 2019-05-19T15:29:10+09:00
draft: false
tags: ["kingkoma", "jQuery"]
---

> 描述：

前段时间在调用 jQuery 表单验证的一个方法时发现怎么样都调不到。搜索了一下感觉是因为引进的其它第三方库里也用了其它版本的 jQuery。因为存在多个 jQuery 版本，无法识别。

> 解决：

jQuery.noConflict()

> 作用：

- 让渡 jQuery 控制权 <br>
- 也可以为 jQuery 变量规定新的名字

> 例子：

``` js
var j = jQuery.noConflict();
// 再用它来调用 jQuery 方法
j.validator.addMethod();
```