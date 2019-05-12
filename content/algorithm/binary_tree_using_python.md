---
title: "用Python实现二叉树"
date: 2019-05-12T22:39:01+08:00
draft: false
---



用Python方式实现二叉树

测试数据1：

```
  7
8   9
```
测试数据2：
```
        7
      8    9
       23    36
      57 58
```
```python
#! /usr/bin/python


class BiTNode:
    def __init__(self, left=0, right=0, data=0):
        self.left = left
        self.data = data
        self.right = right


class BinaryTree:
    def __init__(self, base):
        self.base = base

    def is_empty(self):
        if self.base == 0:
            return True
        else:
            return False

    def pre_order_traversal(self, jd):
        if jd == 0:
            return
        print(jd.data)
        self.pre_order_traversal(jd.left)
        self.pre_order_traversal(jd.right)

    def in_order_traversal(self, jd):
        if jd == 0:
            return
        self.in_order_traversal(jd.left)
        print(jd.data)
        self.in_order_traversal(jd.right)

    def post_order_traversal(self, jd):
        if jd == 0:
            return
        self.post_order_traversal(jd.left)
        self.post_order_traversal(jd.right)
        print(jd.data)


if __name__ == '__main__':
    jd1 = BiTNode(data=8)
    jd2 = BiTNode(data=9)
    base = BiTNode(jd1, jd2, 7)

    x = BinaryTree(base)
    print("pre_order")
    x.pre_order_traversal(x.base)
    print("in_order")
    x.in_order_traversal(x.base)
    print("post_order")
    x.post_order_traversal(x.base)

    jd1 = BiTNode(data=58)
    jd2 = BiTNode(data=57)
    jd3 = BiTNode(data=36)
    jd4 = BiTNode(jd2, jd1, 23)
    jd5 = BiTNode(right=jd3, data=9)
    jd6 = BiTNode(right=jd4, data=8)
    base = BiTNode(jd6, jd5, 7)
    x = BinaryTree(base)
    print("pre_order traversal".center(20, "#"))
    x.pre_order_traversal(x.base)
    print("in_order traversal".center(20, "#"))
    x.in_order_traversal(x.base)
    print("post_order traversal".center(20, "#"))
    x.post_order_traversal(x.base)
    
C:\Python37\python.exe C:/python_workspace/tree/binary_tree.py
pre_order
7
8
9
in_order
8
7
9
post_order
8
9
7
pre_order traversal#
7
8
23
57
58
9
36
#in_order traversal#
8
57
23
58
7
9
36
post_order traversal
57
58
23
8
36
9
7

Process finished with exit code 0
```
