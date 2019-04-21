---
title: "Exmail Smtp TLS"
date: 2019-04-15T00:06:16+08:00
draft: false
---

配置腾讯企业邮箱 exmail 时，虽然官方文档上的 SMTP 端口是 465，但那是支持 SSL 校验验证的，如果客户端只支持 TLS 的话，需要把 SMTP 端口配置成 587，才能配置成功
