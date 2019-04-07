---
title: "Leetcode: 709 To Lower Case"
date: 2019-04-07T14:12:27+09:00
draft: false
---
#### 题号：709 难度：easy 链接：[原题](https://leetcode.com/problems/to-lower-case/)  描述：使用 ASCII 把字母统一为小写

```python
class Solution:
    """use ASCII to return the same str in lowercase """

    def to_lower_case(self, str: str) -> str:
        new_str = ''
        for c in str:
            if 65 <= ord(c) <= 90:   # Uppercase is between 65 and 90 in ASCII table
                c = chr(ord(c)+32)
            new_str += c
        return new_str

    # one line solution
    #return ''.join(chr(ord(c) + 32) if 65 <= ord(c) <= 90 else c for c in str)

if __name__ == '__main__':
    solution = Solution()
    s = 'Hero'
    solution.to_lower_case(s)
```
