---
title: "Sentry Wechat"
date: 2019-04-28T23:49:25+08:00
draft: false
---

这周给 sentry 监控多做了一个发送途径

目前我常用的 notification 途径有：
1. 邮件
2. slack
3. 微信

对 sentry 来说，email 和 slack 已经是内置支持的了，甚至 slack 还支持对收到的消息进行操作，比如 assign 给某人，或者标记 resolved

对微信的推送没有显式的支持，但 sentry 提供了 webhook，可以用这种方式来曲线救国

因此需要两个东西：
1. 从 sentry 接收消息的服务
2. 能推送微信消息的服务

对于第二点，现在有几个十分方便的解决方式，从最开始的 server酱，到升级版的 PushBear，使用体验都十分丝滑柔顺，也真的推荐大家前去实验

那么第一点要怎么做？

sentry 提供了官方的 webhook 工具：https://github.com/getsentry/webhook

当然如果使用 docker 安装，或者版本够高的话，这个插件已经内置了。也就是填写一个 url，然后设定规则（比如默认规则是当某个 issue 第一次被触发时），那么当满足这个规则时，sentry 就会往这个链接发一个请求，同时在 json 里带上以下数据：

```
{
    'project_name': 'woko',
    'message': 'This is an example Python exception',
    'id': '1002921092',
    'culprit': 'raven.scripts.runner in main',
    'project_slug': 'woko',
    'url': 'https://sentry.io/organizations/woko/issues/0000000000/?project=00000000&referrer=webhooks_plugin',
    'level': 'error',
    'triggering_rules': [],
    'event': {},
    'project': 'hcmlink',
    'logger': None
}
```

注意其中的 event 字段，内容其实超多，这里因为展示不方便我就删掉了，而且对提示来说，我们主要关注的是 project_name, message, culprit, level, 再加上一个跳转用的 url 就好了

拿到这个数据后，无论是再发邮件，发微信，做错误分析，或者是其他任意什么操作，就都没有任何限制了

我们可以先在本地启动一个简单的脚本

```

from flask import Flask, request

app = Flask(__name__)


@app.route('/notice/pushbear')
def pushbear():
    print(request.json)
    return ''


if __name__ == '__main__':
    app.run('0.0.0.0', 8888, debug=True)

```

然后在 sentry -> project -> settings -> alerts -> webhook 下填入我们启动的这个服务的链接：

```
http://0.0.0.0:8888/notice/pushbear
```

然后尝试给 sentry 上推一个错

可以在我们刚刚启动的服务里看到，sentry 发来了一个请求，带上了这些参数

我们手动处理一下这些参数，拼成合适的 text 和 desp，就可以发送给微信了

到这里，sentry 发送错误提示到微信的功能就已经完成了

但是，我们可能没有合适的公网地址，来部署这个无关紧要的转发服务，这里有两个方案：
1. 在内网部署，给 sentry 的 webhook 地址里直接写内网地址
2. 把这个功能做成一个 sentry 插件

对于方式二，要怎么做呢

还是参考官方文档：https://docs.sentry.io/workflow/integrations/integration-platform

我简单看了一下，这里允许自己写 integration 作为插件，这周时间不够了，五一期间我尝试写一下看看，如果能用的话，再来分享~
