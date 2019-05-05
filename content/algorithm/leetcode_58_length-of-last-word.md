---
title: "Leetcode_58_length of Last Word"
date: 2019-05-06T00:13:36+08:00
draft: false
---

> 题号：58 <br>
> 难度：Easy <br>
> 链接：https://leetcode-cn.com/problems/length-of-last-word/


```python
class Solution:
    def lengthOfLastWord(self, s: str) -> int:
        words = s.strip().split(" ")
        last_world = words[-1]
        
        return len(last_world)
```