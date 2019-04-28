---
title: "Mysql 里的 DATE 函数"
date: 2019-04-28T10:55:12+09:00
draft: false
---

这周发现目前在做的项目的一个地方，就是要读取特定时间的订单数据，发现这个数据并不准确。
后来找到原因是因为前端传过来的数据是“YYYY-MM-DD”模式，
但是数据库保存的数据是“YYYY-MM-DD HH:MM:SS”格式。

所以查询语句从
``` Mysql
SELECT * FROM XX WHERE ORDER_DATE BETWEEN ORDER_START_TIME AND ORDER_END_TIME； 
```
变成
``` Mysql
SELECT * FROM XX WHERE ORDER_DATE BETWEEN DATE(ORDER_START_TIME) AND DATE(ORDER_END_TIME)； 
```

不过，这样的话如果读取数据量大，会影响性能。假期后我应该会把数据在前端处理一下，而不是在数据库层面操作。
