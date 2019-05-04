---
title: "Sentry Pushbear"
date: 2019-05-04T23:19:21+08:00
draft: false
---

上周写了一下 sentry 可以通过 webhook 发送错误日志给微信，但是需要自己额外搭一个服务，虽然可定制化确实强，但还是有点麻烦

于是五一期间给 sentry 写了个插件，简单安装之后，只需要填上 pushbear 的 SendKey，就可以直接在微信上接收错误提醒啦~

效果如下：

(这里缺上图，后面补)

目前我配了这四个参数：project, culprit, message 和 tags。一般已经可以快速定位错误项目和位置了，至于具体的 trace，可以点击 message 直接进入 sentry 查看

安装也超简单：

### 如果 sentry 是 docker 安装的
1. 在 onpremise/requirements.txt 里加上一行 `sentry-pushbear`
2. `docker-compose build`: 拉取插件代码
3. `docker-compose run --rm web upgrade`: 更新 web 服务，如果插件有问题这里会报错
4. `docker-compose up -d`: 重启 sentry，插件生效

### 如果 sentry 是 python 安装的
1. `pip install sentry-pushbear`
2. 重启 sentry

### 使用 pushbear 服务
在项目配置页，也就是 project->{project}->settings 页面里，点击 All integration(or plugins or Legacy Integrations) 页面，可以找到 `PushBear Notifications` 插件

![image](https://note.youdao.com/yws/public/resource/5cb652c357f03611a6f094c393f40031/xmlnote/WEBRESOURCE7dde78d9b541aa27eb0fbb4efffafa17/26087)

点击右侧开关启用插件后，再点击 `configure plugin` 就可以进入到当前 project 的插件配置页，如图

![image](https://note.youdao.com/yws/public/resource/5cb652c357f03611a6f094c393f40031/xmlnote/WEBRESOURCE1a9f8025ca51e17b005936f375cb8266/26088)

在 SendKey 这一栏里填入从 pushbear 里申请的通道 SendKey，之后，就可以点 `Test Plugin` 进行测试了，微信上会立刻收到类似这样的消息，这就表示 pushbear 安装配置成功了

(这里缺张图，后面补)

再根据个人情况，配置一下 alert rules，比如只有 fatal 级别才发微信推送，点下保存，这就算完工了~

---

顺便，如果有人没有用过 server酱，我也要强行安利一下：

![server_chan](https://note.youdao.com/yws/public/resource/5cb652c357f03611a6f094c393f40031/xmlnote/WEBRESOURCE8a2230543a7cc379748880b8db3157bd/26085)

pushbear 是在 server酱 右上角点击“一对多推送”即可，同样简洁，同样可以快速上手。

![pushbear](https://note.youdao.com/yws/public/resource/5cb652c357f03611a6f094c393f40031/xmlnote/WEBRESOURCE18934140351b5fb77cf0e7f0effe334b/26086)

server酱：http://sc.ftqq.com/3.version

pushbear: https://pushbear.ftqq.com
