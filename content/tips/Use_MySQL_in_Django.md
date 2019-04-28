---
title: "Django中使用MySQL数据库"
date: 2019-04-27T9:06:05+08:00
draft: false
---

在项目settings.py中修改如下内容

```
DATABASES={
    'default': {
        'ENGINE': 'django.db.backends.mysql',  # 数据库连接引擎
        'NAME': '',  # 数据库名
        'USER': '',  # 用户账号
        'PASSWORD': '',  # 用户密码
        'HOST': 'localhost',
        'PORT': 3306  # 连接端口
    }
}
```