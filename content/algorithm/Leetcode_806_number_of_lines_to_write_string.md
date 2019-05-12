---
title: "Leetcode_806: Number of Lines To Write String"
date: 2019-05-11T16:13:13+09:00
draft: false
tags: ["kingkoma", "leetcode"]
---

> 题号：806 <br>
> 难度：easy <br>
> 链接：https://leetcode.com/problems/number-of-lines-to-write-string/ <br>
> 描述：给出 26 个字母每个占位的宽度和一串字母字符串，每行宽度为 100， 当每行加上要输入下一个的字母宽度超过 100 的话这个字母就跳到下一行。求这串字母占多少行且最后一行占位宽度 <br>


``` python
class Solution:
    
    def numberOfLines(self, widths: List[int], S: str) -> List[int]:
        
        letter_list = ["a", "b", "c", "d", "e", "f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        
        letter_d = dict(zip(letter_list, widths))
        
        str_widths = 0
        lines = 1
        
        for letter in S:
            letter_width = letter_d[letter]
            
            if str_widths + letter_width > 100 * lines:
                str_widths = 100 * lines  + letter_width
                lines += 1
            else:
                str_widths += letter_width
            
        last_line_width =  100 - (lines * 100 - str_widths)
        res = [lines,last_line_width]
        return res
            
```

