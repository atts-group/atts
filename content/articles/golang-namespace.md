---
title: "Golang Linux Namespace Usage"
date: 2019-04-07T20:22:21+08:00
draft: false
---

总所周知 Docker 最早诞生于 Linux 平台，利用的是 Linux LXC 技术作为基础。Docker 作为一种 “轻量级虚拟机” 跑在通用操作系统中，那么势必就要对容器进行隔离，保证在宿主机内的独立性。

## Namespace Overview

在 Linux Kernel 中有一组名为 Namespace 的系统调用 API。主要作用是封装了全局的系统资源的调用分配，在一个进程中隔离了其他进程的可见性，让自己 “拥有” 整个计算机的资源的能力。一个典型的用途就是容器的实现。

namespace 一种只有 4 个 API：

- clone：创建一个隔离的进程，可以通过参数控制所拥有的资源
- setns：允许一个进程到现有的 namespace
- unshare：从现有 namespace 中移除一个进程
- ioctl：用法发现 namespace 信息

接下来主要讨论如何创建一个具有隔离性的进程，也就是 clone 这个系统调用的用法。

clone 创建一个新的 namespace（进程），可以对其控制几个方面的资源（通过 CLONE_NEW\* 这系列参数）。

- IPC：CLONE_NEWIPC，System V IPC 和 POSIX message queue
- Network：CLONE_NEWNET，网络设备等
- Mount：CLONE_NEWNS，挂载点
- PID：CLONE_NEWPID，进程的 ID
- User：CLONE_NEWUSER：用户或组的 ID
- UTS：CLONE_NEWUTS：Hostname 和 NIS domain

这里 CLONE_NEWNS 比较奇特，这是最早的一个参数，后面也想不到还有更多粒度的资源控制，所以这是一个历史遗留问题。


## Namespace Usage

由于 Namespace 是 Linux 的系统调用，所以在其他操作系统是无法编译通过的。可以在 build 时候通过设置 `GOOS = linux` 解决，但是运行还是要放在 Linux 上运行。

在 Golang 中创建一个新的进程，通过 CLONE_NEW\* flag 设置资源隔离。

```go
// +build linux

package main

import (
	"log"
	"os"
	"os/exec"
	"syscall"
)

func main() {
	cmd := exec.Command("sh")

	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | 
        syscall.CLONE_NEWIPC | 
        syscall.CLONE_NEWPID | 
        syscall.CLONE_NEWNS | 
        syscall.CLONE_NEWUSER | 
        syscall.CLONE_NEWNET,
	}

	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}
}
```

使用 `env GOOS=linux go build -o nsprocess` 编译后，copy `nsprocess` 到 linux 机器上执行。

先看一下 CLONE_NEWUSER 的功能：

```shell
$ id
uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)
```

我们可以看到，这时候 UID 和我们宿主机上的不同，表明 user 资源被隔离了。

```shell
$ ifconfig
$
```

网络设备信息也是空的，CLONE_NEWNET 的隔离也生效了。

```shell
# hostname -b zxytest
# hostname
zxytest
```

修改 hostname 后到宿主机发现 hostname 并没有被修改，这就是 CLONE_NEWUTS 的隔离性。

```shell
# mount -t proc proc /proc
# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 12:16 pts/0    00:00:00 sh
root         3     1  0 12:17 pts/0    00:00:00 ps -ef
```

mount proc 之后发现进程信息都没有了，只有当前的进程信息。

> ps 命名是通过读取 /proc 文件输出的，所以要先 mount proc

以上就 Linux Namespace 的基本用法，也是 docker 的基础技术。