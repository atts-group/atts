---
title: "Leetcode: 9 Palindrome Number"
date: 2019-05-05T17:28:32+08:00
draft: false
---

> 题号：9 <br>
> 难度：Easy <br>
> 链接：https://leetcode.com/problems/palindrome-number/


Python代码
```python
class Solution:
    def isPalindrome(self, x: int) -> bool:   
        str_x = str(x)
        for i in range(0,int(len(str_x)/2)):
            if str_x[i] != str_x[-i-1]:
                return False
        return True
```