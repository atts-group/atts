---
title: "Leetcode: 771: Jewels and Stones"
date: 2019-04-28T22:50:02+09:00
draft: false
---

题号：771
难度：easy
链接：[Jewels and Stones](https://leetcode.com/problems/jewels-and-stones/)

``` python
class Solution:
    def newJewelsInStones(self,J,S):
        res = []
        for s in S:
            if s in J:
                res.append(s)
        return len(res)

if __name__ == '__main__':
    s = Solution()
    Jewels = "aA"
    Stones = "aAAbbbb"
    s.newJewelsInStones(Jewels, Stones)          
```
