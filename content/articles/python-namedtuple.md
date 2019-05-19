---
title: "Python Namedtuple 源码分析"
date: 2019-05-12T21:42:13+08:00
draft: false
---

`namedtuple` 是一个简化 `tuple` 操作的工厂函数，对于普通元组我们在访问上只能通过游标的访问，在表现力上有时候比不上对象。

命名的元组实例没有每个实例的字典，因此它们是轻量级的，并且不需要比常规元组更多的内存。

假如想计算两个点之间的距离根据定义：

需要两个点的 x、y 坐标，我们可以直接使用元组表示 p1 和 p2 点

```python
>>> import math
>>> 
>>> p1, p2 = (1, 2), (2, 3)
>>> s = math.sqrt((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)
>>> 
>>> print(s)
1.4142135623730951
>>>
```

对于 p1 点的 x 坐标使用 p1[0] 表示，对阅读上有一定的困扰，如果可以使用 `p1.x` 就语义清晰了。

这个场景就是 `namedtuple` 的典型应用，让字段具有名字，使用 `namedtuple` 重写上面例子

```python
>>> import collections
>>> import math
>>> 
>>> Point = collections.namedtuple('Point', ['x', 'y'])
>>> p1, p2 = Point(1, 2), Point(2, 3)
>>> 
>>> s = math.sqrt((p1.x - p2.x)**2 + (p1.y - p2.y)**2)
>>> 
>>> print(s)
1.4142135623730951
>>>
```

好奇宝宝肯定就会想知道 `namedtuple` 是如何让字段具有名字的，先看看函数的签名

```python
namedtuple(typename, field_names, *, rename=False, defaults=None,module=None)
```

第一个和第二参数前面已经使用过了，`typename` 就是新命名元组的名字，我们最经常的就是模仿的类，所以会使用类的定义风格。`field_names` 参数用于定义字段的名字，除了上面使用 `['x', 'y']` 还可以使用 `"x y"` 或者 `"x, y"`，定义方法选择自己喜欢的就好。

`rename` 参数默认是 `False`，顾名思义就是重命名字段名字，假如我们使用了非法的变量名（比如关键字等）会被重命名成别的名字。

>[!DANGER]
>
> 这种改变定义的行为是最好不要做，除非你能保证任何人知道这个行为。


`defaults` 参数可以是 `None` 或者一个可迭代的值，根据具有默认值的字段必须在没有初始值的后面，所以`defaults` 提供的默认值都是最右匹配。

```python
>>> from collections import namedtuple
>>> 
>>> Point = namedtuple('Point', "x y z", defaults=[2, 3])
>>> p1 = Point(1)
>>> 
>>> print(p1)
Point(x=1, y=2, z=3)
>>>
```

如果定义了 `module`，则将命名元组的 `__module__ `属性设置为该值。

```python
...
    if isinstance(field_names, str):
        field_names = field_names.replace(',', ' ').split()
    field_names = list(map(str, field_names))
    typename = _sys.intern(str(typename))
...
```

进入函数的第一步先对两个基本的参数 `typename` 和 `field_names` 进行处理。

如果 `field_names` 是一个字符串就 replace 把 `,` 转化成空格，再 split 成标准的 list。 `list(map(str, field_names))` 保证了 `field_names` 的每个值都是 str 类型。
`_sys.intern` 把 typename 注册到全局中，可以加快对字符串的寻找。

```python
...
    if rename:
        seen = set()
        for index, name in enumerate(field_names):
            if (not name.isidentifier()
                or _iskeyword(name)
                or name.startswith('_')
                or name in seen):
                field_names[index] = f'_{index}'
            seen.add(name)
...
```

对于设置了 `rename=True` 会对不合法的 field\_name 重新命名，从代码中可以看出重新命名的规则是：如果不合法，判断是不是 **关键字**、是不是以 **下划线** 开头，是不是 **已经存在**，如果符合其中一项就会对用 `_{当前的 index}`变量重新命名。

```python
...
    for name in [typename] + field_names:
        if type(name) is not str:
            raise TypeError('Type names and field names must be strings')
        if not name.isidentifier():
            raise ValueError('Type names and field names must be valid '
                             f'identifiers: {name!r}')
        if _iskeyword(name):
            raise ValueError('Type names and field names cannot be a '
                             f'keyword: {name!r}')
    
    seen = set()
    for name in field_names:
        if name.startswith('_') and not rename:
            raise ValueError('Field names cannot start with an underscore: '
                             f'{name!r}')
        if name in seen:
            raise ValueError(f'Encountered duplicate field name: {name!r}')
        seen.add(name)
...
```

接下来对输入的 typename 和 field_names 经检查了一下参数，仍是使用上面的三个规则，确保 typename 和 field_names 中的元素是合法的字符串。

```python
...
    field_defaults = {}
    if defaults is not None:
        defaults = tuple(defaults)
        if len(defaults) > len(field_names):
            raise TypeError('Got more default values than field names')
        field_defaults = dict(reversed(list(zip(reversed(field_names),
                                                reversed(defaults)))))
...
```

如果设置了 defaults 参数，要最右匹配到 field_names。先使用了 `zip` 函数，把 `reversed` 后的 field_names 和 defaults 组合成元组的 list

