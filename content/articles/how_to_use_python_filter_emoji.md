---
title: "如何使用Python过滤emoji"
date: 2019-05-06T00:32:31+08:00
draft: false
---



参考博客：http://my.oschina.net/jiemachina/blog/189460

## 1. 将emoji表情替换为指定字符串

```python
import re



def filter_emoji(desstr, restr=''):
    """过滤表情"""
    try:
        # python UCS-4 build的处理方式
        highpoints = re.compile(u'[\U00010000-\U0010ffff]')
    except re.error:
        # python UCS-2 build的处理方式
        highpoints = re.compile(u'[\uD800-\uDBFF][\uDC00-\uDFFF]')
    return highpoints.sub(restr, desstr)
```


## 2. 把字符串变成表情

```python
import HTMLParser

def str_2_emoji(emoji_str):
    """把字符串转换为表情"""
    if not emoji_str:
        return emoji_str
    h = HTMLParser.HTMLParser()
    emoji_str = h.unescape(h.unescape(emoji_str))
    # 匹配u"\U0001f61c"和u"\u274c"这种表情的字符串
    co = re.compile(r"u[\'\"]\\[Uu]([\w\"]{9}|[\w\"]{5})")
    pos_list=[]
    result=emoji_str
    # 先找位置
    for m in co.finditer(emoji_str):
        pos_list.append((m.start(),m.end()))
    # 根据位置拼接替换
    for pos in range(len(pos_list)):
        if pos == 0:
            result=emoji_str[0:pos_list[0][0]]
        else:
            result=result+emoji_str[pos_list[pos-1][1]:pos_list[pos][0]]
        result = result +eval(emoji_str[pos_list[pos][0]:pos_list[pos][1]])
        if pos==len(pos_list)-1:
            result=result+emoji_str[pos_list[pos][1]:len(emoji_str)]
    return result
```
