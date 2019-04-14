---
title: "Leetcode: 2 Add Two Numbers"
date: 2019-04-13T17:30:32+08:00
draft: false
---

> 题号：2<br>
> 难度：Medium<br>
> 链接：https://leetcode.com/problems/add-two-numbers/
> 
如下是 python3 代码

```python

# Definition for singly-linked list.
# class ListNode(object):
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution(object):
    def addTwoNumbers(self, l1, l2):
        """
        :type l1: ListNode
        :type l2: ListNode
        :rtype: ListNode
        """
        if l1.next is None and l1.val == 0:
            return l2
        if l2.next is None and l2.val == 0:
            return l1
        
        str1 = ''
        str2 = ''
        
        while l1:
            str1 = str(l1.val) + str1
            l1 = l1.next
        while l2:
            str2 = str(l2.val) + str2
            l2 = l2.next
        
        add_num = list(str(int(str1)+int(str2)))[::-1]
        Nodes = [ListNode(num) for num in add_num]
        
        for i in range(len(Nodes)-1):
            Nodes[i].next = Nodes[i+1]
        
        return Nodes[0]
        
```