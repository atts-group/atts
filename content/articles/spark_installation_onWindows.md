---
title: "Windows安装spark"
date: 2019-04-07T20:48:40+08:00
draft: false
---

## 下载安装Java，安装版本为8
[Java8下载地址](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
安装教程详见：[菜鸟教程—Java安装](https://www.runoob.com/java/java-environment-setup.html)
## 下载spark安装包
[spark2.3.3下载地址](https://www.apache.org/dyn/closer.lua/spark/spark-2.3.3/spark-2.3.3-bin-hadoop2.7.tgz)

建议安装2.3.3版本，高版本的2.4.0在运行时会报错Py4j error。
下载后解压文件夹，并将路径配置到系统变量中。

![系统变量配置](http://pp0miv3mb.bkt.clouddn.com/20190312091710994.png)

系统环境变量中配置路径如下：

![环境变量配置](http://pp0miv3mb.bkt.clouddn.com/20190407205136.png)

## 下载Hadoop支持包
[百度网盘下载地址](https://pan.baidu.com/s/19wb-gTMtZ_9x8TegbB-_Wg)
提取码：ezs5

下载后解压，并添加系统变量：

![添加Hadoop支持系统变量](http://pp0miv3mb.bkt.clouddn.com/20190407205301.png)

## 下载并安装pycharm和anaconda
具体安装教程可自行百度。

安装后，将spark下的python中的pyspark拷贝到安装的python路径下的：Lib\site-packages
然后运行pip install py4j
## 配置pycharm运行spark环境

![pycharm配置](http://pp0miv3mb.bkt.clouddn.com/20190407205405.png)

![pycharm配置](http://pp0miv3mb.bkt.clouddn.com/20190407205447.png)

根据上图进行配置后即可运行spark程序。

## 配置日志显示级别
在spark\conf目录下创建log4j.properties配置文件，该目录下有template模板，可以直接复制。

然后将其中的：log4j.rootCategory=INFO, console 修改为 log4j.rootCategory=WARN, console

## 配置cmd下pyspark在jupyter下运行
编辑spark目录下：bin\pyspark2.cmd
修改其中对应部分为以下格式：
```
rem Figure out which Python to use.
if "x%PYSPARK_DRIVER_PYTHON%"=="x" (
  set PYSPARK_DRIVER_PYTHON=jupyter
  set PYSPARK_DRIVER_PYTHON_OPTS=notebook
  if not [%PYSPARK_PYTHON%] == [] set PYSPARK_DRIVER_PYTHON=%PYSPARK_PYTHON%
)
```
