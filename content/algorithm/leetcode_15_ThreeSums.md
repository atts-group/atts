---
title: "Leetcode_15_ThreeSums"
date: 2019-04-21T22:52:55+08:00
draft: false
---

> 题号：15<br>
> 难度：medium
> 链接：https://leetcode.com/problems/3sum <br>
> 描述：一串数字中，找出"和为0的三个数字"的所有可能组合

```
from collections import defaultdict
from typing import List


class Solution:
    def threeSum_TLE(self, nums: List[int]) -> List[List[int]]:
        """这题有两个要点：
        1. 遍历并找到所有组合: 尝试直接暴力 n^3
        2. 保证最终结果里没有重复的: 尝试用集合来解决
        能做出结果，但果然超时了
        """
        if not nums:
            return []

        res = []
        dup = []
        for _i, i in enumerate(nums, 1):
            for _j, j in enumerate(nums[_i:], 1):
                for k in nums[_i + _j:]:
                    if not i + j + k:
                        tmp = [i, j, k]
                        if set(tmp) not in dup:
                            dup.append(set(tmp))
                            res.append(tmp)
        return res

    def threeSum_TLE2(self, nums: List[int]) -> List[List[int]]:
        """考虑到超时应该是 n^3 太过分了，尝试用 n^2 来解决
        先 n^2 遍历一遍，把"任意两个值的和"存起来
        再遍历一遍，找到和为 0 的另外两个值
        这里对 [0,0,0] 没法很好的判断，干脆单独给它做了个判断
        结果：仍然超时
        分析：除了遍历外，耗时最多的是去重
        """
        if len(nums) < 3:
            return []

        res = []
        dup = []
        two = set()

        # 遍历一遍，存上任意两个值的和
        sums = defaultdict(list)
        for _i, i in enumerate(nums, 1):
            for j in nums[_i:]:
                if (j, i) not in sums[-i - j]:
                    sums[-i - j].append((i, j))
                    pass
                if i == j:
                    two.add(i)

        # 再遍历一遍，找出和为0的组合
        for i in nums:
            if i in sums:
                for k, j in sums[i]:
                    if k == i or j == i and i not in two:
                        continue
                    if {i, j, k} not in dup:
                        res.append([i, j, k])
                        dup.append({i, j, k})
        if nums.count(0) > 2:
            res.append([0, 0, 0])
        return res

    def threeSum_TEL3(self, nums: List[int]) -> List[List[int]]:
        """意识到 set 里可以存 tuple，考虑这样处理一下
        时间比上一个缩短了一半，但仍然超时
        现在主要时间花在了构建 sums 字典上
        """
        if len(nums) < 3:
            return []

        res = []
        dup = set()
        two = set()

        # 遍历一遍，存上任意两个值的和
        sums = defaultdict(list)
        for _i, i in enumerate(nums, 1):
            for j in nums[_i:]:
                if (j, i) not in sums[-i - j]:
                    sums[-i - j].append((i, j))
                    pass
                if i == j:
                    two.add(i)

        # 再遍历一遍，找出和为0的组合
        for i in nums:
            if i in sums:
                for k, j in sums[i]:
                    if k == i or j == i and i not in two:
                        continue
                    tmp = sorted([i, j, k])
                    if tuple(tmp) not in dup:
                        res.append([i, j, k])
                        dup.add(tuple(tmp))

        if nums.count(0) > 2:
            res.append([0, 0, 0])
        return res

    def threeSum(self, nums: List[int]) -> List[List[int]]:
        """去看了 discuss, 先排序，确实就完全是另一种思路了
        不需要构建乱七八糟的辅助变量，按顺序走下去就可以了
        去重问题，也因为是有序的，而直接跳过已处理好的相同变量
        """
        if not nums:
            return []
        nums.sort()
        res = []
        for i in range(len(nums)-2):
            if i > 0 and nums[i] == nums[i-1]:
                continue
            l, r = i+1, len(nums)-1
            while l < r:
                s = nums[i] + nums[l] + nums[r]
                if s < 0:
                    l +=1
                elif s > 0:
                    r -= 1
                else:
                    res.append((nums[i], nums[l], nums[r]))
                    while l < r and nums[l] == nums[l+1]:
                        l += 1
                    while l < r and nums[r] == nums[r-1]:
                        r -= 1
                    l += 1; r -= 1
        return res

if __name__ == '__main__':
    data = [-1, 0, 1, 2, -1, -4]
    # data = [3, 0, -2, -1, 1, 2]
    data = [0,0,0,0,0,0,0,0,0]
    print(Solution().threeSum(data))

```