---
title: "GitHub 绑定自己的域名"
date: 2019-04-02T10:14:40+08:00
draft: false
---

第一步：
1. 新建一个GitHub仓库，取名为your-github_name.github.io
2. 新建一个文件，取名为CNAME,填写内容为域名。不需要添加http或https。

第二步：
1. 在本地cmd中，ping第一步中新建的仓库名称。会返回一个ip地址，记录下该地址。

第三步：
1. 打开购买的云服务器，因为我购买的阿里云，所有在这上面进行操作演示。
2. 在控制台中打开域名管理。

![域名管理](http://pp0miv3mb.bkt.clouddn.com/20190402203347.png)

3. 找到解析。添加如下信息：<br>
A：对应cmd中ping的地址。<br>
CNAME：对应新建的GitHub仓库名。

![域名解析内容](http://pp0miv3mb.bkt.clouddn.com/20190402203724.png)

完成上述步骤后，配置完成。<br>
[参考网址](https://www.cnblogs.com/start-fxw/p/7144923.html)
