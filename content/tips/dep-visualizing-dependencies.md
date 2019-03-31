---
title: "dep package 依赖关系图"
date: 2019-03-31T22:11:43+08:00
draft: false
---

Linux:

```shell
$ sudo apt-get install graphviz
$ dep status -dot | dot -T png | display
```

macOS:

```shell
$ brew install graphviz
$ dep status -dot | dot -T png | open -f -a /Applications/Preview.app
```


Windows:

```shell
> choco install graphviz.portable
> dep status -dot | dot -T png -o status.png; start status.png
```