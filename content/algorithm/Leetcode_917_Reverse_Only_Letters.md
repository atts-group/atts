---
title: "Leetcode_917: Reverse Only Letters"
date: 2019-05-19T15:03:07+09:00
draft: false
tags: ["kingkoma", "leetcode"]
---

> 题号：917 <br>
> 难度：easy <br>
> 链接：https://leetcode.com/problems/reverse-only-letters/ <br>
> 描述：只反转字符串中的字母 <br>


``` python
class Solution:
    def reverseOnlyLetters(self, S: str) -> str:
# solution 1
#         new_list = []

#         for s in S[::-1]:
#             if s.isalpha():
#                 new_list.append(s)

#         for i,s in enumerate(S):
#             if not s.isalpha():
#                 new_list.insert(i, s)

#         return ''.join(new_list)

        # solution 2

        S = list(S)
        left, right = 0, len(S)-1

        while left <= right:
            if S[left].isalpha() and S[right].isalpha():
                S[left], S[right] = S[right], S[left]
                left += 1
                right -= 1
            elif S[left].isalpha() and (not S[right].isalpha()):
                right -= 1
            else:
                left += 1
        return "".join(S)

```