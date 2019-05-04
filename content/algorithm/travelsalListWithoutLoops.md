---
title: "使用递归思想进行列表遍历"
date: 2019-04-14T16:46:49+09:00
draft: false
tags: ["kingkoma"]
---

之前一次面试上遇到的题，不允许用 for 循环和 while 循环，要求遍历出列表每个元素。
当时没有想法，回去后就查了一下，原来可以用递归解决。

``` python

class Solution():
    def travelsal_list_with_recursion(self, Ls, index=0):
        if len(Ls) == index:
            return
        print(Ls[index], end=' ')
        self.travelsal_list_with_recursion(Ls, index+1)
        
if __name__ == '__main__':
    s = Solution()
    ls = ['a', '3', 'r', '3']
    s.travelsal_list_with_recursion(ls)          
```
