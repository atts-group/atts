---
title: "CGroups 控制进程资源"
date: 2019-04-14T21:53:50+08:00
draft: false
---

cgroups 是 Linux 内核中的一个功能，用来限制、控制分离一个进程的资源，比如 CPU、内存、IO 等。

cgroups 是由一组子系统构成，每种子系统即时一种资源，目前可使用的资源如下：

- cpu：限制 cpu 的使用率
- cpuacct：cpu 的统计报告
- cpuset：分配 cpu
- memory：分配 mem 的使用量
- blkio：限制块设备的 io
- devices：能够访问的设备
- net_cls：控制网络数据的访问
- net_prio：网络流量包的优先级
- freezer：pause 或者 resume 进程
- ns：控制 namespace 的访问

cgroups 中有个 hierarchy 的概念，意思一组 cgroup 是一棵树，cgroup2 可以挂在 cgroup 1 上，这样可以从 cgroup1 中继承设置。

所以 process、subsystem、hierarchy 存在一些关系。

1. 一个 subsystem 只能附加到一个 hierarchy 
2. 一个 hierarchy 可以附加到多个 subsystem 中
3. 一个 process 可以作为多个 cgroups 成员，但是要在不同的 hierarchy 中
4. fork 出的子进程默认和父进程使用一个 cgroups，但是可以移动到其他的 cgroups 中

在 linux 中 /sys/fs/cgroup 中是 cgroups 默认的 hierarchy，可以看到目前的 subsystem

```shell
dr-xr-xr-x 6 root root  0 Dec 17 17:31 blkio
lrwxrwxrwx 1 root root 11 Dec 17 17:31 cpu -> cpu,cpuacct
dr-xr-xr-x 6 root root  0 Dec 17 17:31 cpu,cpuacct
lrwxrwxrwx 1 root root 11 Dec 17 17:31 cpuacct -> cpu,cpuacct
dr-xr-xr-x 4 root root  0 Dec 17 17:31 cpuset
dr-xr-xr-x 6 root root  0 Dec 17 17:31 devices
dr-xr-xr-x 4 root root  0 Dec 17 17:31 freezer
dr-xr-xr-x 7 root root  0 Dec 17 17:31 memory
lrwxrwxrwx 1 root root 16 Dec 17 17:31 net_cls -> net_cls,net_prio
dr-xr-xr-x 3 root root  0 Dec 17 17:31 net_cls,net_prio
lrwxrwxrwx 1 root root 16 Dec 17 17:31 net_prio -> net_cls,net_prio
dr-xr-xr-x 3 root root  0 Dec 17 17:31 perf_event
dr-xr-xr-x 3 root root  0 Dec 17 17:31 pids
dr-xr-xr-x 5 root root  0 Dec 17 17:31 systemd
```

假如我们想给一个进程添加内存限制，第一步需要创建一个 hierarchy 在 /sys/fs/cgroup/memory 中

```shell
sudo mkdir /sys/fs/cgroup/memory/mytestcgroup
```

系统会帮助我们创建一系列文件，这是因为我们挂载的类型是 cgroup，cgroup 的 hierarchy 目录会被映射成文件目录，方便操作：

```shell
-rw-r--r-- 1 root root 0 Apr 14 21:36 cgroup.clone_children
--w--w--w- 1 root root 0 Apr 14 21:36 cgroup.event_control
-rw-r--r-- 1 root root 0 Apr 14 21:36 cgroup.procs
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.failcnt
--w------- 1 root root 0 Apr 14 21:36 memory.force_empty
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.limit_in_bytes
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.max_usage_in_bytes
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.memsw.failcnt
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.memsw.limit_in_bytes
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.memsw.max_usage_in_bytes
-r--r--r-- 1 root root 0 Apr 14 21:36 memory.memsw.usage_in_bytes
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.move_charge_at_immigrate
-r--r--r-- 1 root root 0 Apr 14 21:36 memory.numa_stat
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.oom_control
---------- 1 root root 0 Apr 14 21:36 memory.pressure_level
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.soft_limit_in_bytes
-r--r--r-- 1 root root 0 Apr 14 21:36 memory.stat
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.swappiness
-r--r--r-- 1 root root 0 Apr 14 21:36 memory.usage_in_bytes
-rw-r--r-- 1 root root 0 Apr 14 21:36 memory.use_hierarchy
-rw-r--r-- 1 root root 0 Apr 14 21:36 notify_on_release
-rw-r--r-- 1 root root 0 Apr 14 21:36 tasks
```

在上面的文件中我们可以看到 tasks，这里面放着就是被限制的进程 pid，我们把当前 session 的 pid 放入 task 中，以后从这个 session 启动的进程将会被限制，比如限制一下内存只能使用 100m。

```shell
sudo bash -c "echo "100m" > memory.limit_in_bytes"
sudo bash -c "echo $$ > tasks"
```

然后使用 stress 工具启动一个测压

```shell
stress --vm-bytes 200m --vm-keep -m 1
```

最后通过 top 等工具可以发现内存被限制到了 100m。

## Go 语言控制 cgroup

Go 语言中并没有特殊的 API 接口来处理 cgroup，依然是通过和命令行一样的模式（读写文件）来控制 cgroup。

所以，在 go 语言中就是创建文件夹，删除文件加，写入文件这三个操作来使用 cgroup 功能。

