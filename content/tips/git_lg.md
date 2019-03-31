---
title: "Git_lg"
date: 2019-03-31T20:41:50+08:00
draft: true
---

`git log` 可以用来查看提交历史，但格式并不舒服，我们可以通过配置 `git config` 来解决这个问题：

运行

`git config --global alias.lg 'log --pretty=format:"%h - %an, %ad : %s" --date=format:"%Y-%m-%d %H:%M:%S"'`

之后，便可以使用 `git lg` 来查看精简版本的，更舒服的提交历史了，如本项目现在看的话会变成

```
80504ec - jarvis, 2019-03-31 13:58:55 : add origin article link
df1bcfd - jarvis, 2019-03-31 13:51:45 : Second week atts of jarvys
eede6bf - chuntao.han, 2019-03-30 17:33:10 : hanchuntao translation checkin 1
769b56b - chuntao.han, 2019-03-30 13:07:45 : hanchuntao tips checkin 1
5507805 - chuntao.han, 2019-03-30 12:41:09 : add algorithm for mistake
ef5c5a8 - CTubby, 2019-03-30 12:04:58 : tubby checkin
d698c58 - chuntao.han, 2019-03-30 00:49:57 : hanchuntao algorithm 1 checkin
05b1e47 - chuntao.han, 2019-03-29 00:12:22 : hanchuntao article checkin 1
4792f15 - Woko, 2019-03-28 23:41:32 : Rename [Go]Exercise of A Tour of Go.md to Exercise_of_A_Tour_of_Go.md
0da03b5 - Woko, 2019-03-28 23:37:26 : Rename [mysql]Is varchar a number?.md to is_varchar_a_number.md
6b112eb - Frost Ming, 2019-03-28 14:11:46 : Quit org
c1a8704 - zhengxiaowai, 2019-03-24 23:56:24 : week 1 atts by zhengxiaowai
```

看起来是不是舒服多了
