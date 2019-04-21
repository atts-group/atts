---
title: "Leetcode_216_Combination_Sum_III"
date: 2019-04-14T18:10:33+08:00
draft: false
---

题号：216
难度：Medium
链接：https://leetcode.com/problems/combination-sum-iii/



``` Python
#!/usr/bin/python
# -*- coding: utf-8 -*-


class Solution:
    def combinationSum3(self, k, n):
        result_list = []

        def f(k, n, cur, next):
            if len(cur) == k:
                if sum(cur) == n:
                    result_list.append(cur)
                return

            for i in range(next, n+1):
                f(k, n, cur+[i], i+1)
        f(k, n, [], 1)
        return result_list


if __name__ == '__main__':
    k = 3
    n = 7
    print(Solution().combinationSum3(k, n))
    k = 3
    n = 9
    print(Solution().combinationSum3(k, n))

C:\Python37\python.exe C:/python_workspace/leecode/array/leecode_216.py
[[1, 2, 4]]
[[1, 2, 6], [1, 3, 5], [2, 3, 4]]
```

