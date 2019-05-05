---
title: "Shell　入门 01"
date: 2019-05-05T13:51:10+09:00
draft: false
tags: ["kingkoma", "shell"]
---

## Shell 的定义

- 一个命令解释器，
- 位于操作系统和应用程序之间

## Shell 的作用
shell 负责把`应用程序`的输入命令信息解释给`操作系统`，将`操作系统`指令处理后的结果解释给`应用程序`。


## Shell 的分类
- 图形界面式
  - 桌面
- 命令行式
  - windows 系统
    - cmd.exe
  - Linux 系统
    - sh
    - bash
    - zsh
    - ...


#### 查看系统 shell 信息
```
echo $SHELL
```

#### 查看系统支持的 shell
```
cat /etc/shells
```

## Shell 的使用
- 手工方式
`逐行输入命令，逐行进行确认执行`

- 脚本方式
`把执行命令写进脚本文件中，通过执行脚本达到执行效果`

#### shell 脚本
`当可执行的 Linux 命令或语句不在命令行状态下执行，而是通过一个文件执行时，我们称文件为shell 脚本。`

#### shell 脚本示范
- 创建一个脚本
```
vim temp.sh
```
- 脚本内容
```
# !/bin/bash 告知系统解释器执行路径
# it's a temp script
echo 'hi'
echo 'atts group'
```
- 执行脚本
```
bash temp.sh
```
- 执行效果
```
hi
atts group
```



