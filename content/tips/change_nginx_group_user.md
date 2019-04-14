---
title: "更改Nginx默认用户与组"
date: 2019-04-14T17:42:53+08:00
draft: false
---


## 1. Nginx默认用户

> 为了让Web服务更安全没需要尽可能地改掉软件默认的所有配置，包括端口、用户等。

> 首先查看Nginx服务的默认用户，一般情况下，Nginx服务启动的用户是Nobody,查看默认的配置文件，代码如下：
```shell
[root@localhost conf]# grep '#user' /etc/nginx/nginx.conf.default 
#user bobody; 
```
> 为了防止黑客猜到这个Web服务的用户，我们需要将其更改成特殊的用户名；下面以nginx用户为例进行说明。


## 2. 为nginx服务建立新用户
``` shell
[root@localhost conf]# useradd nginx -s /sbin/nologin -M 
#<== 不需要有系统登录权限，应当禁止其登录能力，相当于Apache里的用户   
[root@localhost conf]# id nginx   #<==检查用户 
```


## 3. 修改Nginx默认用户的两种方法

> 3.1 在编译Nginx软件时直接指定编译的用户和组，命令如下
``` shell
[root@lnmp nginx-1.14.0]# ./configure --user=nginx --group=nginx ... 
```


> 3.2 配置Nginx 服务，让其使用刚建立的Nginx用户
``` shell
[root@lnmp nginx-1.14.0]# egrep "user" /etc/nginx/conf/nginx.conf          
user  nginx; 
[root@lnmp nginx-1.14.0]# ps -ef|grep nginx|grep -v grep 
nginx   56998  56721  0 21:18 ?        00:00:00 nginx: worker process 

```

