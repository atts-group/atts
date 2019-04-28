---
title: "leetcode_3: Longest Substring Without Repeating Characters"
date: 2019-04-29T00:06:17+08:00
draft: false
---

```python
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        st = {}
        i, ans = 0, 0
        for j in range(len(s)):
            if s[j] in st:
                i = max(st[s[j]], i)
            ans = max(ans, j - i + 1)
            st[s[j]] = j + 1
        return ans;
```