---
title: "使用 gopass，git 和 gpg 来分享你的密码"
date: 2019-04-21T16:20:07+09:00
draft: false
---
作者： Woile
原链接： [Sharing passwords using gopass, git and gpg
](https://woile.github.io/posts/sharing-team-secrets/)
（删减版）

不想再把你的密码放在不可靠却方便的地方？
不想再在 slack，notes 这些不可信赖的平台上分享密码？
不想再在不同的地方放你的团队密码？
如果对于上面的问题你的回答如果是 yes，那你应该会觉得这篇文章有用。

## 背景
我为了寻找一个安全的方式去储存我的密码花了不少时间。当然，除了安全，我还希望有以下性能：
- 密码存在云里
- 设备之间可以简单同步
- 可以很方便地与人共享
我找到的解决方案是 [gopass](https://www.gopass.pw/)

## gopass 是怎么工作的
gopass 就像是有多一份电池的 [pass](https://www.passwordstore.org/)（unix 密码管理器）
在这里面，它拥有的且和我相关的性能有
1. 用 gpg 进行加密；
2. 用 git 进行密码同步；
3. 不同属性的密码可以放在不同的储存地方（个人、公司等）；
4. 每个存储地方指向不同的仓库；
5. 一个存储地址支持多个人运用。接下来我们称他们为收信人

虽然它还缺乏一些文档和命令，但是我们不必害怕去尝试它。
我很高兴 gopass 使用了 gpg。
它唯一的缺点，我想是它正式的 windows 版本还没发布。

## 安装
你可以看看这个网站里介绍的[安装](https://www.gopass.pw/#install)或者可以在 [gopass repo](https://github.com/gopasspw/gopass/blob/master/docs/setup.md) 里得到更多的信息。

## 使用
首先，我们需要一个 gpg 密钥。我们需要 gpg cli 去创建一个，如果你安装了 gopass，那你的系统里应该就有了。
### gpg 是怎么工作的
在 gopass 的文本中，我们需要用 gpg 提供的公钥和私钥。
想象一下你有很多的公钥，万一它们被锁了，只能用你手上拥有的私钥才能打开。
从此我们可以总结出两件事情：
1. 你可以分发你的公钥并且让任何人对它的信息进行加密。比如说我把公钥给朋友了，他们放了一些东西进去并锁住，只有我可以打开它。当然，我也可以自己加密自己的东西，以防别人窥探。
2. 私钥非常重要。私钥要安全的使用，不要丢失私钥，要备份私钥。你可以用加密的随身硬盘、放在安全地方的小纸条或者 [yubikey](https://www.yubico.com/)。
### 创建密钥
只要跟着指令操作就可以了，非常简单。
如果你不知道填什么，用默认值也可以
```
gpg --full-generate-key
```
查看生成好的密钥
```
gpg -k
```
### 初始化 gopass
```
gopass init
```
我建议在你的终端里加上这个 autocomplete（自动补全指令）
```
echo "source <(gopass completion bash)" >> ~/.bashrc
```
### 使用 gopass
gopass 就像 unix，你有一棵树（不同的文件夹），树上有叶子（加密文件）。
```
gopass
    ├── my-company
    │   └── pepe@my-company.com
    └── personal
        └── pepe@personal.com
```

我们开始来加入加密信息吧。
```
gopass insert personal/twitter/santiwilly
```
你会被提示需要输入两次密码
我是按照这个结构去输入的（其中很多是选择性的）
{store}/{org}/{env}/{username or email}

接下来列出我们所有的信息
```
gopass ls
```
我们可以看到这样
```
gopass
    ├── my-company
    │   └── pepe@my-company.com
    └── personal
        ├── pepe@personal.com
        └── twitter
            └── santiwilly
```
接下来，我给你展示更多简单的指令
### 展示密码
```
gopass personal/twitter/santiwilly
```
### 复制密码到剪切板
```
gopass -c personal/twitter/santiwilly
```
### 生成随机的密码
```
gopass generate my-company/anothername@rmail.com
```
### 搜索加密信息
```
gopass search @gmail.com
```
## 使用存储地址
这里有点复杂。
存储地址（AKA mounts）可以让你管理你的密码。比如私人密码和公司密码。每一个存储地址放在不同的仓库里，然后你可以指定公司密码的存储地址分享给你的同事。
### 新建新的存储地址
在 ~/.password-store-my-company 里新建一个存储地址
```
gopass init --store my-company
```
### 同步到远程
```
gopass git remote add --store my-company origin git@gh.com/Woile/keys.git
```
### 克隆已有的存储地址
假如说你有另一个电脑，这个时候 gopass 就派上用场了。你可以用一样的私钥或者选择一个机器一个私钥，去克隆你的仓库。你只需要进入它。
```
gopass clone git@gh.com/Woile/keys.git my-company --sync gitcli
```
指定 gitcli 为 sync 方法非常重要，不然 gopass 会不知道怎么去同步加密信息（默认是用 noop）。gopass 还提供了其它同步方法。
提供了免费的私人仓库的平台有 [gitlab](https://www.gitlab.com/)，[github](https://github.com/) 和 [bitbucket](https://bitbucket.org/product)。
### 移除已有的存储地址
为了避免有什么冲突，我们首先需要卸载存储地址
```
gopass mounts umount my-company
```
然后操作完上一步后，我们可以安全的移除文件夹了。
```
rm -rf ~/.password-store-my-company
```
## 同步
在 gopass，同步等同于 git pull 和 git push，可能还有 git commit。
### 和远程进行同步
```
gopass sync
```
### 和一个存储地址进行同步
```
gopass sync --store my-company
```
## 团队共享
我们终于到了最后和最美妙的部分了。
共享密信。
假如我们的同事有个邮箱 logan@pm.me。这个人已经在他的电脑里用那个邮箱生成了 gpg 密钥。
他要解析公钥并把它发给我们。
```
gpg -a --export logan@pm.me > logan.pub.asc
```
公钥是可以放在不可靠的地方的。
如果你不是很确信，那就用 [firefox send](https://send.firefox.com/)。
记住人们一般在密钥服务器分享公钥的，像 [opengpgkeyserver](https://pgp.surfnet.nl/)。
### 增加公钥到 gopass 里
我们有公钥了，现在把它加进我们的本地
```
gpg --import < logan.pub.asc
```
最后，我们需要添加新的收信人到 gopass 存储地址
```
gopass recipients add logan@pm.me
```
你会见到你的存储地址所有的提示。
选择你想要的方式，它会用新的公钥重新加密你的信息。（除了已存在的）
这样我们就完成了。
你当然还可以移除收信人。
你自己查一下怎么操作吧。
提示： gopass recipients --help
# 结论
我弄了一份 gopass [cheatsheet](https://woile.github.io/gopass-cheat-sheet/) 和 一个 [presentation](https://woile.github.io/gopass-presentation/)。
gopass 是一个很棒的工具。不幸的是对于非开发者可能有点门槛。
下面是一些我用来加强 gopass 操作用到的其它工具。
[Android password store](https://github.com/zeapo/Android-Password-Store)
我建议用 f-droid 来安装它，你需要 OpenKey-chain 来创建一个新的 gpg 密钥
[gopass bridge](https://github.com/gopasspw/gopassbridge)
firefox 或 chrome 上的插件，可以让你登录你的存储地址。
[gopass ui](https://github.com/codecentric/gopass-ui)
在命令行里使用 gopass 的基于 electron 的 ui 软件。
提供了丰富的图形界面去搜索和管理你的密码。
欢迎任何反馈，我不是安全专家，如果有更好的更安全的工作流可以告诉我，我很高兴。




