---
title: "Leetcode 24 Swap Nodes in Pairs"
date: 2019-04-21T22:33:22+08:00
draft: false
---

[24. Swap Nodes in Pairs](https://leetcode.com/problems/swap-nodes-in-pairs/)

代码如下：

```python
# Definition for singly-linked list.
class ListNode(object):
    def __init__(self, x):
        self.val = x
        self.next = None

class Solution(object):
    def swapPairs(self, head):
        """
        :type head: ListNode
        :rtype: ListNode
        """
        h = ListNode(0)
        tail = h
        
        p = head
        count = 0
        while p != None:
            n = p.next
            if count % 2 == 0:
                tail.next = p
                p.next = None
            else:
                next_node = tail.next
                tail.next = p
                p.next = next_node
                tail = next_node
                
            count = count + 1
            p = n

        return h.next
```

