---
title: "Leetcode 165: Compare Version Numbers"
date: 2019-03-31T22:17:14+08:00
draft: false
---

> 题号：165<br>
> 难度：medium<br>
> 链接：https://leetcode-cn.com/problems/compare-version-numbers/


```python
class Solution:
    def compareVersion(self, version1: str, version2: str) -> int:
        vers1 = version1.split(".")
        vers2 = version2.split(".")
        
        diff = len(vers1) - len(vers2)
        if diff > 0:
            vers2 += ['0'] * abs(diff)
        elif diff < 0:
            vers1 += ['0'] * abs(diff)
        else:
            pass

        for i, v1 in enumerate(vers1):
            v1, v2 = int(v1), int(vers2[i])

            if v1 > v2:
                return 1
            elif v1 < v2:
                return -1
            else:
                continue

        return 0
```