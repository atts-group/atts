---
title: "Awk De Duplication"
date: 2019-04-07T23:59:32+08:00
draft: false
---

使用 AWK 对数据进行去重：`awk '!a[$0]++{print}'`

