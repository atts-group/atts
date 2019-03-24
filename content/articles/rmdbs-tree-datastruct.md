---
title: "使用 RMDBS 存在树结构数据"
date: 2019-03-24T23:41:36+08:00
draft: false
---

在关系型数据库中存储树形结构是比较麻烦的事情，因为数据库都是基于行存储的结构，要满足树形数据结构的添加、删除、查询、修改是一件比较棘手的事情。

已经有一些解决方案可以解决：

![img](http://www.ituring.com.cn/figures/2012/SQL%20Antipatterns/06.d3z.05.jpg)

这篇文章介绍一下，使用「闭包表」来处理树形结构存储。

选择「闭包表」主要是基于查询、插入、删除、移动都比较简单，更要的是都可以使用一条 SQL 就能处理完成。

```sql
CREATE TABLE Comments (
  comment_id   SERIAL PRIMARY KEY,
  comment      TEXT NOT NULL
);
```

树形结构典型就是评论和部门成员关系，以评论为例，我们同时又要支持完整增删改查的功能，大致结构如下：
![](https://static.zhengxiaowai.cc/2019-03-24-135302.jpg)

为了满足这种复杂的关系，需要有另外一个表来存储这种结构。

```sql
CREATE TABLE TreePaths (
  ancestor    BIGINT  NOT NULL,
  descendant  BIGINT  NOT NULL,
  PRIMARY KEY(ancestor, descendant),
  FOREIGN KEY (ancestor) REFERENCES Comments(comment_id),
  FOREIGN KEY (descendant) REFERENCES Comments(comment_id)
);
```

ancestor 作为每个评论节点的祖先，descendant 作为每个评论节点的后代。

> 这里的祖先和后代都是泛指所有祖先和后代，而不是特指直接的祖先和后代

接着构造一批数据插入 Comments 和 Tree Paths 中

```sql
insert into comments(comment_id, comment) values (1, '这个 Bug 的成因 是什么');
insert into comments(comment_id, comment) values (2, '我觉得是一个空指针');
insert into comments(comment_id, comment) values (3, '不，我查过了');
insert into comments(comment_id, comment) values (4, '我们需要查无效输入');
insert into comments(comment_id, comment) values (5, '是的，那是个问题');
insert into comments(comment_id, comment) values (6, '好，查一下吧');
insert into comments(comment_id, comment) values (7, '解决了');


insert into treepaths(ancestor, descendant) values (1, 1);
insert into treepaths(ancestor, descendant) values (1, 2);
insert into treepaths(ancestor, descendant) values (1, 3);
insert into treepaths(ancestor, descendant) values (1, 4);
insert into treepaths(ancestor, descendant) values (1, 5);
insert into treepaths(ancestor, descendant) values (1, 6);
insert into treepaths(ancestor, descendant) values (1, 7);
insert into treepaths(ancestor, descendant) values (2, 2);
insert into treepaths(ancestor, descendant) values (2, 3);
insert into treepaths(ancestor, descendant) values (3, 3);
insert into treepaths(ancestor, descendant) values (4, 4);
insert into treepaths(ancestor, descendant) values (4, 5);
insert into treepaths(ancestor, descendant) values (4, 6);
insert into treepaths(ancestor, descendant) values (4, 7);
insert into treepaths(ancestor, descendant) values (5, 5);
insert into treepaths(ancestor, descendant) values (6, 6);
insert into treepaths(ancestor, descendant) values (6, 7);
insert into treepaths(ancestor, descendant) values (7, 7);
```

这里需要解释一下 treepaths 存储关系的逻辑：

1. 每个节点和自己建立一个关系，也就是 ancestor 和 descendant 都是自己
2. 每个节点和自己祖先建立关系，也就是 ancestor 指向所有祖先节点
3. 每个节点和自己后代建立关系，也就是 descendant 指向所有的后代节点

以上关系建立完毕之后，就能以树形关系查询 comments 表中的数据，比如要查询 `comment_id = 4` 所有的子节点：

```sql
SELECT c.* 
	FROM Comments AS c 
	JOIN TreePaths AS t ON c.comment_id = t.descendant 
	WHERE t.ancestor = 4;
```

![](https://static.zhengxiaowai.cc/2019-03-24-151711.png)

或者要查询 `comment_id = 4` 所有的父节点：

```sql
SELECT c.*
	FROM Comments AS c
  	JOIN TreePaths AS t ON c.comment_id = t.ancestor
	WHERE t.descendant = 4;
```

![](https://static.zhengxiaowai.cc/2019-03-24-151815.png)

假如要在 `comment_id= 5` 后插入一个新的节点，先要插入关联到自己的关系，然后从 TreePaths 找出中 descendant 为 5 节点。意思就是找出 `comment_id = 5` 的祖先和新节点在 TreePaths 关联上.

```sql
insert into comments(comment_id, comment) values (8, '对的是这个问题，我已经修复了');

INSERT INTO TreePaths (ancestor, descendant)
	SELECT t.ancestor, 8 FROM TreePaths AS t WHERE t.descendant = 5
 	UNION ALL SELECT 8, 8;
```

![](https://static.zhengxiaowai.cc/2019-03-24-152932.png)

如果要删除 `comment_id = 7` 这个节点，只需要在 TreePaths 删除 descendant = 7 的记录即可，这时候不用我们维护节点和节点之间的关系，所以很方便

```sql
DELETE FROM TreePaths WHERE descendant = 7;
```

假如要删除 `comment_id = 4` 这颗完整的树，只需要找出这个 root 节点所有的后代删除即可。

```sql
DELETE FROM TreePaths
    WHERE descendant IN (SELECT descendant
                         FROM TreePaths
                         WHERE ancestor = 4);
```

如果是移动一个节点，只需要删除然后再添加即可，这时候自身的引用可以不用删除。

比较复杂的是移动一棵树，要先找到这棵树的根节点，然后移除所有子节点和他们祖先的关系，比如把 comment_id = 6 移动到 commint_id = 3 下。

首先把在 TreePaths 把所有关系移除

```sql
DELETE FROM TreePaths
WHERE descendant IN (SELECT descendant
                     FROM TreePaths
                     WHERE ancestor = 6)
  AND ancestor IN (SELECT ancestor
                   FROM TreePaths
                   WHERE descendant = 6 AND ancestor != descendant);
```

然后在 `commint_id = 3` 插入新关系，同时所有子节点要和 `commint_id = 3` 的祖先建立关系

```sql
INSERT INTO TreePaths (ancestor, descendant)
  SELECT supertree.ancestor, subtree.descendant
  FROM TreePaths AS supertree
    CROSS JOIN TreePaths AS subtree
  WHERE supertree.descendant = 3
    AND subtree.ancestor = 6;
```

使用一开始查询的 SQL，可以看出移动过去了

![](https://static.zhengxiaowai.cc/2019-03-24-153505.png)