---
title: "Django中Mysql的使用"
date: 2019-05-12T22:00:34+08:00
draft: false
---

## 1. 数据库设置
```python
settings.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'autotest',
        'USER': 'root',
        'PASSWORD': '123456',
        'HOST': '127.0.0.1',
        'PORT': '3306',
    }
}
```

## 2. models.py
```python
from django.db import models
from django import forms
from datetime import datetime

# Create your models here.
class indexUsers(models.Model):
    username = models.CharField(max_length=30,verbose_name="姓名" )
    age = models.IntegerField(default=3, verbose_name="年龄")
    phone = models.IntegerField(default=11, verbose_name="电话")
    addtime = models.DateField(default=datetime.now, blank=True, null=True, verbose_name="添加时间")

    class Meta:
        verbose_name = u'用户管理'
        verbose_name_plural = u'用户管理'

    def __str__(self):
        return self.username
```

## 3. 创建一个能够建立数据库表的文件
```python
D:\python_workspace\autotest>python manage.py makemigrations
Migrations for 'testtemplate':
  testtemplate\migrations\0001_initial.py
    - Create model indexUsers
```

0001_initial.py文件的本质，其实就是一个创建数据库表的文本
```python
D:\python_workspace\autotest>python manage.py sqlmigrate testtemplate 0001
BEGIN;
--
-- Create model indexUsers
--
CREATE TABLE `testtemplate_indexusers` (`id` integer AUTO_INCREMENT NOT NULL PRIMARY KEY, `username` varchar(30) NOT NULL, `age` integer NOT NULL, `phone` integer NOT NULL, `addtime` date NULL);
COMMIT;

D:\python_workspace\autotest>
```

## 4. 创建数据库表
```python
D:\python_workspace\autotest>python manage.py migrate
```