---
title: "Python_i18n"
date: 2019-04-21T22:55:21+08:00
draft: false
---

这周有一些 API 需要做国际化，于是看了一下通用的解决方案

## GUN 国际化通用方法: gettext

通用的解决方案是，使用 gettext 工具，先将源码中的字符串提取至 .pot 文件中，再复制成各个 .po 文件并填充相应的语言，填充完毕后，再编译成 .mo 文件。

读取的时候，从一个 .mo 文件里得到的内容会转换成一个简单的 hash map(python 中就是单纯的 dict)，使用时根据语言和原始字符串到这里查找，即可得到相应的“翻译后的字符串”并返回。

我们可以看一下前段时间刚刚上线的 python 官方简中文档，这是术语表的 .po 文件链接：https://github.com/python/python-docs-zh-cn/blob/3.7/glossary.po

参照这个图片，可以看到， .po 文件里会把原文里的每个字符串，都这样对照着给一个翻译

说到这里我们插播一下，python 中文文档翻译进度已经达到 30% 了，想参与翻译吗？参照我这个帖子开动吧，或者直接留言，我拉你进翻译群~

说回到国际化，gettext 是一个 GNU 工具，各种语言对它都有支持，官方文档在这里：https://www.gnu.org/software/gettext/manual/gettext.html

在 shell 下它一共提供三个命令：
1. xgettext: 从源文件中提取 .pot 文件
2. msginit: 将 .pot 准备成对应语言的 .po 文件
3. msgfmt: 将 .po 文件编译成 .mo 文件

具体的用法就不详细说了，搜一下有很多，我们这里说一下 python 中对其的实现

python 中内置了一个 gettext 包，其实是为 GUN gettext 提供一个 python 接口，使用时只要指定好语言以及 .mo 文件，就可以快速拿到 translation 对象，调用其 `gettext` 方法即可实现翻译

## Python 中的国际化: Babel

然而在 python 中，还有一个更好的库用来实现国际化: Babel，官方文档：http://babel.pocoo.org/en/latest

> 注：不是下一代 js 编译器的那个 babel，虽然名字一样

Babel 相比内置的 gettext 包提供了更多好用的功能，比如类似于 Java 中的 Locale 类，它详细规定了一个语言包含的各个要素，比如

```
from babel import Locale
a = Locale.parse('zh_CN')
```

用 debug 模式看一下 a，删掉部分不太直观的内容后，我们至少可以看到这些：
```
a = {Locale} zh_Hans_CN
 character_order = {unicode} u'left-to-right'
 display_name = {unicode} u'中文 (简体, 中国)'
 english_name = {unicode} u'Chinese (Simplified, China)'
 first_week_day = {int} 6
 language = {unicode} u'zh'
 language_name = {unicode} u'中文'
 min_week_days = {int} 1
 script = {unicode} u'Hans'
 script_name = {unicode} u'简体'
 territory = {str} 'CN'
 territory_name = {unicode} u'中国'
 text_direction = {unicode} u'ltr'
 variant = {NoneType} None
 variants = {LocaleDataDict} <babel.localedata.LocaleDataDict object at 0x1103c6610>
 weekend_end = {int} 6
 weekend_start = {int} 5
 ```

其中有几个参数是比较重要的，也是我们做国际化时需要注意的：
1. language: 语言，最基本的语言代码，比如 zh 是中文，en 是英文。遵循 ISO-639-1
2. territory: 国家和地区代码，例如 CN 是中国，HK 是香港。遵循 ISO 3166-1
3. script: 书写方式，例如 Hans 是简中，Hant 是繁中。遵循 ISO_15924
4. variant: 变体，没找到合适的资料，不过我猜是类似于 cmn 官话，yue 粤语，nan 闽南语这类的。不过这个字段只是存在，但并没有实际支持。

> 如果想具体了解，可以去看 RFC 5646，里面对这个东西做了详细定义

而在实际使用时，一般根据 language 和 territory 两项进行区分也就足够了

同时，Babel 还干了好多事，比如提供了一个 pybabel 命令来代替 gettext 的那三句，以及对日期时间等的支持，用起来还是比较舒服的。

最后，用在 flask 里，又是怎么做的呢？

## Flask 中的国际化: Flask-Babel

有一个很简单的库，叫 Flask-Babel，官方文档：https://pythonhosted.org/Flask-Babel

这个库作为一个 flask 插件，也支持一些基本的功能：
1. 设置语言包目录
2. 设置默认语言
3. 设置在 request 上下文中获取语言的 callback 函数

但是它有一个致命的问题：在每次请求中，如果当前请求中有字符串需要被翻译，它就会去遍历指定的语言包目录，尝试找到对应的 .mo 文件，并且 load 到内存，然后再进行翻译。

注意，是每次请求都执行一遍整套操作

我不知道这里为什么被设计成这样，但是脑海中自然地回想起清风老师对 flask 生态的评价“flask 的相关库真是一个赛一个得烂”...

好在是，为了保证“同一个进程上下文中只需要 load 一次”，它在执行时也会先判断 `request.babel_locale` 和 `request.babel_translations`，如果不存在再去尝试遍历 + load 文件。

于是我的做法是提前把翻译文件加载上，再在 before_request 里设置上这两个变量，以防止它一直去加载

以上，就是我在了解 python 国际化方案时查到的资料，放在这里给自己留个备份，也希望有人看见之后能有帮助~

