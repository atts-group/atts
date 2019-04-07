---
title: "Leetcode_283_Move_Zeroes"
date: 2019-04-07T23:13:23+08:00
draft: false
---

> 题号：283
> 难度：Easy
> 链接：https://leetcode.com/problems/move-zeroes/


``` python
#!/usr/bin/python
# -*- coding:utf-8 -*-

class Solution:
    def moveZeroes(self, nums):
        """
        Do not return anything, modify nums in-place instead.
        """
        empty_index_list = []
        for i in range(len(nums)):
            if i == 0:
                empty_index_list.append(i)
            elif empty_index_list:
                nums[empty_index_list.pop(0)] = nums[i]

        if empty_index_list:
            for i in range(len(empty_index_list)):
                nums[len(nums)-i] = 0

```