---
title: "Sentry Python Sdk"
date: 2019-04-07T23:58:18+08:00
draft: false
---

> Sentry 是一个开源的实时错误报告工具，支持 web 前后端、移动应用以及游戏，支持 Python、OC、Java、Go、Node、Django、RoR 等主流编程语言和框架 ，还提供了 GitHub、Slack、Trello 等常见开发工具的集成。

这周重新用 docker 部署了一下 Sentry server，比 python 部署确实方便多了，docker-compose 官方都给写好了，改改配置就可以直接上

server 端部署好之后，又看了一下 client 端是怎么做的。就感觉这个 SDK 做的真好，接入成本极低，以 Flask 为例，只要加上两行即可：

```
from raven.contrib.flask import Sentry

sentry = Sentry(app, dsn='http://00d5b7d6d7f1498687430d160fd48ea8:ae6eaaf3c8d24d3f98537453da1f6a4f@localhost:9000/2')
```

于是仔细读了读 SDK 的实现，主要研究三个问题：
1. sentry 是怎么把 SDK 写得如此简洁的？
2. sentry 是如何捕捉到要发送的错误信息的？
3. sentry 是如何把错误信息发送到 server 端的？

注：以下使用的语言及 package 版本为：
* python 3.6
* raven 6.10.0
* Flask 1.0.2

先看一下目录结构：
```
raven
├── conf    		# 配置相关
├── contrib 		# 适配各框架的代码
├── data    		# 证书等
├── handlers		# 日志记录等
├── scripts 		# 测试脚本
├── transport   	# 实际发消息给服务端的东西
├── utils   		# 一些内部工具
├── __init__.py
├── base.py 		# 最主要的 Client 类
├── breadcrumbs.py  # 一个特殊概念，还没搞很懂
├── context.py      # 上下文相关
├── events.py       # 事件，是与服务端交互的基本单位
├── exceptions.py   # 异常类
├── middleware.py   # wsgi中间件
├── processors.py   # 数据处理相关
└── versioning.py   # 获取 git 版本或 pkg 版本
```

最核心的，是 base.py 里的 Client 类，所有的操作都是围绕它来展开的。但是由于 SDK 的封装，我们在使用默认配置时并未直接接触到它，而是使用的 raven.contrib.flask.Sentry。下面我们写一段最简单的代码，然后顺着看下去

```
from flask import Flask
from raven.contrib.flask import Sentry

app = Flask(__name__)

sentry = Sentry(app, dsn='http://00d5b7d6d7f1498687430d160fd48ea8:ae6eaaf3c8d24d3f98537453da1f6a4f@localhost:9000/2')

@app.route('/')
def index():
    return 'index\n'

@app.route('/bad')
def bad():
    return 1/0

if __name__ == '__main__':
    app.run('0.0.0.0', 8888, debug=True)
```

这段代码创建了一个最简单的 Flask app，然后将其传入 raven.contrib.flask.Sentry 中，并传入 dsn。dsn 就是一个字符串，但包含了很多信息，它会在 conf.remote.RemoteConfig 中被处理，处理结果如下：

### dsn

1. schema: `'http'`，标记给服务端发送请求的方式，同时也可以指示使用哪种 raven.transport，比如写 'requests+http' 就是用 requests 包直接发送请求，写 'gevent+http' 就是用 gevent 包异步发送请求
2. public_key: `'00d5b7d6d7f1498687430d160fd48ea8'`，用户名，没有这个的话服务端不会接收请求
3. secret_key: `'ae6eaaf3c8d24d3f98537453da1f6a4f'`，密码，新版已经废弃，不建议继续使用
4. base_url: `'http://localhost:9000'`，是服务端地址
5. project: `'2'`，是在 sentry 的 web 页面里创建的项目的编号
6. options: 是 url.query，我这里内容为空
7. transport: 新版建议 Transport 应在初始化 Client 时明确传入，而不是用 schema 的方式配置。但仍然支持着这个功能。

这里详细说一下 transport，顺便就可以解决掉我们刚才提出的第三个问题：sentry 是如何把错误信息发送到 server 端的？

### transport

sentry 中的 transport 有两类，同步的和异步的，异步的需要继承 AsyncTransport 和 HTTPTransport，同步的只需要继承 HTTPTransport，如果想增加新的 transport，只需要实现其规定的方法，然后传入 Client 即可：

同步的有：
* HTTPTransport
* EventletHTTPTransport
* RequestsHTTPTransport

异步的有：
* ThreadedHTTPTransport
* GeventedHTTPTransport
* TwistedHTTPTransport
* ThreadedRequestsHTTPTransport
* TornadoHTTPTransport

默认 transport 是在 conf.remote.DEFAULT_TRANSPORT 中定义的，当运行环境是 Google App Engine 或 AWS Lambda 时，使用 HTTPTransport(同步)，否则使用 ThreadedHTTPTransport(异步)

ThreadedHTTPTransport 内部用 FIFO Queue + 新开线程的方式来实现异步，这里我们就不用太担心其性能问题了。而发送请求用的是 HTTPTransport 的 urllib2，超时时间5秒，没有重试

### base.Client

接下来，我们来看一看初始化 Client 的时候，都干了些什么，顺便在这里解决掉第二个问题: sentry 是如何捕捉到要发送的错误信息的？

```
class Client(object):
    def __init__(self, dsn=None, raise_send_errors=False,
    transport=None, install_sys_hook=True,
    install_logging_hook=True, hook_libraries=None,
    enable_breadcrumbs=True, _random_seed=None, **options):
```

