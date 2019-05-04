---
title: "Leetcode_938: Range Sum Of BST"
date: 2019-05-03T18:49:11+09:00
draft: false
tags: ["kingkoma", "leetcode"]
---

> 题号：938 <br>
> 难度：easy <br>
> 链接：https://leetcode.com/problems/range-sum-of-bst/ <br>
> 描述：返回一棵二叉搜索树两个节点之间的值的和，包括两个节点 <br>


``` python

class TreeNode:
    def __init__(self, x):
        self.val = x
        self.left = None
        self.right = None

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
