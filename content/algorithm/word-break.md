---
title: "Leetcode: 139 Word Break"
date: 2019-04-14T21:57:23+08:00
draft: false
---

> 题号：139<br>
> 难度：中等<br>
> 链接：https://leetcode-cn.com/problems/word-break/submissions/

```python
class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        if not s:
            return True
        
        word_idx = [0]
        
        for i in range(len(s) + 1):
            for j in word_idx:
                if s[j:i] in wordDict:
                    word_idx.append(i)
                    break
        
        return word_idx[-1] == len(s)
```