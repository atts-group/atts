---
title: "Leetcode 3 Longest Substring Without Repeating Characters"
date: 2019-04-20T10:43:56+08:00
draft: false
---

> 题号：3 <br>
> 难度：medium <br>
> 链接：https://leetcode.com/problems/longest-substring-without-repeating-characters/

如下为Python3代码

```python
class Solution(object):
    def lengthOfLongestSubstring(self, s):
        """
        :type s: str
        :rtype: int
        """
        b, m, d = 0, 0, {}
        for i, l in enumerate(s):
            b, m, d[l] = max(b, d.get(l, -1) + 1), max(m, i - b), i
        return max(m, len(s) - b)    

```

[参考内容](https://leetcode.com/problems/longest-substring-without-repeating-characters/discuss/276830/Python-3-line-O(N)-solution)
