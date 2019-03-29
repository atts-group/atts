---
title: "Leetcode：905 Sort Array ByParity"
date: 2019-03-30T00:29:38+08:00
draft: false
---

> 题号：905<br>
> 难度：Easy<br>
> 链接：https://leetcode.com/problems/sort-array-by-parity/

如下是 python3 代码:

```python
#!/usr/bin/python


class Solution:
    def sortArrayByParity(self, A: 'List[int]') -> 'List[int]':
        lens = len(A)
        store_list = [None] * lens
        head = 0
        tail = lens - 1
        for i in range(lens):
            if A[i] % 2 == 0:
                store_list[head] = A[i]
                head += 1
            else:
                store_list[tail] = A[i]
                tail -= 1
        return store_list


if __name__ == '__main__':
    test_list = [3, 1, 2, 4]
    print(Solution().sortArrayByParity(test_list))
```

