---
title: "Leetcode 102. 二叉树的层次遍历"
date: 2019-04-21T21:57:06+08:00
draft: false
---

> 题号：102<br>
> medium<br>
> 链接：https://leetcode-cn.com/problems/binary-tree-level-order-traversal/

Python 递归实现

```python
class Solution:
    def levelOrder(self, root: TreeNode) -> List[List[int]]:
        result = []
        self.traverse(root, 0, result)
        return result
    
    def traverse(self, root, depth, result):
        if root is None:
            return
        
        if depth == len(result):
            result.append([])
        
        result[depth].append(root.val)
        self.traverse(root.left, depth+1, result)
        self.traverse(root.right, depth+1, result)
```