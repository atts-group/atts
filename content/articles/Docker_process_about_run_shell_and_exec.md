---
title: "运行shell和exec命令时，Docker进程的区别"
date: 2019-04-14T17:55:40+08:00
draft: false
---

## 1. 前言

Docker容器内运行的进程对于宿主机而言，是独立进程，还是Docker容器进程？

Docker容器内启动的进程全部都是宿主机上的独立进程

Docker容器内启动的进程是不是Docker进程本身要看Dockerfile的写法

比如Docker内启动redis，如果用CMD "/usr/bin/redis-server"，这是用shell启动，会先启动shell，然后再启动redis，所以不是Docker进程本身；

如果用CMD ["/usr/bin/redis-server"]，这是用exec启动，是直接启动redis，进程号为1，所以是Docker进程本身


## 2. shell方式

1) shell方式的Dockerfile

``` shell
root@ubuntu:~# cat Dockerfile 
FROM ubuntu:18.04
RUN apt-get update && apt-get -y install redis-server && rm -rf /var/lib/apt/lists/*
EXPOSE 6379
CMD "/usr/bin/redis-server"
```

2)shell方式创建容器
``` shell
root@ubuntu:~# docker build -t redisshell -f Dockerfile .
```

3) shell方式创建并运行镜像
``` shell
root@ubuntu:~# docker run --name redisshell redisshell
```

4) redisshell容器内进程
``` shell
root@ubuntu:~# docker exec -it redisshell ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 17:36 ?        00:00:00 /bin/sh -c "/usr/bin/redis-ser
root          6      1  0 17:36 ?        00:00:00 /usr/bin/redis-server *:6379
root         10      0  0 17:37 pts/0    00:00:00 ps -ef
```

5) 宿主机进程
``` shell
root@ubuntu:~# ps -ef|grep redis
root       4151   2874  0 10:36 pts/0    00:00:00 docker run --name redisshell redisshell
root       4202   4176  0 10:36 ?        00:00:00 /bin/sh -c "/usr/bin/redis-server"
root       4252   4202  0 10:36 ?        00:00:00 /usr/bin/redis-server *:6379
root       4392   4102  0 10:39 pts/1    00:00:00 grep --color=auto redis
```

## 3. exec方式
1) exec方式的Dockerfile
``` shell
root@ubuntu:~# cat Dockerfile 
FROM ubuntu:18.04
RUN apt-get update && apt-get -y install redis-server && rm -rf /var/lib/apt/lists/*
EXPOSE 6379
CMD ["/usr/bin/redis-server"]
```

2)shell方式创建容器
``` shell
root@ubuntu:~# docker build -t redisexec -f Dockerfile .
```

3) shell方式创建并运行镜像
``` shell
root@ubuntu:~# docker run --name redisexec redisshell
```

4）redisexec器内进程
``` shell
root@ubuntu:~# docker exec -it redisexec ps -ef
UID         PID   PPID  C STIME TTY          TIME CMD
root          1      0  0 17:44 ?        00:00:00 /usr/bin/redis-server *:6379
root          9      0  0 17:45 pts/0    00:00:00 ps -ef
```


5) 宿主机进程
``` shell
root@ubuntu:~# ps -ef|grep redis
root       4151   2874  0 10:36 pts/0    00:00:00 docker run --name redisshell redisshell
root       4202   4176  0 10:36 ?        00:00:00 /bin/sh -c "/usr/bin/redis-server"
root       4252   4202  0 10:36 ?        00:00:01 /usr/bin/redis-server *:6379
root       4442   4102  0 10:44 pts/1    00:00:00 docker run --name redisexec redisexec
root       4496   4466  0 10:44 ?        00:00:00 /usr/bin/redis-server *:6379
root       4646   4561  0 10:46 pts/2    00:00:00 grep --color=auto redis
```


## 4. 两种方式的区别

除了进程是否独立有一定的区别外，两种启动模式导致进程的退出机制也完全不同，从而形成了僵尸进程和孤儿进程

### 4.1 具体说来。Docker提供了docker stop和docker kill两个命令向容器中的1号进程发送信号

