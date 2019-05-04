---
title: "Leetcode_709: To Lower Case"
date: 2019-04-07T14:12:27+09:00
draft: false
tags: ["kingkoma", "leetcode"]
---
> 题号：709 <br>
> 难度：easy <br>
> 链接：https://leetcode.com/problems/to-lower-case/ <br>
> 描述：使用 ASCII 把字母统一为小写 <br>

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
