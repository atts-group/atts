---
title: "Git Commit 指南"
date: 2019-04-28T10:48:43+09:00
draft: false
tags: ["kingkoma","git"]
---



原链接： [Commit messages guide](https://github.com/RomuloOliveira/commit-messages-guide)

一个让你了解 commit 信息的重要性以及如何写好它们的指南。
本文可以帮助到你
- 了解什么是 commit
- 写好一个 commit 信息为什么如此重要
- 最佳实践
- 一些关于计划、编写或重写好的 commit 历史记录的建议

## 什么是 commit？
简单来说，一次 commit 就是对于你的本地文件的一份快照，写在你的本地仓库里。和某些人想法相反，[git 不仅保存了文件之间的差异，而是保存了文件的完整版本](https://git-scm.com/book/eo/v1/Ekkomenci-Git-Basics#Snapshots,-Not-Differences)。对于那些 commit 和 commit 之间没有发生变化的文件，git 保存了一个快捷链接，这个链接指向之前保存好的相同的文件。
下图展示了 git 是如何随着时间存储数据的，其中每个 version 表示一次 commit。

(![68747470733a2f2f692e737461636b2e696d6775722e636f6d2f41513554472e706e67](https://camo.githubusercontent.com/461832542a2262717f4cd9e843e8e523a10b83b2/68747470733a2f2f692e737461636b2e696d6775722e636f6d2f41513554472e706e67))


## 为什么写好一个 commit 信息如此重要
- 为了提高代码审核的效率，及简化代码审核的过程；
- 帮助了解历史变化；
- 去阐述代码无法解释的原因；
- 帮助未来的维护人员弄清楚为什么要更改和如何更改的，让排除故障和调试更容易。

为了最大化这些好处，我们接下来会举一些好例子和标准范本。

## 好示范
这些都是我从自己经历、网络文章或其它的指南收集的例子。
如果你对它们有任何意见或建议，欢迎新开一个 pull request。

### 用命令式
```
# 好的
Use InventoryBackendPool to retrieve inventory backend

# 不好的
Used InventoryBackendPool to retrieve inventory backend
```
为什么要用命令式？
一次 commit 消息描述了相应改变实际执行的操作及其影响，而不是它做了什么。
[Chris Beams 的这篇优秀的文章给](https://chris.beams.io/posts/git-commit/)了我们提供了一个很简单的句式，可以帮助我们用命令式写出更好的 commit 消息

```
If applied, this commit will <commit message>
```

例子：
```
# 好的
If applied, this commit will use InventoryBackendPool to retrieve inventory backend

# 不好的
If applied, this commit will used InventoryBackendPool to retrieve inventory backend
```

### 第一个字大写
```
# 好的
Add `use` method to Credit model

# 不好的
add `use` method to Credit model
```

为什么要这样做？因为要遵守“一句话的第一个字母要大写”这个语法规则。
对于这个做法，人与人之间、团队与团队之间，甚至语言和语言之间都不一定是一样的。无论要不要第一个字母大写，更重要的是，定一个简单的标准，然后坚持遵守它。

### 尝试不需要看源码就可以知道有什么变化
```
# 好的
Add `use` method to Credit model

# 不好的
Add `use` method
```

```
# 好的
Increase left padding between textbox and layout frame

# 不好的
Adjust css
```
这个在很多场景都非常有用处，比如多次提交、多次修改和重构的时候。可以帮助审核者了解提交者的想法。

### 用信息去解释`为什么`、`为了什么`、`怎么做的`和一些细节

```
# 好的
Fix method name of InventoryBackend child classes

Classes derived from InventoryBackend were not
respecting the base class interface.

It worked because the cart was calling the backend implementation
incorrectly.
```
```
# 好的
Serialize and deserialize credits to json in Cart

Convert the Credit instances to dict for two main reasons:

  - Pickle relies on file path for classes and we do not want to break up
    everything if a refactor is needed
  - Dict and built-in types are pickleable by default
```
```
# 好的
Add `use` method to Credit

Change from namedtuple to class because we need to
setup a new attribute (in_use_amount) with a new value
```
这些信息的主题和征文是用一个空行分隔的。
一个多余的空行是被看作这个正文的一部分的。
同时，像 `-`,`*` `｀` 是可以提高可读性的元素。

### 避免通用信息或没有内容的信息
```
# 不好的
Fix this

Fix stuff

It should work now

Change stuff

Adjust css
```

### 限制字数
[建议主题少于 50 个字母，正文少于 72 个字母](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project#_commit_guidelines)

### 保持语言一致性
给项目持有人：选择一个语言，并用那个语言写所有的 commit 信息。更理想的是，和代码的注释、默认翻译区域设置（用本地化项目时）等保持一致。
给项目贡献者：查看项目历史 commit 信息，使用同一种语言写你的 commit 语句。

```
# 好的
ababab Add `use` method to Credit model
efefef Use InventoryBackendPool to retrieve inventory backend
bebebe Fix method name of InventoryBackend child classes
```

```
# 好的 (葡萄牙语例子)
ababab Adiciona o método `use` ao model Credit
efefef Usa o InventoryBackendPool para recuperar o backend de estoque
bebebe Corrige nome de método na classe InventoryBackend
```

```
# Bad (混合英语和葡萄牙语)
ababab Usa o InventoryBackendPool para recuperar o backend de estoque
efefef Add `use` method to Credit model
cdcdcd Agora vai
```

### 模版
这是来自 [Tim Pope ](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)的一个模版，[Pro Git Book ](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)上有记载。


```
Summarize changes in around 50 characters or less

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of the commit and the rest of the text as the body. The
blank line separating the summary from the body is critical (unless
you omit the body entirely); various tools like `log`, `shortlog`
and `rebase` can get confused if you run the two together.

Explain the problem that this commit is solving. Focus on why you
are making this change as opposed to how (the code explains that).
Are there side effects or other unintuitive consequences of this
change? Here's the place to explain them.

Further paragraphs come after blank lines.

 - Bullet points are okay, too

 - Typically a hyphen or asterisk is used for the bullet, preceded
   by a single space, with blank lines in between, but conventions
   vary here

If you use an issue tracker, put references to them at the bottom,
like this:

Resolves: #123
See also: #456, #789
```

## Rebase 和 Merge

这个部分是来自 Atlassian 的 TL;DR 的一个很好的教程。[Merging vs. Rebasing \| Atlassian Git Tutorial](https://www.atlassian.com/git/tutorials/merging-vs-rebasing)

![68747470733a2f2f7761632d63646e2e61746c61737369616e2e636f6d2f64616d2f6a63723a30316230623034652d363466332d343635392d616632312d6334643836626337636230622f30312e7376673f63646e56657273696f6e3d6871](https://camo.githubusercontent.com/100363e5ea3ea688e98a05ff4aad4d491f68ba05/68747470733a2f2f7761632d63646e2e61746c61737369616e2e636f6d2f64616d2f6a63723a30316230623034652d363466332d343635392d616632312d6334643836626337636230622f30312e7376673f63646e56657273696f6e3d6871)

### Rebase
TL;DR：在你的基本分支基础上，逐步进行你的分支 commit，生成一棵新树。

![68747470733a2f2f7761632d63646e2e61746c61737369616e2e636f6d2f64616d2f6a63723a35623135336132322d333862652d343064302d616563382d3566326666666337373165352f30332e7376673f63646e56657273696f6e3d6871](https://camo.githubusercontent.com/55a8d4d1514ae2b5f95d2852b907444bdf90c1a2/68747470733a2f2f7761632d63646e2e61746c61737369616e2e636f6d2f64616d2f6a63723a35623135336132322d333862652d343064302d616563382d3566326666666337373165352f30332e7376673f63646e56657273696f6e3d6871)

### Merge
TL;DR：创建一个新的 commit，成为一个合并 commit，两个分支间存在一些差异。
![68747470733a2f2f7761632d63646e2e61746c61737369616e2e636f6d2f64616d2f6a63723a65323239666566362d326332662d346134662d623237302d6531653162616139343035352f30322e7376673f63646e56657273696f6e3d6871](https://camo.githubusercontent.com/5db7f575cb9d38a52d7204353d39ad40b484fcf5/68747470733a2f2f7761632d63646e2e61746c61737369616e2e636f6d2f64616d2f6a63723a65323239666566362d326332662d346134662d623237302d6531653162616139343035352f30322e7376673f63646e56657273696f6e3d6871)


### 为什么有些人喜欢 rebase 多于 merge？
我本人喜欢 rebase 多于 merge，理由有如下：
- 它生成一个干净的历史记录，没有不必要的合并 commit；
- 所看即所得，比如，在审核代码时，所有的更改都来自一些特定的有根据的 commit，避免了一些隐藏在合并 commit 里的变化；
- 提交者能解决更多的合并，以及在一个 commit 里的每个合并更改都有准确的信息；
- 挖掘和审核合并 commit 是不寻常的，因此要尽量避免它们，确保所有的更改都有一个所属的 commit。

### 什么时候 squash？
`Squashing` 是指将多个 commit 合并成一个 commit 的过程。
在某些场合下很有用处，比如：
- 减少一些没什么内容的 commit（拼写纠正、代码格式化、遗忘的东西等）
- 把一些分开的更改一起应用，会更有意义
- 进展 commit 的重写工作

### 什么时候应该避免 rebases 或 squash？
在公共 commit 或者共享分支上尽量避免用 rebase 和 squash。
rebase 和 squash 会重写历史和覆盖已存在的 commits，在共享分支上这样操作，因为冲突会引起混乱和导致某些人丢失他们的 commits（包括本地和远程）。

## 有用的 git 命令
### rebase -i
用它来 squash commits，修改信息，重写、删除或重新调整 commit 等。

```
pick 002a7cc Improve description and update document title
pick 897f66d Add contributing section
pick e9549cf Add a section of Available languages
pick ec003aa Add "What is a commit" section"
pick bbe5361 Add source referencing as a point of help wanted
pick b71115e Add a section explaining the importance of commit messages
pick 669bf2b Add "Good practices" section
pick d8340d7 Add capitalization of first letter practice
pick 925f42b Add a practice to encourage good descriptions
pick be05171 Add a section showing good uses of message body
pick d115bb8 Add generic messages and column limit sections
pick 1693840 Add a section about language consistency
pick 80c5f47 Add commit message template
pick 8827962 Fix triple "m" typo
pick 9b81c72 Add "Rebase vs Merge" section

# Rebase 9e6dc75..9b81c72 onto 9e6dc75 (15 commands)
#
# Commands:
# p, pick = use commit
# r, reword = use commit, but edit the commit message
# e, edit = use commit, but stop for amending
# s, squash = use commit, but meld into the previous commit
# f, fixup = like "squash", but discard this commit's log message
# x, exec = run command (the rest of the line) using shell
# d, drop = remove commit
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```
### fixup
用它可以很方便的清理 commits，没有 rebases 那么复杂的操作。[这篇文章](http://fle.github.io/git-tip-keep-your-branch-clean-with-fixup-and-autosquash.html)介绍了一些例子来展示如何用它和应该什么情况下用它。

### cherry-pick
这个当你在错误分支上进行 commit 时非常有用
```
$ git cherry-pick 790ab21
[master 094d820] Fix English grammar in Contributing
 Date: Sun Feb 25 23:14:23 2018 -0300
 1 file changed, 1 insertion(+), 1 deletion(-)
 ```

### add/checkout/reset `[--patch | -p]`
假如说我们有以下差异：
```
diff --git a/README.md b/README.md
index 7b45277..6b1993c 100644
--- a/README.md
+++ b/README.md
@@ -186,10 +186,13 @@ bebebe Corrige nome de método na classe InventoryBackend
 ``
 # Bad (mixes English and Portuguese)
 ababab Usa o InventoryBackendPool para recuperar o backend de estoque
-efefef Add `use` method to Credit model
 cdcdcd Agora vai
 ``

+### Template
+
+This is a template, [written originally by Tim Pope](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html), which appears in the [_Pro Git Book_](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project).
+
 ## Contributing

 Any kind of help would be appreciated. Example of topics that you can help me with:
@@ -202,3 +205,4 @@ Any kind of help would be appreciated. Example of topics that you can help me wi

 - [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)
 - [Pro Git Book - Commit guidelines](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project#_commit_guidelines)
+- [A Note About Git Commit Messages](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
```
我们可以用 `git add -p`去加我们想要的补丁，不需要去更改已经写好的代码。
在把一个大更改分成几个 commits 时或者 reset/checkout 特定更改时非常有用。

```
Stage this hunk [y,n,q,a,d,/,j,J,g,s,e,?]? s
Split into 2 hunks.
```

`hunk 1`

```
@@ -186,7 +186,6 @@
 ``
 # Bad (mixes English and Portuguese)
 ababab Usa o InventoryBackendPool para recuperar o backend de estoque
-efefef Add `use` method to Credit model
 cdcdcd Agora vai
 ``

Stage this hunk [y,n,q,a,d,/,j,J,g,e,?]?
```

`hunk 2`

```
@@ -190,6 +189,10 @@
 ``
 cdcdcd Agora vai
 ``

+### Template
+
+This is a template, [written originally by Tim Pope](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html), which appears in the [_Pro Git Book_](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project).
+
 ## Contributing

 Any kind of help would be appreciated. Example of topics that you can help me with:
Stage this hunk [y,n,q,a,d,/,K,j,J,g,e,?]?
```

`hunk 3`

```
@@ -202,3 +205,4 @@ Any kind of help would be appreciated. Example of topics that you can help me wi

 - [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)
 - [Pro Git Book - Commit guidelines](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project#_commit_guidelines)
+- [A Note About Git Commit Messages](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
```

