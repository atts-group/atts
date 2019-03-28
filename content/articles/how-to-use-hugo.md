---
title: "How to Use Hugo"
date: 2019-03-28T23:51:40+08:00
draft: false
---


## 一、介绍
### 1. 优点 
> * Hugo是一个用Go语言编写的静态网站生成器，它使用起来非常简单，相对于Jekyll复杂的安装设置来说，Hugo仅需要一个二进制文件hugo(hugo.exe)即可轻松用于本地调试和生成静态页面。
> * Hugo生成静态页面的效率很高，几乎是瞬间完成的，而之前用Jekyll需要等待。
> * Hugo自带watch的调试模式，可以在我修改MarkDown文章之后切换到浏览器，页面会检测到更新并且自动刷新，呈现出最终效果，能极大的提高博客书写效率。
> * 再加上Hugo是使用Go语言编写，已经没有任何理由不使用Hugo来代替Jekyll作为我的个人博客站点生成器了。

### 2. 静态网站文件的两种方式：
>* 放到自己的服务器上提供服务：需要自己购买服务器
>* 把网站托管到 GitHub Pages：需要将静态页面文件 push 到 GitHub 的博客项目的 gh-pages 分支并确保根目录下有 index.html 文件。

### 3. 官网
>* Hugo语言官方中文文档地址：http://www.gohugo.org/
>* Hugo官方主页：https://gohugo.io/



## 二、安装Hugo

