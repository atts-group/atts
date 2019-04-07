---
title: "Leetcode 13 Roman to Integer"
date: 2019-04-07T23:55:16+08:00
draft: false
---


> 题号：13<br>
> 难度：easy<br>
> 链接：https://leetcode.com/problems/roman-to-integer<br>
> 描述：罗马数字转阿拉伯数字(1-3999)<br>


```
class Solution(object):
    def romanToInt1(self, s: str) -> int:
        """仿照上一题的无脑解法，先直接怼一个出来"""
        ten = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX']
        res = 0

        if s.startswith('MMM'):
            res += 3000
            s = s[3:]
        elif s.startswith('MM'):
            res += 2000
            s = s[2:]
        elif s.startswith('M'):
            res += 1000
            s = s[1:]

        if s.startswith('CM'):
            res += 900
            s = s[2:]
        elif s.startswith('D'):
            res += 500
            s = s[1:]
        elif s.startswith('CD'):
            res += 400
            s = s[2:]
        if s.startswith('CCC'):
            res += 300
            s = s[3:]
        elif s.startswith('CC'):
            res += 200
            s = s[2:]
        elif s.startswith('C'):
            res += 100
            s = s[1:]

        if s.startswith('XC'):
            res += 90
            s = s[2:]
        elif s.startswith('L'):
            res += 50
            s = s[1:]
        elif s.startswith('XL'):
            res += 40
            s = s[2:]
        if s.startswith('XXX'):
            res += 30
            s = s[3:]
        elif s.startswith('XX'):
            res += 20
            s = s[2:]
        elif s.startswith('X'):
            res += 10
            s = s[1:]

        res += ten.index(s)
        return res

    def romanToInt2(self, s: str) -> int:
        """有一个微妙的规律，当 左<右 时，减掉左，其余为加左"""
        res = 0
        roman = {'M': 1000, 'D': 500, 'C': 100, 'L': 50, 'X': 10, 'V': 5, 'I': 1}

        for i in range(0, len(s) - 1):
            if roman[s[i]] < roman[s[i + 1]]:
                res -= roman[s[i]]
            else:
                res += roman[s[i]]
        res += roman[s[-1]]

        return res

    def romanToInt(self, s: str) -> int:
        """看了看 discuss，有人给了个更简单的写法
        这里反向迭代的原因是，可以确定 I 是最小的"""
        res, p = 0, 'I'
        roman = {'M': 1000, 'D': 500, 'C': 100, 'L': 50, 'X': 10, 'V': 5, 'I': 1}

        for c in s[::-1]:
            res, p = res - roman[c] if roman[c] < roman[p] else res + roman[c], c
        return res


if __name__ == '__main__':
    print(Solution().romanToInt('MCMXCIV'))
```