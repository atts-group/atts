---
title: "Dockerfile网络配置概述"
date: 2019-04-28T9:32:05+08:00
draft: false
---


[原文地址](https://docs.docker.com/network/)

## 概况
Docker容器和服务如此强大的原因之一是可以将它们连接起来，或者将它们连接到非Docker工作负载中。Docker容器和服务甚至不需要知道它们部署在Docker上，或者它们的对等端是否也是Docker工作负载。无论Dokcer主机是运行在Linux，Windows还是两者兼有，都可以使用Docker以与平台无关的方式管理它们。


## 网络驱动程序
Dokcer的网络子系统是可插拔的，使用网络驱动程序。默认情况下存在多个驱动程序，并提供核心网络功能。

1. bridge：默认网络驱动程序。如果未指定驱动程序，则这将是默认创建的网络类型。当应用程序在需要通信的独立容器中运行时，通常会使用桥连网络。查看[桥连网络](https://docs.docker.com/network/bridge/)
---

2. host：对于独立容器，删除容器和Docker主机之间的网络隔离，并直接使用主机的网络。host仅用于Docker17.06及更高版本的swarm服务。查看[host网络](https://docs.docker.com/network/host/)
---

3. overlay：覆盖网络将多个Docker守护程序连接在一起，并使集群服务嫩巩固相互通信。可以使用覆盖网络来促进集群服务和独立容器之间的通信，或者在不同Docker守护程序上的两个独立容器之间进行通信。此策略消除了在这些容器之间执行OS级别路由的需要。查看[overlay网络](https://docs.docker.com/network/overlay/)
---

4. macvlan：Macvlan网络允许为容器分配MAC地址，使其显示为网络上的物理设备。Docker守护程序通过其MAC地址将流量路由到容器。macvlan在处理期望直接连接到物理网络的传统应用程序时，使用驱动程序有时时最佳选择，而不是通过Docker主机的网络堆栈进行路由。查看[Macvlan网络](https://docs.docker.com/network/macvlan/)
---

5. none：对于此容器，禁用所有网络。通常与自定义网络驱动程序一起使用。none不适用于群组服务。查看[none网络](https://docs.docker.com/network/none/)
---

6. 网络插件：可以使用Docker按照和使用第三方网络插件。这些插件可以从Docker Hub或第三方供应商处获得。


## 网络驱动摘要
1. 当需要多个容器在同一个Docker主机上进行通信时，用户定义的桥接网络是最佳选择。

2. 当网络堆栈不应与Docker主机隔离时，主机网络是最好的。

3. 当需要在不同Docker主机上运行的容器进行通信时，或者当多个应用程序使用swarm服务协同工作时，覆盖网络是最佳选择。

4. 当从VM设置迁移或需要容器看起来像网络上的物理主机时，Macvlan网络是最佳的，每个主机都具有唯一的MAC地址。

5. 第三方网络插件允许您将Docker与专用网络堆栈集成。