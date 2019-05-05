---
title: "在微信小程序中切换Tab的同时挑战Swiper"
date: 2019-04-21T22:58:19+08:00
draft: false
---

## 场景说明：
在首页面中通过点击事件，跳转到另一个Tab页面中。同时根据点选的内容，在跳转到的Tab页面中，跳转到不同的加载不同的swiper。

## 实现方式：
1. 在Tab的wxml中将swiper设置不同的currentID，借此来标识不同的swiper。
2. 在js中撰写swiper切换函数。具体可百度此部分内容。
3. 在app.js中设置全局变量current。并在Tab页面Js中引入app。
4. 将全局变量与Tab页面js中的current进行绑定。然后在首页面中设置跳转函数的同时，修改全局current。

## 实现效果：
通过首页中修改current，然后在Tab页面中根据全局current来实现不同swiper的转换。