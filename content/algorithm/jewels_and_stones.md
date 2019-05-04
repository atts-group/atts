---
title: "Leetcode_771: Jewels and Stones"
date: 2019-04-28T22:50:02+09:00
draft: false
tags: ["kingkoma", "leetcode"]
---
> 题号：771 <br>
> 难度：easy <br>
> 链接：https://leetcode.com/problems/jewels-and-stones/ <br>
> 描述：看看自己手上的石头有多少是宝石 <br>

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