```python
>>> field_names = ['x', 'y', 'z']
>>> defaults = [2, 3]
>>> 
>>> print(list(zip(reversed(field_names), reversed(defaults))))
[('z', 3), ('y', 2)]
>>>
```

最后在使用 `dict(reversed(...))` 转化成 dict 类型。

```python
...
    # Variables used in the methods and docstrings
    field_names = tuple(map(_sys.intern, field_names))
    num_fields = len(field_names)
    arg_list = repr(field_names).replace("'", "")[1:-1]
    repr_fmt = '(' + ', '.join(f'{name}=%r' for name in field_names) + ')'
    tuple_new = tuple.__new__
    _dict, _tuple, _len, _map, _zip = dict, tuple, len, map, zip

    # Create all the named tuple methods to be added to the class namespace

    s = f'def __new__(_cls, {arg_list}): return _tuple_new(_cls, ({arg_list}))'
    namespace = {'_tuple_new': tuple_new, '__name__': f'namedtuple_{typename}'}
    # Note: exec() has the side-effect of interning the field names
    exec(s, namespace)
    __new__ = namespace['__new__']
    __new__.__doc__ = f'Create new instance of {typename}({arg_list})'
    if defaults is not None:
        __new__.__defaults__ = defaults
...
```

这部分动态设置参数的过程，重点关注 `exec(s, namespace)` ，s 是 `__new__` 方法的定义，其中的 `arg_list` 是我们设置的属性名字会转换成 `x, y, x` 这种形式，填充的 s 中。namespace 则是 exec 过程中可使用的变量，这里传入了 `tuple_new = tuple.__new__` 用于创建一个新的 tuple。

```python
...
    @classmethod
    def _make(cls, iterable):
        result = tuple_new(cls, iterable)
        if _len(result) != num_fields:
            raise TypeError(f'Expected {num_fields} arguments, got {len(result)}')
        return result

    _make.__func__.__doc__ = (f'Make a new {typename} object from a sequence '
                              'or iterable')

    def _replace(_self, **kwds):
        result = _self._make(_map(kwds.pop, field_names, _self))
        if kwds:
            raise ValueError(f'Got unexpected field names: {list(kwds)!r}')
        return result

    _replace.__doc__ = (f'Return a new {typename} object replacing specified '
                        'fields with new values')

    def __repr__(self):
        'Return a nicely formatted representation string'
        return self.__class__.__name__ + repr_fmt % self

    def _asdict(self):
        'Return a new dict which maps field names to their values.'
        return _dict(_zip(self._fields, self))

    def __getnewargs__(self):
        'Return self as a plain tuple.  Used by copy and pickle.'
        return _tuple(self)

    # Modify function metadata to help with introspection and debugging
    for method in (__new__, _make.__func__, _replace,
                   __repr__, _asdict, __getnewargs__):
        method.__qualname__ = f'{typename}.{method.__name__}'
...
```

接着定义了一些列的方法，这些方法最后都是用于生成 namedtuple 后所拥有的方法，根据简单的注释可以很容易知道他们的用途

```python
...
    # Build-up the class namespace dictionary
    # and use type() to build the result class
    class_namespace = {
        '__doc__': f'{typename}({arg_list})',
        '__slots__': (),
        '_fields': field_names,
        '_field_defaults': field_defaults,
        # alternate spelling for backward compatiblity
        '_fields_defaults': field_defaults,
        '__new__': __new__,
        '_make': _make,
        '_replace': _replace,
        '__repr__': __repr__,
        '_asdict': _asdict,
        '__getnewargs__': __getnewargs__,
    }
    
    # _tuplegetter = lambda index, doc: property(_itemgetter(index), doc=doc)
    for index, name in enumerate(field_names):
        doc = _sys.intern(f'Alias for field number {index}')
        class_namespace[name] = _tuplegetter(index, doc)
    
    result = type(typename, (tuple,), class_namespace)
...
```

定义 `class_namespace` 传入上面定义好一系列方法，最后使用 `type` 创建出一个新的 class。

 >[!NOTE]
 >
 > Python 所有的东西都是 type 这个函数创建出来的，包括 type 本身，更多 type 相关信息参考
 > https://docs.python.org/3/library/functions.html#type


 ```python
 ...
    # For pickling to work, the __module__ variable needs to be set to the frame
    # where the named tuple is created.  Bypass this step in environments where
    # sys._getframe is not defined (Jython for example) or sys._getframe is not
    # defined for arguments greater than 0 (IronPython), or where the user has
    # specified a particular module.
    if module is None:
        try:
            module = _sys._getframe(1).f_globals.get('__name__', '__main__')
        except (AttributeError, ValueError):
            pass
    if module is not None:
        result.__module__ = module

    return result
 ...
 ```

最后需要把 module 属性设置回 result 的 `__module__` 中，这些信息会在 pickle 会被用到。

总结一下，namedtuple 创建过程大体分成三个部分：

1. 提取参数、定义 tuple 所需的方法
2. 根据参数名字动态构建 `__new__` 函数，和最后生成的 tuple 的属性可以对应上
3. 填充 class_namespace，用 `type` 函数创建一个 tuple 对象

其实在不久之前，namedtuple 还是直接使用字符串模板生成，现在这种实现方法更优雅了。