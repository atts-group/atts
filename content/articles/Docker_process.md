---
title: "Docker的进程"
date: 2019-04-21T20:55:18+08:00
draft: false
---

## 1. 查看Docker进程
在Linux系统中，启动Docker服务，会看到如下进程：
``` shell
CentOS7：
[root@lvs-webserver2 ~]# docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
c8a999e1b510        ubuntu              "/bin/bash"         34 seconds ago      Up 32 seconds                           ubuntu
[root@lvs-webserver2 ~]# 
[root@lvs-webserver2 ~]# ps -ef|grep docker|grep -v grep
root      40362      1  1 18:14 ?        00:00:08 /usr/bin/dockerd
root      40373  40362  2 18:14 ?        00:00:14 docker-containerd --config /var/run/docker/containerd/containerd.toml
root      40758  40373  0 18:23 ?        00:00:00 docker-containerd-shim -namespace moby -workdir /var/lib/docker/containerd/daemon/io.containerd.runtime.v1.linux/moby/c8a999e1b510abc2136384742f9ce8fa082d297e83af07d50c8b0d8f47254609 -address /var/run/docker/containerd/docker-containerd.sock -containerd-binary /usr/bin/docker-containerd -runtime-root /var/run/docker/runtime-runc
```

``` shell
Ubuntu18
root@lvs-master:/var/run# docker ps -a
CONTAINER ID        IMAGE                                    COMMAND                   CREATED             STATUS                     PORTS                    NAMES
e96ce4c8c256        redisexec                                "/usr/bin/redis-serv…"    11 days ago         Up 9 minutes               6379/tcp                 redisexec
root@lvs-master:/var/run# 
root@lvs-master:/var/run# ps -ef|grep docker |grep -v grep
root       1039      1  0 18:24 ?        00:00:03 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
root       2852    884  0 19:10 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/e96ce4c8c2569e5209504626275a5db15f88fbd1d778ae9ac69c79536690c11f -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runc
```

## 2.  进程说明
### 2.1 Docker Daemon 或者叫Docker Engine
/usr/bin/dockerd是由Docker服务启动的第一个进程，它是整个Docker服务端启动的入口

### 2.2 docker-containerd
Centos7中有这个过程，Ubuntu18中貌似合并到了/usr/bin/dockerd
它是Dockerd进程的子进程，是Docker服务端的核心进程，负责与Docker客户端进行通信交互，与Docker容器之间进行交互，执行docker run命令，fork出Docker容器进程，几乎所有的核心操作都发生在这里

两者都有一个参数*.sock。意思是打开一个sock描述符，实现所有的Docker容器和Docker客户端（个人理解就是宿主机）之间的通信
CentOS7中是在/var/run/docker/containerd/containerd.toml中有定义
``` shell
[grpc]
  address = "/var/run/docker/containerd/docker-containerd.sock"
  uid = 0
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216
```


Ubuntu18中是在
``` shell
/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

### 2.3 docker-containerd-shim
如果docker run命令启动一个容器，就会生成一个docker-containerd的子进程docker-containerd-shim，这个进程运行着镜像

## 3. 总结
Docker的进程模型为：
dockerd守护进程fock出docker-containerd子进程，用来管理所有容器
docker-containerd进程fork出docker-containerd-shim子进程，该进程中运行了具体的镜像