---
title: "Leetcode: 148 Sort List"
date: 2019-04-07T20:21:28+08:00
draft: false
---

> 题号：148<br>
> 难度：中等<br>
> 链接：https://leetcode-cn.com/problems/sort-list/submissions/

```go
/**
 * Definition for singly-linked list.
 * type ListNode struct {
 *     Val int
 *     Next *ListNode
 * }
 */
func sortList(head *ListNode) *ListNode {
    quickSort(head, nil)
    return head
}

func getPartion(start *ListNode, end *ListNode) *ListNode {
    key := start.Val
    
    i := start
    j := start.Next
    
    for j != end {
        if (j.Val < key) {
            i = i.Next
            
            i.Val, j.Val = j.Val, i.Val
        }
        
        j = j.Next
    }
    
    start.Val, i.Val = i.Val, start.Val
    return i
}

func quickSort(head *ListNode, tail *ListNode) {
    if head != tail {
        partion := getPartion(head, tail)
        quickSort(head, partion)
        quickSort(partion.Next, tail)
    }
}
```