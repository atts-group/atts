---
title: "Leetcode_100: same tree"
date: 2019-04-21T17:52:54+09:00
draft: false
tags: ["kingkoma", "leetcode"]
---

> 题号：100 <br>
> 难度：easy <br>
> 链接：https://leetcode.com/problems/same-tree/ <br>
> 描述：查看两棵树是否一致 <br>

``` python

class TreeNode:
    def __init__(self, x):
        self.val = x
        self.left = None
        self.right = None

class Solution:
    def isSameTree(self, p: TreeNode, q: TreeNode) -> bool:
        if p and q:
            return p.val == q.val and self.isSameTree(p.right,q.right) and self.isSameTree(p.left,q.left)
        return p == q


if __name__ == '__main__':
    s = Solution()
    tree1 = TreeNode('s')
    tree2 = TreeNode('s')
    s.isSameTree(tree1, tree2)
```
