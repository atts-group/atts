---
title: "Leetcode Find K Pairs With Smallest Sums"
date: 2019-04-07T16:05:27+08:00
draft: false
---

[原题链接: 373. Find K Pairs with Smallest Sums](https://leetcode.com/problems/find-k-pairs-with-smallest-sums)

典型的 Kth elements 问题，使用堆就行：

```python
import heapq


class Solution:
    def kSmallestPairs(self, nums1: 'List[int]', nums2: 'List[int]', k: 'int') -> 'List[List[int]]':
        if len(nums1) == 0 or len(nums2) == 0:
            return []
        
        q = []
        for n1 in nums1:
            for n2 in nums2:
                heapq.heappush(q, (n1 + n2, n1, n2))
        
        i = k
        ret = []
        while i > 0 and len(q) > 0:
            item = heapq.heappop(q)
            ret.append([item[1], item[2]])
            i = i - 1
        
        return ret
```

