---
title: "Leetcode: 210 Course Schedule II"
date: 2019-03-31T13:16:57+08:00
draft: false
---

原题链接：[210. Course Schedule II](https://leetcode.com/problems/course-schedule-ii/) 。一道基础拓扑排序题，代码如下：

```python
class Solution:
    def findOrder(self, numCourses: 'int', prerequisites: 'List[List[int]]') -> 'List[int]':
        degrees = [0] * numCourses
        graph = [[] for _ in range(numCourses)]

        for edge in prerequisites:
            source, dep = edge
            degrees[source] += 1
            graph[dep].append(source)
        
        stack = []
        for i in range(numCourses):
            deps = degrees[i]
            if deps == 0:
                stack.append(i)
        
        ret = []
        while len(stack) > 0:
            node = stack.pop()
            
            ret.append(node)
            deps = graph[node]
            for dep in deps:
                degrees[dep] -= 1
                if degrees[dep] == 0:
                    stack.append(dep)


        if len(ret) != numCourses:
            return []
        else:
            return ret
```

