---
title: "Mysql 锁：灵魂七拷问"
date: 2019-04-14T13:49:26+09:00
draft: false
---

## Mysql 锁：灵魂七拷问 

作者：柳树 on 美业 from 有赞coder

原链接： [Mysql 锁：灵魂七拷问](https://mp.weixin.qq.com/s/R7gN-dVA4LrVi5zy2LvG_Q)

#### 一、缘起

假设你想给别人说明，Mysql 里面是有锁的，你会怎么做？

大多数人，都会开两个窗口，分别起两个事务，然后 update 同一条记录，在发起第二次 update 请求时，block，这样就说明这行记录被锁住了：
![](https://mmbiz.qpic.cn/mmbiz_png/PfMGv3PxR7icSKQQqXlJcokhOnL03GktP5TvkibJsc1eQCia2y2YzDAvGrEI5Ipco1hNAHyeUJPibGwjsI3zAt4BUg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

#### 二、禁锢

问题来了，貌似只有显式的开启一个事务，才会有锁，如果直接执行一条 update 语句，会不会加锁呢？

比如直接执行：
``` mysql
    update t set c = c + 1 where id = 1;
```

这条语句，前面不加 begin，不显式开启事务，那么 Mysql 会不会加锁呢？

直觉告诉你，会。

但是为什么要加锁？

给你五秒钟，说出答案。


学过多线程和并发的同学，都知道下面这段代码，如果不加锁，就会有灵异事件：
``` java
    i++;
```
开启十个线程，执行 1000 次这段代码，最后 i 有极大可能性，会小于 1000。

这时候，用 Java 的套路，加锁：
``` java
    synchornize {

        i++;

    }
```
问题解决。

同理，对于数据库，你可以理解为 i，就是数据库里的一行记录，i++ 这段代码，就是一条 update 语句，而多线程，对应的就是数据库里的多个事务。

既然对内存中 i 的操作需要加锁，保证并发安全，那么对数据库的记录进行修改，也必须加锁。

这道理很简单，但是很多人，未曾想过。
#### 三、释然

为什么大家都喜欢用第一部分里的例子来演示 Mysql 锁？

因为开两个事务，会 block，够直观。

那么问题又来了，为什么会 block，或者说，为什么 Mysql 一定要等到 commit 了，才去释放锁？

执行完一条 update 语句，就把锁释放了，不行吗？

举个例子就知道 Mysql 为什么要这么干了：
![](https://mmbiz.qpic.cn/mmbiz_png/PfMGv3PxR7icSKQQqXlJcokhOnL03GktPhxia8JJdzh8OAerrZvFrEG8IIe05Z974KxkmARXiaiaGibPmuDgsoPRcjg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

一开始数据是：{id:1,c:1}；

接着事务A通过 select .. for update，进行当前读，查到了 c=1；

接着它继续去更新，把 c 更新成 3，假设这时候，事务 A 执行完 update 语句后，就把锁释放了；

那么就有了第 4 行，事务 B 过来更新，把 c 更新成 4；

结果到了第 5 行，事务 A 又来执行一次当前读，读到的 c，竟然是 4，明明我上一步才把 c 改成了 3...

事务 A 不由的发出怒吼：我为什么会看到了我不该看，我也不想看的东西？！

事务 B 的修改，居然让事务 A 看到了，这明目张胆的违反了事务 ACID 中的 I，Isolation，隔离性（事务提交之前，对其他事务不可见）。

所以，结论：Mysql 为了满足事务的隔离性，必须在 commit 才释放锁。
#### 四、自私的基因

有人说，如果我是读未提交（ Read Uncommited ）的隔离级别，可以读到对方未提交的东西，是不是就不需要满足隔离性，是不是就可以不用等到 commit 才释放锁了？

非也。

还是举例子：
![](https://mmbiz.qpic.cn/mmbiz_png/PfMGv3PxR7icSKQQqXlJcokhOnL03GktPqf88qicW084hLxEYPNkW2a3lvdvXnqdibaLzEqlKX6uzBj4dcBnTtVRA/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

事务A是 Read Committed，事务B是 Read Uncommitted；

事务B执行了一条 update 语句，把 c 更新成了3

假设事务 B 觉得自己是读未提交，就把锁释放了

那这时候事务 A 过来执行当前读，读到了 c 就是3

事务 A 读到了别的事务没有提交的东西，而事务 A，还说自己是读已提交，真是讽刺

根因在于，事务 B 非常自私，他觉得自己是读未提交，就把锁释放了，结果让别人也被“读未提交”

显然，Mysql 不允许这么自私的行为存在。

结论：就算你是读未提交，你也要等到 commit 了再释放锁。
#### 五、海纳百川

都知道 Mysql 的行锁，分为X锁和S锁，为什么 Mysql 要这么做呢？

这个简单吧，同样可以类比 Java 的读写锁：

    It allows multiple threads to read a certain resource, but only one to write it, at a time.

允许多个线程同时读，但只允许一个线程写，既支持并发提高性能，又保证了并发安全。
#### 六、凤凰涅磐

最后来个难点的。

假设事务 A 锁住了表T里的一行记录，这时候，你执行了一个 DDL 语句，想给这张表加个字段，这时候需要锁表吧？但是由于表里有一行记录被锁住了，所以这时候锁表时会 block。

那 Mysql 在锁表时，怎么判断表里有没有记录被锁住呢？

最简单暴力的，遍历整张表，遍历每行记录，遇到一个锁，就说明表里加锁了。

这样做可以，但是很傻，性能很差，高性能的 Mysql，不允许这样的做法存在。

Mysql 会怎么做呢？

行锁是行级别的，粒度比较小，好，那我要你在拿行锁之前，必须先拿一个假的表锁，表示你想去锁住表里的某一行或者多行记录。

这样，Mysql 在判断表里有没有记录被锁定，就不需要遍历整张表了，它只需要看看，有没有人拿了这个假的表锁。

这个假的表锁，就是我们常说的，意向锁。

    Intention locks are table-level locks that indicate which type of lock (shared or exclusive) a transaction requires later for a row in a table

很多人知道意向锁是什么，但是却不知道为什么需要一个粒度比较大的锁，不知道它为何而来，不知道 Mysql 为何要设计个意向锁出来。

知其然，知其所以然。
#### 七、参考文献

    
[InnoDB Locking](https://dev.mysql.com/doc/refman/8.0/en/innodb-locking.html)
    

    
[ReadWriteLock](http://tutorials.jenkov.com/java-util-concurrent/readwritelock.html)
    


