---
title: "Different rsa for different github account in the same computer"
date: 2019-03-30T10:14:40+08:00
draft: false
---


在同一个电脑上为不同的GitHub账号创建rsa并实现关联。
操作命令行。

```Batch
#为第一个账号创建rsa文件
ssh-keygen -t rsa -C "your email" -f ~/.ssh/id_rsa_for_account1

#为第二个账号创建rsa文件 
ssh-keygen -t rsa -C "your email" -f ~/.ssh/id_rsa_for_account2
```
在.ssh文件夹下创建config文件
输入如下内容：

```
#Default GitHub
Host account1
HostName github.com
User git
IdentityFile ~/.ssh/id_rsa_for_account1

Host account2
HostName github.com
User git
IdentityFile ~/.ssh/id_rsa_for_account2
```
然后分别在account1和account2GitHub中添加公钥。
验证

```
ssh -T account1

ssh -T account2
```