1） 当执行docker stop命令时，Docker会首先向容器的1号进程发送一个SIGTERM信号，用于容器内程序的退出。

如果容器在收到SIGTERM信号后没有结束进程，那么Docker Daemon会在等待一段时间(默认是10秒)后再向容器发送SIGKILL信号，将容器杀死并变为退出状态

这种方式给Docker应用提供了一个优雅的退出机制，允许应用在收到stop命令时清理和释放使用中的资源


2）docker kill命令可以向容器内的1号进程发送任何信号，默认是发送SIGKILL信号来强制退出

3) 从Docker1.9版本开始，Docker支持停止容器时向其发送自定义信号量，并指明容器退出机制，该参数的缺省值是SIGTERM



### 4.2 两种方式运行docker stop结果不一样：

1)exec方式
``` shell
root@ubuntu:~# docker stop redisexec
redisexec
root@ubuntu:~# docker logs -f redisexec
1:C 08 Apr 17:44:48.982 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 08 Apr 17:44:48.982 # Redis version=4.0.9, bits=64, commit=00000000, modified=0, pid=1, just started
1:C 08 Apr 17:44:48.982 # Warning: no config file specified, using the default config. In order to specify a config file use /usr/bin/redis-server /path/to/redis.conf
1:M 08 Apr 17:44:48.985 * Running mode=standalone, port=6379.
1:M 08 Apr 17:44:48.985 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 08 Apr 17:44:48.985 # Server initialized
1:M 08 Apr 17:44:48.985 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 08 Apr 17:44:48.986 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
1:M 08 Apr 17:44:48.986 * Ready to accept connections
1:signal-handler (1554746551) Received SIGTERM scheduling shutdown...
1:M 08 Apr 18:02:31.880 # User requested shutdown...
1:M 08 Apr 18:02:31.880 * Saving the final RDB snapshot before exiting.
1:M 08 Apr 18:02:31.892 * DB saved on disk
1:M 08 Apr 18:02:31.892 # Redis is now ready to exit, bye bye...
```
在容器日志中看到了"Received SIGTERM scheduling shutdown..."的内容，说明redis-server进程已经接收到了SIGTERM消息，并优雅地关闭了资源



2）shell方式
``` shell
root@ubuntu:~# docker stop redisshell
redisshell
root@ubuntu:~# docker logs -f redisshell
6:C 08 Apr 17:36:54.062 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
6:C 08 Apr 17:36:54.063 # Redis version=4.0.9, bits=64, commit=00000000, modified=0, pid=6, just started
6:C 08 Apr 17:36:54.063 # Warning: no config file specified, using the default config. In order to specify a config file use /usr/bin/redis-server /path/to/redis.conf
6:M 08 Apr 17:36:54.067 * Running mode=standalone, port=6379.
6:M 08 Apr 17:36:54.067 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
6:M 08 Apr 17:36:54.068 # Server initialized
6:M 08 Apr 17:36:54.068 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
6:M 08 Apr 17:36:54.068 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
6:M 08 Apr 17:36:54.068 * Ready to accept connections
```


docker stop redisshell 容器停止缓慢，而且容器没有优雅关机的内容

原因在于，用shell脚本启动的容器，其1呈进程是shell进程，shell进程中没有对SIGTERM信号的处理逻辑，所以它忽略了接收到的SIGTERM信号

当Docker等待stop命令执行10秒超时之后，Docker Daemon将发送SIGKILL信号强制杀死1号进程，并销毁它的PID命名空间

其子进程redis-servere也在收到SIGKILL信号后被强制终止并退出。

如果此时应用中还有正在执行的事务或未持久化的数据，强制退出可能导致数据丢失或状态不一致



## 5. 总结

所以，容器的1号进程必须能够正确的处理SIGTERM信号来支持优雅退出，如果容器中包含多个进程，则需要1号进程能够正确地传播SIGTERM信号来结束所有的进程，之后再退出

当然，更正确的做法是，令每一个容器中只包含一个进程，同时采用exec模式启动进程。

这也是Docker官方推荐的做法。

