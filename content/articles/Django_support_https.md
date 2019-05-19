---
title: "Django同时支持http/https"
date: 2019-05-12T22:11:42+08:00
draft: false
---

##  一、django中的HTTPS
HTTPS在web应用中与web服务器有关，比如搭建nginx+django应用，通过反向代理https和http请求重定向到django的http请求上，https证书在web服务器上配置，与django应用无关。当反向代理也是走https请求时，django则需要通过插件使django可支持https。



## 二、 django中的SECURE_SSL_REDIRECT配置
在settings.py中添加SECURE_SSL_REDIRECT = True,默认下配置为SECURE_SSL_REDIRECT = False

### 1. 设置SECURE_SSL_REDIRECT = True
此时在浏览器发出http请求时django会重定向到https上。 

以 $ python manage.py runserver启动应用，发出http请求后django后台日志如下：
"GET / HTTP/1.1" 301 0
Self-signed SSL certificates are being blocked:Fix this by turning off 'SSL certificate verification' in Settings > General...


但此时web应用是不支持https的，报错如下
You're accessing the development server over HTTPS, but it only supports HTTP

### 2. 设置SECURE_SSL_REDIRECT = False
此时http请求不会跳转到https,http此时django能正确访问。如果直接请求HTTPS时会报错如下： You're accessing the development server over HTTPS, but it only supports HTTP.



## 三、django的https支持：sslserver插件
### 1.如果django需要HTTPS支持，可安装有sslserver插件:
``` python
$ pip install django-sslserver
```

### 2. 在settings.py中添加配置
``` python
SECURE_SSL_REDIRECT = False
INSTALLED_APPS = (
    ...
    "sslserver",
    ...
)
```

### 3. 自带证书启动django应用
``` python
$ python manage.py runsslserver
```

### 4. 指定证书启动django应用
``` python
$ python manage.py runsslserver --certificate /path/to/certificate.crt --key /path/to/key.key 0.0.0.0:8000
```
当SECURE_SSL_REDIRECT = False时，http请求无响应，https请求能正确访问。 
当SECURE_SSL_REDIRECT = True时，http请求会重定向https，此时django支持https，可正确访问。
