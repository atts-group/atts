---
title: "Tmux 快捷键"
date: 2019-04-28T23:13:11+09:00
draft: false
---


- 启动 tmux： tmux

- 创建新命名会话和命名窗口：
tmux new -s name -n name
- 恢复会话：
tmux at [-t 会话名]
- 会话后台运行
prefix d
- 列出所有会话：
tmux ls
- 关闭会话：
tmux kill-session -t 会话名
- 关闭所有会话：
tmux ls | grep : | cut -d. -f1 | awk '{print substr($1, 0, length($1)-1)}' | xargs kill


- 触发 tmux： ctr+b
- 新建窗口： prefix c
- 切换窗口： alt+窗口号（1，2，3）
- 退出窗口 prefix x
- 窗口重命名 prefix ，


- 左右分屏 prefix shift+|
- 上下分屏 prefix shift+-
- 左下上右 prefix hjkl
- 切换面板 prefix o
- 切换面板布局 prefix 空格
- 调整窗格大小 prefix HJKL
- 最大化当前窗格，再次执行可恢复原来大小 prefix z 

- 复制 prefix y
- 黏贴 prefix p
- 向上翻阅 y 进入黄色模式，k向上 q 退出模式

- 多行缩进 进入 v 模式，选中，shift + < 或 >

- 用户配置（优先级更高） ~/.tmux.conf
- 系统配置 /etc/tmux.conf 
- 查看快捷键 prefix ？
- 进入命令模式 prefix ：


[reference1](https://www.kancloud.cn/kancloud/tmux/62463)
[reference2](https://www.cnblogs.com/kaiye/p/6275207.html)




