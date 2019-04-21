---
title: "Docker容器退出时，自动删除容器"
date: 2019-04-21T21:04:57+08:00
draft: false
---

## 1. docker run --rm -v
在Docker容器退出时，默认容器内部的文件系统仍然被保留，以方便调试并保留用户数据。
但是，对于foreground容器，由于其只是在开发调试过程中短期运行，其用户数据并无保留的必要，因而可以在容器启动时设置--rm选项，这样在容器退出时就能够自动清理容器内部的文件系统。示例如下：
``` sehll
docker run --rm centos4
# 等价于
docker run --rm=true centos4
```
显然，--rm选项不能与-d同时使用，即只能自动清理foreground容器，不能自动清理detached容器
注意，--rm选项也会清理容器的匿名data volumes。
所以，执行docker run命令带--rm命令选项，等价于在容器退出后，执行docker rm -v。

rm只是删除容器，rm -v 不仅删除容器（如果容器有使用卷，卷也会进行相应的删除）。

## 2. 范例
``` shell
[root@lvs-webserver2 run]# docker run --rm=true --name=centos4 -it centos
[root@2c1d3bebde29 /]# 
[root@lvs-webserver2 ~]# docker ps -a
CONTAINER ID  IMAGE    COMMAND      CREATED      STATUS       PORTS         NAMES
2c1d3bebde29  centos "/bin/bash"   23 seconds ago  Up 21 seconds            centos4

[root@2c1d3bebde29 /]# exit
exit
[root@lvs-webserver2 run]# 
[root@lvs-webserver2 ~]# docker ps -a
CONTAINER ID   IMAGE      COMMAND       CREATED      STATUS     PORTS      NAMES
```

