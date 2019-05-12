---
title: "用 replace 方法修改 mysql 存储的数据"
date: 2019-05-11T16:27:04+09:00
draft: false
tags: ["kingkoma","mysql"]
---

> 描述：

`数据库`存储的数据与`前端`传过来的数据格式不一定统一

> 解决：

用　replace 方法解决这个问题

> 例子：

- 数据库表里的电话号码：</br>
PHONE_NUMBER: xxx-xxxx-xxxx

- 前端传过来的电话号码：</br>
phoneNumber: xxxxxxxxxxx

 另要注意，当语句里用到 OR 时要用括号给括起来
``` mysql
SELECT * FROM table WHERE 1 = 1 AND （REPLACE(PHONE_NUMBER, "-", "") = phoneNumber OR PHONE_NUMBER = phoneNumber）;
```

