---
title: "Range Sum Of BST"
date: 2019-05-03T18:49:11+09:00
draft: false
tags: ["kingkoma", "leetcode"]
---

``` python
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution:
        
    def rangeSumBST(self, root: TreeNode, L: int, R: int) -> int:
        if not root:
            return 0
        elif root.val < L:
            return self.rangeSumBST(root.right, L, R)
        elif root.val > R:
            return self.rangeSumBST(root.left, L, R)
        else:
            return root.val + self.rangeSumBST(root.right, L, R) + self.rangeSumBST(root.left, L, R)

```
