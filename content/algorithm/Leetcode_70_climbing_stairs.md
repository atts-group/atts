---
title: "Leetcode 70: Climbing Stairs"
date: 2019-05-12T21:43:33+08:00
draft: false
---

> 题号：70 <br>
> 难度：Easy <br>
> 链接：https://leetcode-cn.com/problems/climbing-stairs/


Python代码
```python
class Solution:
    def __init__(self):
        self.cache = {1: 1, 2: 2}
    
    def climbStairs(self, n: int) -> int:
        if n in self.cache:
            return self.cache[n]
        
        result =  self.climbStairs(n - 1) + self.climbStairs(n - 2)
        self.cache[n] = result
        
        return result
```