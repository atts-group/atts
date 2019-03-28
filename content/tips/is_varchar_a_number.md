---
title: "[Mysql]Is Varchar a Number?"
date: 2019-03-24T22:38:28+08:00
draft: false
---

判断 MySQL 里一个 varchar 字段的内容是否为数字：

```mysql
select * from table_name where length(0+name) = length(name);
```

