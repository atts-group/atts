---
title: "手把手带你创建你第一个 GitHub 贡献"
date: 2019-05-04T17:20:23+09:00
draft: false
---



原链接： [A Step by Step Guide to Making Your First GitHub Contribution
](https://codeburst.io/a-step-by-step-guide-to-making-your-first-github-contribution-5302260a2940)


### 前言
如果你还没有 Github 账户，或者不知道什么是 Git，请阅读：[编程菜鸟？你昨天就应该把 Git 给学了](https://codeburst.io/number-one-piece-of-advice-for-new-developers-ddd08abc8bfa)

### 拜见老师
希望你来这之前已经注册好 Github 账户并做好开始第一个开源项目贡献的准备了。
作为一个新手，贡献一个项目可能会觉得可怕。我明白，我也曾经试过。我花了很长时间才完成我的第一个 Pull Request。这就是为什么我希望你认识 [Roshan Jossey](https://github.com/Roshanjossey) 的原因。Roshan 建了一个 Github 仓库 [First Contributions](https://github.com/Roshanjossey/first-contributions) ，手把手带新人过一遍 Github 的贡献流程，还提供了一个仓库给大家做自己的第一个贡献。

### 开始你的第一个开源项目贡献
#### 1. Fork 仓库
打开 [First Contributions](https://github.com/Roshanjossey/first-contributions) 这个仓库，点击页面上的 Fork 按钮。这样会创建一份仓库备份到你自己的账户。
![0*8NFC0LcrKJhDoQAG.png](https://cdn-images-1.medium.com/max/1600/0*8NFC0LcrKJhDoQAG.png)

#### 2. 克隆仓库
现在把这个仓库克隆到你自己的电脑上。点击 clone 按钮 再点击 copy to clipboard 图标。
![0*J4YiNCc3AOOUMYTT.png](https://cdn-images-1.medium.com/max/1600/0*J4YiNCc3AOOUMYTT.png)
打开终端并运行以下的 git 指令：
```
git clone "你刚刚拷贝到的地址"
```
你刚刚拷贝到的地址（不包括双引号）就是 [First Contributions](https://github.com/Roshanjossey/first-contributions) 这个仓库的地址。查看你之前的步骤去获得这个地址。
![0*D3fowk-gRvjlMJjQ.png](https://cdn-images-1.medium.com/max/1600/0*D3fowk-gRvjlMJjQ.png)
比如：
```
git clone https://github.com/this-is-you/first-contributions.git
```
`this-is-you` 的地方就是你的 Github 用户名。
这样你就把你 Github 上这个仓库的内容拷贝到你的电脑了。

#### 3. 创建分支
进入到你电脑上的仓库目录
```
cd first-contributions
```
使用 `git checkout` 指令创建一个分支
```
git checkout -b <add-your-name>
```
例子：
```
git checkout -b add-alonzo-church
```
（分支的名字不一定要有 add 在里面，但是因为这个分支的目的是为了把你的名字加入名单中，所以有 add 是合理的。）

#### 4. 增加一些必要的修改并对修改进行 commit
现在用文本编辑器打开 `Contributors.md` 这个文件，把你的名字加在里面，然后保存。回到你的终端上的项目目录，执行 `git status` 指令，你就会看到这些修改。执行 `git add` 指令把这些修改加到你刚刚创立的分支上。
```
git add Contributors.md
```
现在用 `git commit` 指令提交修改
```
git commit -m "Add <your-name> to Contributors list"
```
用你自己的名字替代 `<your-name>`

#### 5. Push 修改到 Github
用 `git push` 指令 push 修改
```
git push origin <add-your-name>
```
用你早前创建的分支名字替代 `<add-your-name>`

#### 6. 确认你的修改
这时你去到你 Github 仓库页面上看，会发现一个 `Compare & pull request` 按钮。
点击按钮。
![0*F-LrOSu0kL3fO_Nt.png](https://cdn-images-1.medium.com/max/1600/0*F-LrOSu0kL3fO_Nt.png)
现在确认这个 pull request
![0*T1wiLQV5w5X42w1i.png](https://cdn-images-1.medium.com/max/1600/0*T1wiLQV5w5X42w1i.png)
然后我就会把你的修改合并到这个项目的主分支上。一旦修改被合并你就会收到一封提醒邮件。
你 fork 的主分支不会有改变。为了让你的 fork 与我的同步，请跟着下一步走。

#### 7. 让你的 fork 与这个仓库同步
首先，切换到主分支上
```
git checkout master 
```
然后增加我仓库的地址为 `upstream remote url`
```
git remote add upstream https://github.com/Roshanjossey/first-contributions
```
这是在告诉 git 这个项目的另一个版本在这个地址上，我们称之为 `upstream`。一旦修改被合并，拉取这个仓库的最新版本。

```
git fetch upstream
```
这就是我们怎么拉取 fork（远程上游） 里所有修改的了。
现在你需要把我仓库的最新版本合并到你的主分支。

```
git rebase upstream/master
```
这里你在把你拉取的所有修改应用到主分支上。
如果你现在 push 主分支，你的 fork 也会有这些变化：

```
git push origin master
```
注意你这里 push 的远程对象叫 origin
这个时候我已经把你的分支 `<add-your-name>` 合并到我的主分支上了，你也把我的主分支合并到你自己的主分支上了。
你的分支不再用到了，你可以删掉它。
```
git branch -d <add-your-name>
```
你也可以删掉在远程仓库的分支的版本

```
git push origin --delete <add-your-name>
```
这不是必须的，但是这个分支的名字展示了它的主要目的。因此它的寿命相应的会很短。

### 你做到啦！
现在你已经具备了在网上做开源项目贡献的能力。尽管放胆去试试吧！






























