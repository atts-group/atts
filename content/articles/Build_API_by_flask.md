---
title: "Python下使用Flask建立API"
date: 2019-04-10T19:46:45+09:00
draft: false
---

## 前言
最近在学习微信小程序，前后端数据交互时，需要API提供数据操作。便学习通过python建立API。

## 示例

### 创建获取数据API
```python
@app.route('/api/v1.0', methods=['GET'])
def get_data():
    data = function  # function为从数据库中获取内容的操作函数。
    return jsonify({'data':data})  # 返回json格式的数据。
```

### 操作结果
![返回数据](http://pp0miv3mb.bkt.clouddn.com/20190410200053.png)


### 创建数据提交API
```python
@app.route('/post/', methods=['POST'])
def post_data():
    args = request.args.get('arg_name')  # request.args.get提供了从url获取参数的功能，通过参数将数据传递后后端
    status = post_function(args)  # post数据的函数，成功返回200，失败返回错误信息。
    return jsonify({'status':status})  # 将信息返回给前端
```

上述情况中参数传递形式为：
```
http://127.0.0.1:5000/post/?name=小李&age=20  # name和age为参数名, 后面的值为具体参数值。
```

### 动态url规则下可以直接获取参数：
```python
app.route('/post/<id>', methods=['POST'])
def post_data(id):  # 直接将<id>的值作为函数参数
    status = post_function(id)  # psot id
    return jsonify({'status':status})
```

上述情况参数传递形式为：
```
http://127.0.0.1:5000/post/1  # 1为参数
```

