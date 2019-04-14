---
title: "如何在Ubuntu18中设置静态IP"
date: 2019-04-07T22:24:28+08:00
draft: false
---

**修改yaml文件**

Ubuntu 18.04使用netplan配置网络，其配置文件是yaml格式的。

安装好Ubuntu 18.04之后，在/etc/netplan/目录下默认的配置文件名是50-cloud-init.yaml或者是01-network-manager-all.yaml


我们通过VIM修改它

```
sudo vim /etc/netplan/50-cloud-init.yaml
#Let NetworkManager manage all devices on this system 
network:
    #version: 2
    #renderer: NetworkManager
    ethernets:     
        ens33:   
            addresses: [172.20.12.74/24]
            gateway4: 172.20.12.254
            dhcp4: no     
            nameservers:           
                addresses: [103.16.125.251, 103.16.125.252]
```


重启网络服务使配置生效:

>sudo netplan apply 



**注意事项**

1） 无论是ifupdown还是netplan，配置的思路都是一致的，在配置文件里面按照规则填入IP、掩码、网关、DNS等信息。

注意yaml是层次结构，需要缩进，冒号(:)表示字典，连字符(-)表示列表。

比如：
```
network:     
    ethernets:
        ens160:
            addresses:
                - 210.72.92.28/24 # IP及掩码
            gateway4: 210.72.92.254 # 网关
            nameservers:
                addresses:
                    - 8.8.8.8 # DNS     
    version：2 
```


2）只是针对ubuntu18.04 Server版，对于18.04 desktop它缺省是使用NetworkManger来进行管理，可使用图形界面进行配置，其网络配置文件是保存在：/etc/NetworkManager/system-connections目录下的，跟Server版区别还是比较大的。



3) 同时，在 Ubuntu 18.04 中，我们定义子网掩码的时候不是像旧版本的那样把 IP 和子网掩码分成两项配置。

在旧版本的 Ubuntu 里，我们一般配置的 IP 和子网掩码是这样的：

> address = 192.168.225.50 
> netmask = 255.255.255.0 

而在 netplan 中，我们把这两项合并成一项，就像这样：

> addresses : [192.168.225.50/24] 



4) 配置完成之后保存并关闭配置文件。然后用下面这行命令来应用刚才的配置：

> $ sudo netplan apply 

如果在应用配置的时候有出现问题的话，可以通过如下的命令来查看刚才配置的内容出了什么问题。

> $ sudo netplan --debug apply 

这行命令会输出这些 debug 信息：

```
root@ubuntu:/etc/netplan# vim 01-network-manager-all.yaml 
root@ubuntu:/etc/netplan# netplan --debug apply
** (generate:27915): DEBUG: 00:58:04.024: Processing input file /etc/netplan/01-network-manager-all.yaml..
** (generate:27915): DEBUG: 00:58:04.025: starting new processing pass
** (generate:27915): DEBUG: 00:58:04.025: ens33: setting default backend to 1
** (generate:27915): DEBUG: 00:58:04.025: Generating output files..
** (generate:27915): DEBUG: 00:58:04.025: NetworkManager: definition ens33 is not for us (backend 1)
DEBUG:netplan generated networkd configuration exists, restarting networkd
DEBUG:no netplan generated NM configuration exists
DEBUG:ens33 not found in {}
DEBUG:Merged config:
network:
  bonds: {}
  bridges: {}
  ethernets:
    ens33:
      addresses:
      - 192.168.23.129/24
      dhcp4: false
      gateway4: 172.20.12.254
      nameservers:
        addresses:
        - 103.16.125.251
        - 103.16.125.252
  vlans: {}
  wifis: {}

DEBUG:Skipping non-physical interface: lo
DEBUG:device ens33 operstate is up, not changing
DEBUG:Skipping non-physical interface: docker0
DEBUG:Skipping non-physical interface: veth6c57bfa
DEBUG:Skipping non-physical interface: vethf518b7b
DEBUG:Skipping non-physical interface: veth9faaf09
DEBUG:{}
DEBUG:netplan triggering .link rules for lo
DEBUG:netplan triggering .link rules for ens33
DEBUG:netplan triggering .link rules for docker0
DEBUG:netplan triggering .link rules for veth6c57bfa
DEBUG:netplan triggering .link rules for vethf518b7b
DEBUG:netplan triggering .link rules for veth9faaf09
root@ubuntu:/etc/netplan# 
```


5) 在 Ubuntu 18.04 LTS 中配置动态 IP 地址

其实配置文件中的初始配置就是动态 IP 的配置，所以你想要使用动态 IP 的话不需要再去做任何的配置操作。

如果你已经配置了静态 IP 地址，想要恢复之前动态 IP 的配置，就把在上面静态 IP 配置中所添加的相关配置项删除，把整个配置文件恢复成之前的样子

```
# Let NetworkManager manage all devices on this system
network:   
    version: 2   
    renderer: NetworkManager 
```
然后，运行:
> $ sudo netplan apply
