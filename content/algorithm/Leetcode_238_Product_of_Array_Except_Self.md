---
title: "Leetcode 238 Product of Array Except Self"
date: 2019-05-06T00:41:26+08:00
draft: false
---

题号：238
难度：medium
链接：https://leetcode.com/problems/product-of-array-except-self/



```python
#!/usr/bin/python
# -*- coding:utf-8 -*-


class Solution:
    def productExceptSelf(self, nums):
        len_nums = len(nums)
        result = [None] * len_nums
        left = 1
        right = 1
        result[0] = left

        for i in range(1, len_nums):
            left = left * nums[i-1]
            result[i] = left

        for i in range(len_nums-2, -1, -1):
            right = right * nums[i+1]
            result[i] *= right

        return result


if __name__ == '__main__':
    test_list = [1, 2, 3, 4]
    test_result = Solution().productExceptSelf(test_list)
    print(test_result)
```