---
title: "Sentry Raven vs Sentry_sdk"
date: 2019-04-15T00:04:31+08:00
draft: false
---

上周写了 Sentry 的 Python SDK `raven` 包的工作原理，但这周发现 Sentry Team 把 SDK 又给重构了一版，现在叫做 `New Unified Version: sentry-sdk`。

但是更新工作没做彻底， 官网(https://docs.sentry.io) 上的文档虽然已经改成 `sentry-sdk` 了，但 sentry-web 服务上的各种说明还没改，而且新版 SDK 的版本号还没到 1.0(0.7.10)，raven 已经完善到 6.10.0 了

于是又读了一下这个包的代码，与之前真的大不相同了。

以下内容分两部分：

1. 对 SDK 的用户来说，都有哪些变化
2. 新 SDK 在实现方式上有什么变化

## 新旧 SDK 变化对比

简单写了个表，功能上的区别基本就是这样了，实际使用上倒是完全感受不到什么

| 对比项 | raven | sentry_sdk |
| --- | --- | --- |
| 捕捉错误的方式 | flask.got_request_exception + middleware | flask.got_request_exception + middleware |
| 获取上下文等信息的方式(flask) | 直接访问 flask.request，以及 sys.exc_info 和环境相关信息| 使用信号 appcontext_pushed, request_started 和 sys.exc_info，以及一些环境相关信息 |
| 同步？异步？ | 默认异步，用 queue.Queue 来保证 | 只支持异步，同样用 queue.Queue 来保证 |
| 发送方式 | 默认 urllib2.urlopen，可更换为 requests | 使用 urllib3.PoolManager 做 HTTP 连接池 |
| 配置方式 | 默认读取 `SENTRY_`开头的所有 flask.app 配置及超多环境变量 | 默认读取 `SENTRY_DSN`, `SENTRY_RELEASE`, `SENTRY_ENVIRONMENT` 环境变量 |
| 发送给服务端的信息 | 正常 | 多返回了 当前python环境的所有已安装包 |

感觉比较明显的改动有四个：

1. 新版在兼容 flask 时不需要传入 flask app
2. 新版少了很多配置项
3. 新版使用了 HTTP 连接池
4. 发送事件(event)更方便了

兼容 flask 的时候，只需要这样写：

```python
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

sentry_sdk.init(integrations=[FlaskIntegration()])
```

flask 是作为一个“插件”一样的东西加进去的，里面完成了信号关联，并且在信号回调里也是直接调用的 sentry API，而没有做更定制化的处理

少的那些配置，我猜是因为新版 SDK 优先实现了核心功能，剩下那些配置要不要加还不知道

HTTP 连接池加的倒是正好，因为所有发送给服务端的事件都是走的同一个 API: `{scheme}://{host}/api/{project_id}/store`

至于发送 event 更方便，则是因为新版把 API 的概念明确做到了 SDK 里，并且只需要 

```python
from sentry_sdk import capture_message
capture_message('this message will be sent to sentry server directly')
```

就可以直接发送了。而之前由于所有的一切都与 client 有关，都需要依赖 client 对象，因此必须先获取到 client 对象，才能做后面的事。

那么新版是怎么做到可以不依赖特定 client 对象的呢？

## 新 SDK 实现方式详细说明

还是先看看代码目录

```
sentry_sdk
├── integrations    # 类似与插件，中间件，钩子的东西，用于与其他框架和环境
├── __init__.py
├── _compat.py      # 为各个 python 版本做兼容
├── api.py          # 用户可直接使用的 API 方法
├── client.py       # 包含 Client 类，用于构建时间并发送给服务端
├── consts.py       # 一些常量定义如版本号
├── debug.py        # debug 支持
├── hub.py          # 新版最关键的类，用于并发管理
├── scope.py        # 保存所有待发送给服务端的周边信息
├── transport.py    # 同之前，实际发消息给服务端的东西
├── utils.py        # 一些内部工具
└── worker.py       # 执行发送任务的后台 worker
```

结构很清晰，其中 client, transport, worker, processor 等都与之前概念相同，这里只说一下几个新增概念

1. api
2. scope
3. hub

## Unified API

关于这个，官方文档里有详细说明，参见：https://docs.sentry.io/development/sdk-dev/unified-api，最后点阅读全文可以直接跳转过去看

python 新版里给出了 8 个可以全局调用的 API：

1. `capture_event(event, hit=None)`: 发送事件给 sentry 服务端
2. `capture_message(message, level=None)`: 发送一个字符串给 sentry 服务端
3. `capture_exception(error=None)`: 将一个异常发送给 sentry 服务端
4. `add_breadcrumb(crumb=None, hint=None, **kwargs)`: 增加 breadcrumb
5. `configure_scope(callback=None)`: 修改 scpoe 配置内容
6. `push_scope(callback=None)`: 新增一个 scope 层
7. `flush(timeout=None, callback=None)`: 等待 timeout 秒来发送当前所有事件
8. `last_event_id()`: 上一个提交的 event 的 id

对这些 API 来说，任何地方只要 `from sentry_sdk import ` 之后就可以直接用了（前提是已经 init 过了）

## scope

包含要随着事件发送给服务端的各种数据，包括上下文，扩展信息，事件级别等等。另外各个 processor 里获取的信息，也会存在 scope 里，并随着事件发送给服务端

scope 和 client 是一一对应的，也就是说，一个 client 只会对应一个 scope，因此同一个 client 发送的多条 event，只会获取一次 scope，除非又做了单独配置

## hub

是新版实现中最关键的一个东西，我们先来看一下新版里 Hub 类的描述

```python
class Hub(with_metaclass(HubMeta)):  # type: ignore
    """The hub wraps the concurrency management of the SDK.  Each thread has
    its own hub but the hub might transfer with the flow of execution if
    context vars are available.

    If the hub is used with a with statement it's temporarily activated.
    """

    _stack = None  # type: List[Tuple[Optional[Client], Scope]]

    def __init__(self, client_or_hub=None, scope=None):
        # type: (Union[Hub, Client], Optional[Any]) -> None
        if isinstance(client_or_hub, Hub):
            hub = client_or_hub
            client, other_scope = hub._stack[-1]
            if scope is None:
                scope = copy.copy(other_scope)
        else:
            client = client_or_hub
        if scope is None:
            scope = Scope()

        self._stack = [(client, scope)]
        self._last_event_id = None  # type: Optional[str]
        self._old_hubs = []  # type: List[Hub]
```

怎么理解呢，就是说 Hub 并不参与 sentry 客户端的原有逻辑，捕获异常，发送给服务端，这些东西没有 Hub 也都可以正常完成，Hub 只是做了一个并发管理，让不同线程都可以在任何地方直接获取到当前的 client 和其对应的 scope，从而完成“捕获-发送”流程。

我们来看一下 Hub 的构造函数，前面的一大段只做了一件事，就是初始化 self._stack，这里面包含有 client 和 scope 两个参数，有了这两个，正常逻辑就可以走通了。剩下的两个参数，self._last_event_id 不用说了，self._old_hubs 也是一个栈，是在用 with 语句使用 hub 的时候，可以在新的上下文里进行操作，而不会影响到原有的上下文。


```python
class Hub(with_metaclass(HubMeta)):
    def __enter__(self):
        # type: () -> Hub
        self._old_hubs.append(Hub.current)
        _local.set(self)
        return self

    def __exit__(
        self,
        exc_type,  # type: Optional[type]
        exc_value,  # type: Optional[BaseException]
        tb,  # type: Optional[Any]
    ):
        # type: (...) -> None
        old = self._old_hubs.pop()
        _local.set(old)
```

可以看到 Hub 用在 with 里时十分简单，但是那个 `_local` 是什么东西？

```python
_local = ContextVar("sentry_current_hub")
```

_local 与 Hub 在同一个文件里定义，这里的 ContextVar 是在 python3.7 引入的新特性，可以理解为线程级别的上下文变量，详细参见 PEP567。他的作用就是保存当前线程的 HUb 对象，使得同一个线程里，任何通过 _local 得到的 Hub 都是同一个。但是我们知道下划线开头的变量属于内部变量，不建议外部使用，这里怎么让其他地方可以获取到他呢？

```python
def with_metaclass(meta, *bases):
    class metaclass(type):
        def __new__(cls, name, this_bases, d):
            return meta(name, bases, d)

    return type.__new__(metaclass, "temporary_class", (), {})


class HubMeta(type):
    @property
    def current(self):
        # type: () -> Hub
        """Returns the current instance of the hub."""
        rv = _local.get(None)
        if rv is None:
            rv = Hub(GLOBAL_HUB)
            _local.set(rv)
        return rv

    @property
    def main(self):
        """Returns the main instance of the hub."""
        return GLOBAL_HUB

class Hub(with_metaclass(HubMeta)):
    pass

...

GLOBAL_HUB = Hub()
_local.set(GLOBAL_HUB)
```

在第一次看到 Hub 类定义的时候，应该就注意到 `with_metaclass(HubMeta)` 了吧，这里 with_metaclass 我猜可能是为了兼容老版本，实际上就是给他定义了个元类，并且设置了一个只读参数 Hub.current，效果是从 _local 里或者 GLOBAL_HUB 里获取一个 Hub 实例，并且返回。这里有一点要注意，就是 GLOBLE_HUB 是模块级别的变量，新线程找不到 _local 时都会用这个。

而 HubMeta.main 是直接返回了 GLOBAL_HUB，我看了下这个函数只在 AtexitIntegration 也就是获取到 shutdown signal 时使用，那时会直接调用 hub.client.close 关掉客户端以及 transport，也就是 SDK 完成使命光荣退出了

看到这里应该要总结一下了，但是稍等，我们再看一下对外暴露的 API 是怎么实现的

```python
def capture_message(message, level=None):
    # type: (str, Optional[Any]) -> Optional[str]
    hub = Hub.current
    if hub is not None:
        return hub.capture_message(message, level)
    return None
```

很简单吧，Hub 类持有着 client 和 scope，所有的操作都直接用 Hub 类操作即可

总结：

1. sentry_sdk 明确了 API 的概念，`sentry_sdk.init()` 完成后，任何地方都可以直接使用相应 API 完成操作
2. 对各种框架的兼容使用了 Integration 的概念，在其内部只做很小的 hook 或关联，实际操作还是通过 API 来完成
3. 调用 API 的时候，通过 Hub.current 获取到当前线程的 Hub 对象，并在 Hub._stack 里拿到最近的 client 和 scope，然后就可以像旧 SDK 一样对 client 进行各种操作了。

最后，关于多线程下各种情况的处理，按说应该是一个比较重要的部分，但是我还没有做测试，就先放一下吧


