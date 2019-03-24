---
title: "Leetcode: 146 LRU Cache"
date: 2019-03-24T23:44:56+08:00
draft: false
---

> 题号：146<br>
> 难度：hard<br>
> 链接：https://leetcode-cn.com/problems/lru-cache/

使用双向链表+map，O(1) 时间复杂度内完成 get 和 put 操作

```python
class Node:
    """ 双链表节点 """

    def __init__(self, key, val):
        self.val = val
        self.key = key
        self.next = None
        self.prev = None


class LRUCache:
    def __init__(self, capacity: int):
        self.capacity = capacity
        self.head = None
        self.tail = None
        self.index = {}

    def get(self, key: int) -> int:
        node = self.index.get(key)

        if node == None:
            return -1

        if node.prev == None:
            # 这是一个表头节点
            return node.val

        if node.next == None:
            # 这是一个尾节点，需要移动到头结点

            if len(self.index) == 2:
                # 如果这是只有两个节点的链表
                self.head = node
                self.tail = node.prev

                self.head.next = self.tail
                self.tail.prev = self.head
            else:
                self.tail = node.prev
                self.tail.next = None

                node.next = self.head
                self.head.prev = node
                self.head = node

            return self.head.val

        # 中间节点
        node.prev.next = node.next
        node.next.prev = node.prev

        node.prev = None
        node.next = self.head
        self.head.prev = node
        self.head = node

        return self.head.val

    def put(self, key: int, value: int) -> None:
        node = self.index.get(key)
        if node:
            # 如果存在先删除
            if len(self.index) == 1:
                # 如果只有一个直接删除就好
                self.head = None
                self.tail = None
                self.index.pop(node.key)
            elif node.next == None:
                # 删除尾节点，需要修复一下 self.tail
                self.tail = node.prev
                self.tail.next = None
                self.index.pop(node.key)
            elif node.prev == None:
                # 删除头结点，需要修复一下 self.head
                self.head = node.next
                self.head.prev = None
                self.index.pop(node.key)
            else:
                # 删除中间节点
                node.prev.next = node.next
                node.next.prev = node.prev
                self.index.pop(node.key)
        else:
            # 如果 capacity 不够要删除尾节点
            if len(self.index) >= self.capacity:
                if len(self.index) == 1:
                    self.head = None
                    self.tail = None
                    self.index = {}
                else:
                    node = self.tail
                    self.tail = node.prev
                    self.tail.next = None
                    self.index.pop(node.key)

        # 构建一个新的节点，插入到头部
        node = Node(key, value)
        if len(self.index) == 0:
            self.head = node
            self.tail = node
            self.index[key] = node
        elif len(self.index) == 1:
            # 如果当前只有一个节点
            self.head = node
            self.head.next = self.tail
            self.tail.prev = self.head
            self.index[key] = node
        else:
            node.next = self.head
            self.head.prev = node
            self.head = node
            self.index[key] = node
            
```