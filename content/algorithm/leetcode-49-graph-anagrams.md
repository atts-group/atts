---
title: "Leetcode 49 Graph Anagrams"
date: 2019-04-14T22:37:32+08:00
draft: false
---

[原题链接](https://leetcode.com/problems/group-anagrams) ，难度 Medium：

```python
class Solution:
    def groupAnagrams(self, strs):
        """
        :type strs: List[str]
        :rtype: List[List[str]]
        """
        memo = {}
        for s in strs:
            s_ = ''.join(sorted(s))
            if s_ in memo:
                memo[s_].append(s)
            else:
                memo[s_] = [s]
        
        result = []
        for key in memo:
            result.append(memo[key])
        
        return result
```