先看看可传入的参数：
* raise_send_errors: 没找到合理的用法，无视
* transport: 上面有说，不建议用 dsn.schema 来控制 transport，最好应该在这里传入
* install_sys_hook: 默认是True，作用是修改 `sys.excepthook`，把自己的异常处理函数放进去
* hook_libraries: 对 httplib 和 requests 库做了些操作，没搞懂用处
* enable_breadcrumbs: 是否开启此功能
* _random_seed: sentry 可以设置只有部分异常会被发送到服务端，这个值是生成随机数的种子
* 其他参数

其中，`install_sys_hook` 是重点，`Client.__init__` 里除了进行各种初始化外，最重要的一件事就是这个了

```
def install_sys_hook(self):
    global __excepthook__

    if __excepthook__ is None:
        __excepthook__ = sys.excepthook

    def handle_exception(*exc_info):
        self.captureException(exc_info=exc_info, level='fatal')
        __excepthook__(*exc_info)
    handle_exception.raven_client = self
    sys.excepthook = handle_exception
```

可以看到，这里在原有内置函数的基础上，加了一句 `self.captureException`，当一个异常未被 catch 住时，就会调用 sys.excepthook，同时也就发出了发出了请求

至于 self.captureException 内部，简单来说就做三件事：
1. 获取上下文及各种信息，用到了 sys.exc_info(), flask._request_ctx_stack, flask._app_ctx_stack 和 breadcrumbs 等
2. 到处记日志
3. 构建消息体，选择 transport，发送

于是，第二个问题，我们已经知道 sentry 的思路了：用 hook 来获取所有未处理的异常

然而，对 flask 而言，事情并没有这么简单，因为在 flask 里，推荐的异常处理是 `@app.errorhandler`，同时 sys.excepthook 永远不会被调用

那怎么办？我们看一下 raven.contrib.flask 吧

### raven.contrib.flask.Sentry

```
class Sentry(object):
    def __init__(self, app=None, client=None,
    client_cls=Client, dsn=None, logging=False,
    logging_exclusions=None, level=logging.NOTSET,
    wrap_wsgi=None, register_signal=True):
```
这个参数就容易懂多了
* app: flask app
* client: 即上文的 Client，可以自己定制后传入，不定制的话就默认生成一个
* client_cls: Client 类，用来默认生成 Client 对象，不过这个参数没什么意思
* dsn: 开头就有说
* logging, logging_exclusions，level: 日志定制
* wrap_wsgi: 是否将 sentry 加入 flask 中间件
* register_signal: 是否将 sentry 异常处理注册至 flask 的 got_request_exception 信号

这里的关键是最后一个参数

默认情况下 register_signal 被设置为 True，于是它会把一个 capture_exception 函数注册到 flask 的 got_request_exception 上

而 flask 的 got_request_exception 会在 flask.app.handle_exception 的开头，把当前异常 send 出去，然后再执行原有逻辑

到这里，是不是终于可以说，第二个问题也搞明白了？当发生了无法处理的异常时，flask 先用信号把异常发给 sentry.client，然后 sentry 用 sys.exc_info() 获取上下文，再把拼装好的信息传给相应 passport，最后发送给服务端

但是，在做测试的时候，我们可能会发现，发生一个异常的同时，服务端收到了两个一毛一样的 event，这是怎么回事？

答案就在 raven.contrib.flask.Sentry 的一个初始化参数里：wrap_wsgi

```
if wrap_wsgi is not None:
    self.wrap_wsgi = wrap_wsgi
elif self.wrap_wsgi is None:
    # Fix https://github.com/getsentry/raven-python/issues/412
    # the gist is that we get errors twice in debug mode if we don't do this
    if app and app.debug:
        self.wrap_wsgi = False
    else:
        self.wrap_wsgi = True
if self.wrap_wsgi:
    app.wsgi_app = SentryMiddleware(app.wsgi_app, self.client)
```

已知：
1. 在中间件 raven.middleware.Sentry.client 里，对所有未处理的异常，会向 sentry 服务端发送一次请求
2. production 模式下，发送完 got_request_exception 信号后，会 `return InternalServerError()`。而 debug 模式下则是把异常重新抛出

因此当 debug 模式 + 有中间件时，`raven.contrib.flask.Sentry.client`(信号发送) 和 `raven.middleware.Sentry.client`(中间件异常捕捉发送) 都会捕捉到这个异常，并发送给服务端。而 production 模式下，只有信号的那一次，中间件不会发

上面的代码中可以看到，这个问题被修复过一次了，但在我最开头的代码里，`flask.app.debug = True` 是在最后才运行的，传给 Sentry 的时候，还是 `app.debug = False`，因此 https://github.com/getsentry/raven-python/issues/412 仍然会发生，临时解决方式就是把 `app.debug = True` 放到初始化 Sentry 前就好

好像写的有点长了，最后终于说到了第一个问题，sentry 是怎么把 SDK 写得如此简洁的？

我认为答案是其丰富的配置项和默认设置，以及对环境变量和全局变量的灵活使用，我真是一边看代码，一边感慨这思路我真得赶紧抄过来...

---

SDK 里还有一些内容文章里没有涉及到(主要我也还没看)，但比较重要的部分都在这里了，总结一下吧：

1. 初始化 Client 类时，会从环境变量里获取各种配置，从 dsn 里确定 remote 服务端，选定 transport 并初始化各种 logger, 上下文等等
2. 设置 hook，或者其他手段，保证在发生异常时，能够获取得到异常及上下文
3. 同步/异步 发送消息给服务端，同时不让 sentry 占用太多资源

TODO: 
1. breadcrumbs 到底是干啥的
2. 其他框架都是怎么和 sentry 结合的
