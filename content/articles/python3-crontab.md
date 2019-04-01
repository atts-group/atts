---
title: "Python3 Crontab"
date: 2019-03-31T21:43:04+08:00
draft: false
---

这周需要在容器中跑一个定时脚本

现成的方式有很多：
1. 直接使用 ubuntu:14.04 的镜像，内置 crontab 和 python3.4
2. 想用 python3.6 的话，可以用 python:3.6 的镜像装一个 crontab 也成
3. dockerhub 上别人应该也有这种需求，捞一个就成

不过我还是想自己拼一个，要求：
1. 需要包含 crontab 和 python3.6
2. 需要能支持使用 pip 安装其他扩展包
3. 镜像要尽量小

思路以及需要注意的地方大概是：
1. 装上各种必要的东西
2. 设置时区
3. 配置好 crontabfile
4. 运行时启动 crond，并用 `tail -f` 来保证容器不退出

目前只是做了个能用的，用 python3.6-alpine 做源，往上怼了点够自己使用的东西，先实现了需求

下一步是直接用 alpine 或者 buildpack-deps 来构建镜像，以此精简，留着 TODO 吧

我写了个 demo 放到了 github 上: https://github.com/WokoLiu/python3-cron ，也同步到了 dockerhub 上 `docker pull woko/python3-cron`

文件结构是这样的：
```
.
├── Dockerfile
├── crontabfile
├── scripts.py
└── requirements.txt
```

* Dockerfile 负责构建镜像
* crontabfile 是写有 crontab 内容的文件
* scripts.py 是要运行的脚本文件
* requirements.txt 是需要 pip 安装的扩展

关键内容是 `Dockerfile`，鉴于还没完善，不好意思在这里详细讲，感兴趣的话可以去看看，后面会再更新

刚学 docker 没多久，一些地方还不清楚，有问题还请不吝赐教，多谢
