---
title: "Leetcode: 3 Longest Palindromic Substring"
date: 2019-04-26T17:28:32+08:00
draft: false
---

> 题号：5 <br>
> 难度：medium <br>
> 链接：https://leetcode.com/problems/longest-palindromic-substring/

如下为Python3代码
```python
class Solution:
    def longestPalindrome(self, s: str) -> str:
        if len(s) == 0:
            return s
        length = len(s)
        temp_bool = [[0]*length for i in range(length)]
        left = 0
        right = 0
        i = length - 2
        while i >= 0:
            temp_bool[i][i] = 1
            for j in range(i+1, length):
                temp_bool[i][j] = s[i] == s[j] and (j-i < 3 or temp_bool[i+1][j-1])
                if temp_bool[i][j] and (right-left) < j-i:
                    left = i
                    right = j
            i = i - 1
        return s[left:right+1]

```