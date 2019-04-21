---
title: "用Python实现单链表反转"
date: 2019-04-21T21:14:09+08:00
draft: false
---

> 题目：单链表反转

> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9 -> None

> 9 -> 8 -> 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> None

> 单链表的反转可以使用循环，也可以使用递归的方式

## 1. 构造链表
### 1） 一次性构造无头结点链表
``` python
class Node:
    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next
link = Node(1, Node(2, Node(3, Node(4, Node(5, Node(6, Node(7, Node(8, Node(9)))))))))       
```

### 2）循环构造有头结点链表
``` python
class LNode:
    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next
i = 1
head = LNode()
cur = head

# 构造单链表
while i <= 9:
    temp = LNode()
    temp.data = i
    temp.next = None
    cur.next = temp
    cur = temp
    i += 1
```

## ２. 使用循环的方式实现单链表反转
### 1) 无头结点的单链表反转
``` python
#!/usr/bin/env python
# coding = utf-8


class Node:
    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next


def reverse_link(link):
    # 将原链表的第一个节点变成了新链表的最后一个节点，同时将原链表的第二个节点保存在cur中
    pre = link
    # 下面两行不能反过来，反过来后link的next就为None了
    cur = link.next
    pre.next = None
    # 从原链表的第二个节点开始遍历到最后一个节点，将所有节点翻转一遍
    # 以翻转第二个节点为例
    # temp = cur.next是将cur的下一个节点保存在temp中，也就是第节点3，因为翻转后，节点2的下一个节点变成了节点1，原先节点2和节点3之间的连接断开，通过节点2就找不到节点3了，因此需要保存
    # cur.next = pre就是将节点2的下一个节点指向了节点1
    # 然后pre向后移动到原先cur的位置，cur也向后移动一个节点，也就是pre = cur, cur = temp
    # 这种就为翻转节点3做好了准备
    while cur:
        temp = cur.next
        cur.next = pre
        pre = cur
        cur = temp
    return pre


if __name__ == '__main__':
    # 构造链表
    link = Node(1, Node(2, Node(3, Node(4, Node(5, Node(6, Node(7, Node(8, Node(9)))))))))

    # 打印反转前链表
    print("before reverse:", end=" ")
    cur = link
    while cur:
        print(cur.data, end=" -> ")
        cur = cur.next
    else:
        print("None")

    # 反转链表
    reversed_pre = reverse_link(link)

    # 打印反转后链表
    print("After reverse:", end=" ")
    while reversed_pre:
        print(reversed_pre.data, end=" -> ")
        reversed_pre = reversed_pre.next
    else:
        print("None")

C:\python_workspace\venv\Scripts\python.exe C:/python_workspace/reverse_node.py
before reverse: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9 -> None
After reverse: 9 -> 8 -> 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> None       
```

### 2） 有头结点的单链表反转

``` python
#!/usr/bin/env python


class LNode:
    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next


def reversed_link(head):
    if head == None or head.next == None:
        return
    # 把链表首结点变成尾结点
    pre = head.next
    cur = pre.next
    pre.next = None
    
    while cur:
        temp = cur.next
        cur.next = pre
        pre = cur
        cur = temp
    
    head.next = pre


if __name__ == '__main__':
    # 初始化变量设置与初始化链表头结点
    i = 1
    head = LNode()
    cur = head

    # 构造单链表
    while i <= 9:
        temp = LNode()
        temp.data = i
        cur.next = temp
        cur = temp
        i += 1

    # 打印逆序前链表
    print("before reverse:", end=" ")
    cur = head.next
    while cur:
        print(cur.data, end=" -> ")
        cur = cur.next
    else:
        print("None")

    # 反转链表
    reversed_link(head)

    # 打印反转后链表
    print("After reverse:", end=" ")
    cur = head.next
    while cur:
        print(cur.data, end=" -> ")
        cur = cur.next
    else:
        print("None")
 C:\python_workspace\venv\Scripts\python.exe C:/python_workspace/reverse_link3.py
before reverse: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8 -> 9 -> None
After reverse: 9 -> 8 -> 7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> None
```

### 3) 用简单的链表表示方法：
``` python
#!/usr/bin/python


class LNode:
    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next


def reverse_link(head):
    if not head and not head.next:
        return 0

    cur = head.next
    temp = cur.next
    cur.next = None

    pre = cur
    cur = temp

    while cur:
        temp = cur.next
        cur.next = pre
        pre = cur
        cur = temp

    head.next = pre


if __name__ == '__main__':
    list_node = LNode("head", LNode(1, LNode(2, LNode(3, LNode(4, LNode(5, LNode(6, LNode(7, LNode(8, LNode(9))))))))))
    head = list_node
    while head.next:
        print(head.data, end=" ")
        head = head.next
    else:
        print(head.data)
    reverse_link(list_node)
    head = list_node
    while head:
        print(head.data, end=" ")
        head = head.next
C:\python_workspace\venv\Scripts\python.exe C:/python_workspace/reverse_link4.py
head 1 2 3 4 5 6 7 8 9
head 9 8 7 6 5 4 3 2 1 
Process finished with exit code 0
```
