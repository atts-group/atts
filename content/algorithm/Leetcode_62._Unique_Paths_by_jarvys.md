---
title: "Leetcode: 62. Unique Paths by jarvys"
date: 2019-03-21T11:20:10+08:00
draft: false
---

[62. Unique Paths](https://leetcode.com/problems/unique-paths/) 是一道基础动规题，递推公式：f(x,y) = f(x+1,y) + f(x, y+1)。我用递归 + memo 的方式完成的，代码如下：

```python
class Solution(object):
    def fn(self, i, j, rows, cols, memo):
        if j >= cols or i >= rows:
            return 0
        
        if j == cols - 1 or i == rows - 1:
            return 1
        
        if memo[i][j] is  None:
            memo[i][j] = self.fn(i+1,j,rows,cols,memo) + self.fn(i,j+1,rows,cols,memo)
        return memo[i][j]
        
    def uniquePaths(self, m, n):
        """
        :type m: int
        :type n: int
        :rtype: int
        """
        if m == 1 and n == 1:
            return 1
        memo = []
        for i in range(n):
            r = []
            for j in range(m):
                r.append(None)
            memo.append(r)
            
        return self.fn(0, 0, n, m, memo)
    
```