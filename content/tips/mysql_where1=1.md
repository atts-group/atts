---
title: "在 Mysql 里使用 where1=1 的作用"
date: 2019-04-14T16:38:31+09:00
draft: false
---

这周工作时看了同事的代码，发现他写的很多 sql 语句都在后面加上了 where1=1，研究了一下，才发现了他的作用和好处。

例子：
``` java
string MySqlStr=”select * from table where”；

　　if(Age.Text.Lenght>0)
　　{
　　　　MySqlStr=MySqlStr+“Age=“+“'Age.Text'“；
　　}

　　if(Address.Text.Lenght>0)
　　{
　　　　MySqlStr=MySqlStr+“and Address=“+“'Address.Text'“；
}
```
如果两个条件都符合，即 sql 语句 "select * from table where Age=x and Address=xx" 成立。
但是如果两个条件都不符合，则语句变成了 "select * from table where"，这个时候就会报错。
使用 where 1=1 可以避免上面发生的问题。

参考链接： [mysql中使用 where 1=1和 0=1 的作用及好处](https://www.haorooms.com/post/mysql_where1100)
