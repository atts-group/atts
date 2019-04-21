---
title: "漫谈死锁"
date: 2019-04-21T18:18:29+09:00
draft: false
---

作者：杨一 

原链接： [漫谈死锁](https://mp.weixin.qq.com/s?__biz=MzAxOTY5MDMxNA==&mid=2455759362&idx=1&sn=423432bad8307690348a28a42dad3129&chksm=8c686c27bb1fe5311d4a6ee87d6b8c0be7cec0e7c81aa10acb770227f8bbd279d91a1e896146&scene=21#wechat_redirect)

## 一、前言

死锁是每个 MySQL DBA 都会遇到的技术问题，本文自己针对死锁学习的一个总结，了解死锁是什么，MySQL 如何检测死锁，处理死锁，死锁的案例，如何避免死锁。

## 二、死锁
死锁是并发系统中常见的问题，同样也会出现在 Innodb 系统中。当两个及以上的事务，双方都在等待对方释放已经持有的锁或者因为加锁顺序不一致造成循环等待锁资源，就会出现"死锁"。

举例来说 A 事务持有 x1锁 ，申请 x2 锁，B 事务持有 x2 锁，申请 x1 锁。A 和 B 事务持有锁并且申请对方持有的锁进入循环等待，就造成死锁。


从死锁的定义来看，MySQL 出现死锁的几个要素：

a 两个或者两个以上事务。
b 每个事务都已经持有锁并且申请新的锁。
c 锁资源同时只能被同一个事务持有或者不兼容。
d 事务之间因为持有锁和申请锁导致了循环等待。

## 三、MySQL 的死锁机制
死锁机制包含两部分：检测和处理。
把事务等待列表和锁等待信息列表通过事务信息进行 wait-for graph 检测，如果发现有闭环，则回滚 undo log 量少的事务；死锁检测本身也会算检测本身所需要的成本，以便应对检测超时导致的意外情况。
![640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1](https://mmbiz.qpic.cn/mmbiz_png/PfMGv3PxR784nY5yG8nJO634njibCwjx5or9XHwvgW3YyrvhicREbiaEM5pWWSofDEyv3Fzg0po7rV7EbRz1ag6Xw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)
### 3.1 死锁检测
当 InnoDB 事务尝试获取(请求)加一个锁，并且需要等待时，InnoDB 会进行死锁检测。正常的流程如下:
- InnoDB 的初始化一个事务，当事务尝试申请加一个锁，并且需要等待时 (wait_lock)，innodb 会开始进行死锁检测 (deadlock_mark)
- 进入到 lock_deadlock_check_and_resolve() 函数进行检测死锁和解决死锁
- 检测死锁过程中，是有计数器来进行限制的，在等待 wait-for graph 检测过程中遇到超时或者超过阈值，则停止检测。
- 死锁检测的逻辑之一是等待图的处理过程，如果通过锁的信息和事务等待链构造出一个图，如果图中出现回路，就认为发生了死锁。
- 死锁的回滚，内部代码的处理逻辑之一是比较 undo 的数量，回滚 undo 数量少的事务。

### 3.2 如何处理死锁
《数据库系统实现》里面提到的死锁处理：

- 超时死锁检测：当存在死锁时，想所有事务都能同时继续执行通常是不可能的，因此，至少一个事务必须中止并重新开始。超时是最直接的办法，对超出活跃时间的事务进行限制和回滚

- 等待图：等待图的实现，是可以表明哪些事务在等待其他事务持有的锁，可以在数据库的死锁检测里面加上这个机制来进行检测是否有环的形成

- 通过元素排序预防死锁：这个想法很美好，但现实很残酷,通常都是发现死锁后才去想办法解决死锁的原因

- 通过时间戳检测死锁：对每个事务都分配一个时间戳，根据时间戳来进行回滚策略

## 四、Innodb 的锁类型
首先我们要知道对于 MySQL 有两种常规锁模式

- LOCK_S（读锁，共享锁）

- LOCK_X（写锁，排它锁）

最容易理解的锁模式，读加共享锁(in share mode)，写加排它锁。

有如下几种锁的属性：
```
LOCK_REC_NOT_GAP      （锁记录）

 LOCK_GAP              （锁记录前的GAP）

 LOCK_ORDINARY         （同时锁记录+记录前的GAP，也即
Next
 
Key
锁）

 LOCK_INSERT_INTENTION （插入意向锁，其实是特殊的GAP锁）
```
锁的属性可以与锁模式任意组合。例如：

```
lock
->type_mode       可以是
Lock_X
 或者
Lock_S

 locks gap before rec  表示为gap锁：
lock
->type_mode & LOCK_GAP

 locks rec but 
not
 gap 表示为记录锁，非gap锁：
lock
->type_mode & LOCK_REC_NOT_GAP

 insert intention      表示为插入意向锁：
lock
->type_mode & LOCK_INSERT_INTENTION

 waiting               表示锁等待：
lock
->type_mode & LOCK_WAIT
```

## 五、Innodb 不同事务加锁类型
例子: 
```
update tab set x=1 where id= 1 ;
```

1. 索引列是主键，RC 隔离级别
对记录记录加 X 锁

2. 索引列是二级唯一索引，RC 隔离级别
若 id 列是 unique 列，其上有 unique 索引。那么 SQL 需要加两个 X 锁，一个对应于 id unique 索引上的 id = 10 的记录，另一把锁对应于聚簇索引上的[name='d',id=10]的记录。

3. 索引列是二级非唯一索引，RC 隔离级别
若 id 列上有非唯一索引，那么对应的所有满足 SQL 查询条件的记录，都会被加锁。同时，这些记录在主键索引上的记录，也会被加锁。

4. 索引列上没有索引，RC 隔离级别
若 id 列上没有索引，SQL 会走聚簇索引的全扫描进行过滤，由于过滤是由 MySQL Server 层面进行的。因此每条记录，无论是否满足条件，都会被加上 X 锁。但是，为了效率考量，MySQL 做了优化，对于不满足条件的记录，会在判断后放锁，最终持有的，是满足条件的记录上的锁，但是不满足条件的记录上的加锁/放锁动作不会省略。同时，优化也违背了 2PL 的约束。

5. 索引列是主键，RR 隔离级别
对记录记录加 X 锁

6. 索引列是二级唯一索引，RR 隔离级别
对表加上两个 X 锁，唯一索引满足条件的记录上一个，对应的聚簇索引上的记录一个。

7. 索引列是二级非唯一索引，RR 隔离级别
结论：Repeatable Read 隔离级别下，id 列上有一个非唯一索引，对应 SQL:delete from t1 where id = 10;

首先，通过 id 索引定位到第一条满足查询条件的记录，加记录上的 X 锁，加 GAP 上的 GAP 锁，然后加主键聚簇索引上的记录 X 锁，然后返回；然后读取下一条，重复进行。直至进行到第一条不满足条件的记录[11,f]，此时，不需要加记录 X 锁，但是仍旧需要加 GAP 锁，最后返回结束。

8. 索引列上没有索引，RR 隔离级别则锁全表

这里需要重点说明 insert 和 delete 的加锁方式，因为目前遇到的大部分案例或者部分难以分析的案例都是和 delete，insert 操作有关。

insert 的加锁方式

划重点 insert 的流程(有唯一索引的情况): 比如 insert N

1. 找到大于 N 的第一条记录 M，以及前一条记录 P

2. 如果 M 上面没有 gap/next-key lock，进入第三步骤，否则等待(对其 next-rec 加 insert intension lock，由于有 gap 锁，所以等待)

3. 检查 P：判断 P 是否等于 N：

```

 如果不等: 则完成插入（结束）

 如果相等: 再判断P是否有锁，

    a 如果没有锁:报
1062
错误(duplicate key),说明该记录已经存在，报重复值错误 

    b 加S-
lock
,说明该记录被标记为删除, 事务已经提交，还没来得及purge

    c 如果有锁: 则加S-
lock
,说明该记录被标记为删除，事务还未提交.
```
该结论引自: http://keithlan.github.io/2017/06/21/innodblocksalgorithms/

delete 的加锁方式

1. 在非唯一索引的情况下，删除一条存在的记录是有 gap 锁，锁住记录本身和记录之前的 gap

2. 在唯一索引和主键的情况下删除一条存在的记录，因为都是唯一值，进行删除的时候，是不会有 gap 存在

3. 非唯一索引，唯一索引和主键在删除一条不存在的记录，均会在这个区间加 gap 锁

4. 通过非唯一索引和唯一索引去删除一条标记为删除的记录的时候，都会请求该记录的行锁，同时锁住记录之前的 gap

5. RC 情况下是没有 gap 锁的，除了遇到唯一键冲突的情况，如插入唯一键冲突。

引自文章 MySQL DELETE 删除语句加锁分析

## 六、如何查看死锁
1. 查看事务锁等待状态情况
```  
select
 * 
from
 information_schema.innodb_locks;

   
select
 * 
from
 information_schema.innodb_lock_waits;

   
select
 * 
from
 information_schema.innodb_trx;

   
```

下面的查询可以得到当前状况下数据库的等待情况：via《innodb技术内幕中》
```
select
 r.trx_id wait_trx_id,

 r.trx_mysql_thread_id wait_thr_id,

 r.trx_query wait_query,

 b.trx_id block_trx_id,

 b.trx_mysql_thread_id block_thrd_id,

 b.trx_query block_query

 
from
 information_schema.innodb_lock_waits w

 inner join information_schema.innodb_trx b on b.trx_id = w.blocking_trx_id

 inner join information_schema.innodb_trx r on r.trx_id =w.requesting_trx_id

```

2. 打开下列参数，获取更详细的事务和死锁信息

```

   innodb_print_all_deadlocks = ON

   innodb_status_output_locks = ON

```

3. 查看 innodb 状态(包含最近的死锁日志)
```
show engine innodb status;
```
## 七、如何尽可能避免死锁
1. 事务隔离级别使用 read committed 和 binlog_format=row ，避免 RR 模式带来的 gap 锁竞争。

2. 合理的设计索引,区分度高的列放到组合索引前列，使业务 sql 尽可能的通过索引定位更少的行，减少锁竞争。

3. 调整业务逻辑 SQL 执行顺序，避免 update/delete 长时间持有锁 sql 在事务前面，(该优化视情况而定)。

4. 选择合理的事务大小，小事务发生锁冲突的几率也更小；

5. 访问相同的表时，应尽量约定以相同的顺序访问表，对一个表而言，尽可能以固定的顺序存取表中的行。这样可以大大减少死锁的机会；

6. 5.7.15 版本之后提供了新的功能 innodb_deadlock_detect 参数,可以关闭死锁检测，提高并发TPS。