### 1. 二进制安装（推荐：简单、快速）
到 Hugo Releases (<https://github.com/gohugoio/hugo/releases>)下载对应的操作系统版本的Hugo二进制文件（hugo或者hugo.exe）

*  下载解压后添加到 Windows 的系统环境变量的 PATH 中即可，不需安装。
*  可以直接放在C:\Users\chunt\go\bin下，这样就不需要添加系统环境变量


Mac下直接使用 Homebrew 安装：

*  brew install hugo
*  二进制在 $GOPATH/bin/, 即C:\Users\chunt\go\bin


### 2.  源码安装(不好用，go get有些下载不下来)
源码编译安装，首先安装好依赖的工具：

* Git
*  Go 1.3+ (Go 1.4+ on Windows)


设置好 GOPATH 环境变量，获取源码并编译：

* export GOPATH=$HOME/go
*  go get -v github.com/spf13/hugo

源码会下载到 $GOPATH/src 目录, 即C:\Go\src

如果需要更新所有Hugo的依赖库，增加 -u 参数： 

* go get -u -v github.com/spf13/hugo


> The -u flag instructs get to use the network to update the named packages
> and their dependencies. By default, get uses the network to check out
> missing packages but does not use it to look for updates to existing packages.

> The -v flag enables verbose progress and debug output.  

### 3.  查看安装结果

可知hugo已经正常安装:
![](/how-to-use-hugo/1.png)



## 三、创建hugo项目
使用Hugo快速生成站点，比如希望生成到 /path/to/site | C:\code\hugo路径：

* linux:  $ hugo new site /path/to/site
*  windows:  hugo new site C:\code\hugo


这样就在 /path/to/site | C:\code\hugo目录里生成了初始站点，进去目录：

* cd /path/to/site
* cd  C:\code\hugo


站点目录结构：

* ▸ archetypes/
* ▸ content/
* ▸ layouts/
* ▸ static/
*   config.toml


config.toml是网站的配置文件，这是一个TOML文件，全称是Tom’s Obvious, Minimal Language，
这是它的作者GitHub联合创始人Tom Preston-Werner 觉得YAML不够优雅，捣鼓出来的一个新格式。
如果你不喜欢这种格式，你可以将config.toml替换为YAML格式的config.yaml，或者json格式的config.json。hugo都支持。

> content目录里放的是你写的markdown文章，layouts目录里放的是网站的模板文件，static目录里放的是一些图片、css、js等资源。



## 四、创建文章

### 1. 创建一个 about 页面：
进入到C:\code\hugo

* $ hugo new about.md

about.md 自动生成到了 content/about.md ，打开 about.md 看下：
 
![](/how-to-use-hugo/2.jpg)

内容是 Markdown 格式的，+++ 之间的内容是 TOML 格式的，根据你的喜好，你可以换成 YAML 格式（使用 --- 标记）或者 JSON 格式。



### 2. 创建第一篇文章，放到 post 目录，方便之后生成聚合页面。
$ hugo new post/first.md

打开编辑 post/first.md ：

![](/how-to-use-hugo/3.jpg)



## 五、安装皮肤
去 themes.gohugo.io 选择喜欢的主题，下载到 themes 目录中，配置可见theme说明

### 1. 下载方法一
    在 themes 目录里把皮肤 git clone 下来：
    $ pwd
    /c/code/hugo
    $ mkdir themes # 创建 themes 目录
    $ cd themes
    $ git clone https://github.com/digitalcraftsman/hugo-material-docs.git

### 2. 下载方法二
    也可以添加到git的submodule中，优点是后面讲到用 travis 自动部署时比较方便。
    如果需要对主题做更改，最好fork主题再做改动。
    git submodule add https://github.com/digitalcraftsman/hugo-material-docs.git themes/hugo-material-docs

### 3. 使用皮肤
将\blog\themes\hugo-fabric\exampleSite\config.toml 替换 \blog\config.toml
注：config.toml文件是核心，对网站的配置多数需要修改该文件，而每个主题的配置又不完全一样。


### 4. 修改皮肤
    如果需要调整更改主题，需要在 themes/hugo-material-docs 目录下重新 build
    cd themes/hugo-material-docs && npm i && npm start
    
    生成主题资源文件（hugo-fabric为主题名）
    D:\git\blog>hugo -t hugo-fabric
    Started building sites ...
    Built site for language en:
    0 of 3 drafts rendered
    0 future content
    0 expired content
    8 regular pages created
    12 other pages created
    0 non-page files copied
    2 paginator pages created
    1 tags created
    1 categories created
    total in 35 ms
    将\blog\themes\hugo-fabric\exampleSite\config.toml 替换 \blog\config.toml

### 5. 修改配置文件
    根据个人实际情况，修改config.toml

## 五、启动 hugo 自带的服务器

### 1. 在你的站点根目录执行 Hugo 命令进行调试：

* 回到hugo站点目录C:\code\hugo
* $ hugo server --theme=hugo-material-docs --buildDrafts

注明：v0.15 版本之后，不再需要使用 --watch 参数了
浏览器里打开： http://localhost:1313


### 2. 在项目根目录下，通过 hugo server 命令可以使用hugo内置服务器调试预览博客。
    --theme 选项可以指定主题。也可用-t
    --watch 选项可以在修改文件后自动刷新浏览器。也可用-w
    --buildDrafts 包括标记为草稿（draft）的内容。也可以用-D

## 六、 部署到github

### 1. 新建仓库
    假设你需要部署在GitHub Pages上，首先在GitHub上创建一个Repository，
    命名为：hanchuntao.github.io （hanchuntao替换为你的github用户名）。

注意
baseUrl要在仓库setting里面查看，有可能跟仓库名不一样。
例如：https://SYSUcarey.github.io/变成了https://sysucarey.github.io/

### 2. 在项目根目录执行Hugo命令生成HTML静态页面
    $ hugo --theme=hugo-material-docs --baseUrl="https://hanchuntao.github.io/"

--theme 选项指定主题，
--baseUrl 指定了项目的网站

注意
以上命令并不会生成草稿页面，如果未生成任何文章，请去掉文章头部的 draft=true 再重新生成。
文件默认内容在，draft 表示是否是草稿，编辑完成后请将其改为 false，否则编译会跳过草稿文件。

### 3. 查看生成的页面
如果一切顺利，所有静态页面都会生成到public目录


### 4. 将pubilc目录里所有文件push到刚创建的Repository的master分支。
    $ cd public
    $ git init
    $ git remote add origin https://github.com/hanchuntao/hanchuntao.github.io.git
    $ git add -A
    $ git commit -m "first commit"
    $ git push -u origin master


> 浏览器里访问：https://hanchuntao.github.io/
![](/how-to-use-hugo/6.png)


## 七、错误处理

### 1. Unable to locate Config file
    启动 hugo 内置服务器时，会在当前目录执行的目录中寻找项目的配置文件。所以，需要在项目根目录中执行这个命令，否则报错如下：
    C:\Users\kika\kikakika\themes>hugo server --theme=hugo-bootstrap --buildDrafts --watch
    Error: Unable to locate Config file. Perhaps you need to create a new site.
      Run `hugo help new` for details. (Config File "config" Not Found in "[C:\\Users\\kika\\kikakika\\themes]")



### 2. Unable to find theme Directory
    hugo 默认在项目中的 themes 目录中寻找指定的主题。所有下载的主题都要放在这个目录中才能使用，否则报错如下：
    C:\Users\kika\kikakika>hugo server --theme=hugo-bootstrap --buildDrafts --watch
    Error: Unable to find theme Directory: C:\Users\kika\kikakika\themes\hugo-bootstrap



### 3. 生成的网站没有文章

    生成静态网站时，hugo 会忽略所有通过 draft: true 标记为草稿的文件。必须改为 draft: false 才会编译进 HTML 文件。



### 4. 默认的ServerSide的代码着色会有问题，有些字的颜色会和背景色一样导致看不见。

    解决方法：使用ClientSide的代码着色方案即可解决。（见：Client-side Syntax Highlighting）



### 5. URL全部被转成了小写，如果是旧博客迁移过来，将是无法接受的。

    解决方法：我是直接改了Hugo的代码，将URL强制转换为小写那段逻辑去掉了，之后考虑在config里提供配置开关，然后给Hugo提一个PR。如果是Windows用户可以直接https://github.com/coderzh/ConvertToHugo 下载到我修改后的版本myhugo.exe。
    Update(2015-09-03): 已经提交PR并commit到Hugo，最新版本只需要在config里增加：
    disablePathToLower: true



### 6. 文章的内容里不能像Jekyll一样可以内嵌代码模板了。最终会生成哪些页面，有一套相对固定而复杂的规则，你会发现想创建一个自定义界面会非常的困难。

    解决方法：无，看文档，了解它的规则。博客程序一般也不需要特别的自定义界面。Hugo本身已经支持了类似posts, tags, categories等内容聚合的页面，同时支持rss.xml，404.html等。如果你的博客程序复杂到需要其他的页面，好好想想是否必须吧。



### 7. 如何将rss.xml替换为feed.xml？

    解决方法：在config.yaml里加入： rssuri: “feed.xml”



### 8. 部署到github上后, 无内容
![](/how-to-use-hugo/4.png)

个人原因
hugo --theme=hyde --baseUrl="https://hanchuntao.github.io/"生成静态页面后，public中会产生相应的目录，没有把这些目录push 到远端



### 9.  部署到github上后一直不显示CSS样试

![](/how-to-use-hugo/5.png)
发现是 --baseUrl="http://hanchuntao.github.io/"的问题，要用 --baseUrl="https://hanchuntao.github.io/"

### 从github上看到的markdown没有显示图片
原因： 图片要保存在static目录下，并显在引用图片时，使用static的相对位置(例如：/how-to-use-hugo/1.png)
      生成静态网页后，需要把图片也上传到github