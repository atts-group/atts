---
title: "Leetcode_17_LetterCombinationsOfAPhoneNumber"
date: 2019-05-04T23:22:55+08:00
draft: false
---


> 题号：17<br>
> 难度：medium<br>
> 链接：https://leetcode.com/problems/letter-combinations-of-a-phone-number/ <br>
> 描述：手机9键盘上，每个数字代表几个字母，给定几个数字，返回他们能组成的所有组合<br>

```
from functools import reduce
from typing import List


class Solution:
    def letterCombinations1(self, digits: str) -> List[str]:
        """一个一个数字地来就可以了，直接 reduce 解决"""
        data = {
            '0': '',
            '1': '',
            '2': 'abc',
            '3': 'def',
            '4': 'ghi',
            '5': 'jkl',
            '6': 'mno',
            '7': 'pqrs',
            '8': 'tuv',
            '9': 'wxyz'
        }
        if not digits:
            return []
        if len(digits) == 1:
            return list(data[digits])
        return reduce(lambda x, y: [i + j for i in x for j in y], [data[x] for x in digits])

    def letterCombinations(self, digits: str) -> List[str]:
        """看了 discuss ，确实还可以用递归
        就结果而言，递归比reduce多消耗了一点点空间，时间上则是相同的
        """
        data = {
            '0': '',
            '1': '',
            '2': 'abc',
            '3': 'def',
            '4': 'ghi',
            '5': 'jkl',
            '6': 'mno',
            '7': 'pqrs',
            '8': 'tuv',
            '9': 'wxyz'
        }
        if not digits:
            return []
        if len(digits) == 1:
            return list(data[digits])
        others = self.letterCombinations(digits[1:])
        res = [a + b for a in data[digits[0]] for b in others]
        return res


if __name__ == '__main__':
    digits = '237'
    print(Solution().letterCombinations(digits))
```
