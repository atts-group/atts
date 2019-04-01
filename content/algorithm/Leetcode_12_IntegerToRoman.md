---
title: "Leetcode_12_IntegerToRoman"
date: 2019-03-31T21:38:00+08:00
draft: false
---


> 题号：12
> 难度：medium
> 链接：https://leetcode.com/problems/integer-to-roman
> 描述：阿拉伯数字转罗马数字(1-3999)


```
class Solution:
    """这道题的点在于，1/10/100/1000是可以重复的，其他数字是不可以重复的，如果用循环处理的话，要注意这一点"""

    def intToRoman1(self, num: int) -> str:
        """照例先撸一个无脑的出来
        这个还算快，不过占用空间比较大
        """
        ten = ['', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX']
        roman = ''

        m, num = divmod(num, 1000)
        roman += 'M' * m
        if num >= 900:
            roman += 'CM'
            num -= 900
        elif num >= 500:
            roman += 'D'
            num -= 500
        elif num >= 400:
            roman += 'CD'
            num -= 400

        c, num = divmod(num, 100)
        roman += 'C' * c

        if num >= 90:
            roman += 'XC'
            num -= 90
        elif num >= 50:
            roman += 'L'
            num -= 50
        elif num >= 40:
            roman += 'XL'
            num -= 40

        x, num = divmod(num, 10)
        roman += 'X' * x + ten[num]

        return roman

    def intToRoman(self, num: int) -> str:
        """看了一下 discuss，有个更简洁的，同样够快且占用空间大"""
        M = ('', 'M', 'MM', 'MMM')
        C = ('', 'C', 'CC', 'CCC', 'CD', 'D', 'DC', 'DCC', 'DCCC', 'CM')
        X = ('', 'X', 'XX', 'XXX', 'XL', 'L', 'LX', 'LXX', 'LXXX', 'XC')
        I = ('', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX')
        return M[num // 1000] + C[(num % 1000) // 100] + X[(num % 100) // 10] + I[num % 10]


if __name__ == '__main__':
    print(Solution().intToRoman(1994))
```

