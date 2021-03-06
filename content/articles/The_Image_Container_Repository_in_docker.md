---
title: "Doker核心概念-镜像、容器和仓库"
date: 2019-04-20T15:55:09+08:00
draft: false
---

## Docker镜像
Docker镜像类似于虚拟机镜像，可以将它理解为一个只读模板。
例如，一个镜像包含一个基本的操作系统环境，里面仅安装了Apache应用程序(或用户需要的其他软件)。可以把它称为一个Apache镜像。
镜像是创建Docker容器的清楚。通过版本管理和增量的文件系统，Docker提供了一套十分简单的机制来创建和更新现有的镜像，用户甚至可以从网上下载一个已经做好的应用镜像，并直接使用。

## Docker容器
Docker容器类似于一个轻量级的沙盒，Docker利用容器来运行和隔离应用。
容器时从镜像创建的应用运行实例。他可以启动、停止、删除，而这些容器都是彼此相互隔离、互补可见的。
可以把容器看作一个简易版的Linux系统环境(包括root用户系统，进程空间，用户空间和网络空间等)以及运行在其中的应用程序打包而成的盒子。


## Docker仓库
Docker仓库类似于代码仓库，是Docker集中存放镜像文件的场所。
有时候我们会将Docker仓库和仓库注册服务器(Registry)混为一谈，并不严格区分。实际上，仓库注册服务器是存放仓库的地方，其上往往存放着多个仓库。每个仓库集中存放某一类镜像，往往包括多个镜像文件，通过不同的标签(tag)来进行区分。例如存放Ubuntu操作系统镜像的仓库，被称为Ubuntu仓库，其中可能包括不同版本的镜像。

根据所存储的镜像公开与否，Docker仓库可以分为公开仓库和私有仓库两种形式。目前，最大的公开仓库是官方提供的Docker Hub，其中存放着数量庞大的镜像供用户下载。国内不少云服务提供商(如腾讯云，阿里云等)也提供了仓库的本地源，可以提供稳定的国内访问。
当然，用户如果不希望公开分享自己的镜像文件，Docker也支持用户在本地网络内创建一个只能自己访问的私有仓库。
当用户创建了自己的镜像之后，就可以使用push命令将它上传到指定的公有或者私有仓库。这样用户下次在另一台机器上使用该镜像时，只需要将其从仓库上pull下来即可。


## 镜像和容器的区别：
镜像是一个只读系统，在这个只读系统中存在很多只读层，它们按照层次顺序堆叠在一起，中间使用指针连接起来(指针指向下一层)。统一的文件系统将多层只读层统一起来，所以看起来会是一个整体。
容器在镜像的上层添加了一层可读可写层。通过该层，可以经过系统进行写入操作。初次之外，容器几乎是与镜像一样的。