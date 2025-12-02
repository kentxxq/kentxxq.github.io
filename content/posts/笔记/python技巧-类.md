---
title: python技巧-类
tags:
  - blog
  - python
date: 2019-11-26
lastmod: 2023-07-11
categories:
  - blog
keywords:
  - "python"
  - "元类"
  - "类方法"
  - "静态方法"
description: "最近把手上的事情都忙完了。准备来好好巩固自己的python知识。为什么标题是技巧呢，因为这部分是它和其他语言最大的不同，或者说特点。要玩得6，不熟这一些知识点，肯定是不行"
---

## 简介

最近把手上的事情都忙完了。准备来好好巩固自己的 [[笔记/point/python|python]] 知识。为什么标题是技巧呢，因为这部分是它和其他语言最大的不同，或者说特点。要玩得 6，不熟这一些知识点，肯定是不行。

## python 的类

python 可以用函数式编程。也支持面向对象编程。

在使用函数式编程的时候，多数都是用来写脚本。同时这也是 python 最开始发光发亮的点。但是在处理结构性数据以及架构项目的时候，面向对象的优势就会凸显出来。同时也有很多的黑魔法让你快速完成原型的构造。

### 先说 type 函数

我们经常用 type 函数来查看对象的类型信息。但还有一个用法，就是用 type 来生成对象。当你在写 python class 代码的时候，解析器遇到 class 代码块，就会解析 class 结构，然后用 type 来构造对象。  

```python
# name代表类名，base代表父类或者说基类，attrs为字典形式，代表属性值。
type(name, base, attrs)
```

### type 和元类

```python
class TMetaClass(type):
    def __new__(cls, name, base, attrs):
        print('in TMetaClass new')
        return type.__new__(cls, name, base, attrs)

    def __init__(self, object_or_name, bases, dict):
        print('in TMetaClass init')
        super().__init__(object_or_name, bases, dict)


class Person(metaclass=TMetaClass):
    def __new__(cls):
        print('in Person')
        return object.__new__(cls)

    def __init__(self):
        print(self.__class__.__name__)
        super().__init__()

    def test(self):
        print('Person test..')


class Man(Person):
    def __new__(cls):
        print('in Man')
        return object.__new__(cls)

    def test(self):
        print('Man test..')


print('-'*20)
kentxxq1 = Person()
kentxxq1.test()

print('-'*20)
kentxxq2 = Man()
kentxxq2.test()
# 结果
# in TMetaClass new
# in TMetaClass init
# in TMetaClass new
# in TMetaClass init
# --------------------
# in Person
# Person
# Person test..
# --------------------
# in Man
# Man
# Man test..
```

总结几个要点:

1. type 可以通常被继承来使用。用法是 `type.__new__`，如果 `__new__` 方法返回的不是实例化时的类型，不会进入到 `__init__` 方法。
2. Person 指定元类以后，在定义过程中会进入元类 `__new__` 和 `__init__` 方法。而 Man 继承 Person 以后，定义过程也是进入元类的方法。在 python 中类也是对象，这里说的定义过程，也就是构建一个类对象。
3. 而在实例化的过程中。使用的都是各自的 `__new__` 方法。这里的实例化是将类对象进行实例化。

你在正常的代码编写过程中，很容易想到剥离相同的代码。放到一个基类中。那你什么时候应该要想到用基类呢？当你想要控制子类的行为时。

可以参考 orm 的做法，那么是实际代码中的使用方法应该如下:

1. 在元类中编写构建类时需要做的事情。例如把子类所有的数据存放到一个 __mapping__ 字典中。
2. 编写一个基类，把所有继承者通用特性综合到一起。
3. 在继承者内部编写不同之处 (调用者)。调用者可以非常方便的去使用基类，编写简单明了的代码。

上面的例子，是判断字段是否为 Field 类型。如果是的，那么这个变量代表的就是数据库内的字段名。

再举个例子，别人在继承你的基类时，加上了一个名字为 kentxxq 的变量，但是你对这个名字深恶痛绝！你就可以在基类指定 metaclass，而 metaclass 里对 attrs 进行判断，然后去掉它。这样别人要是不理解元类，就只能改变量名了！同样的方法，你也可以修改 name 和 base。也就是说，你可以通过条件操作这个子类会变成什么样子。

还来一个例子，哈哈。你写了一个很牛逼很牛逼的通用工具模块。别人只需要继承你，就可以让代码性能提高 10000%！你想看看到底有多少人再用！那么你就可以在这里做个统计，不就明白啦！

当然还有很多的地方可以用上，关键在于你的需求。

### 特殊的内部函数

|方法|调用方式|解释|
|---|---|---|
|\__new__(cls [,...])|instance = MyClass(arg1, arg2)|__new__ 在创建实例的时候被调用|
|\__init__(self [,...])|instance = MyClass(arg1, arg2)|__init__ 在创建实例的时候被调用|
|\__cmp__(self, other)|self == other, self > other, 等。|在比较的时候调用|
|\__pos__(self)|+self|一元加运算符|
|\__neg__(self)|-self|一元减运算符|
|\__invert__(self)|~self|取反运算符|
|\__index__(self)|x[self]|对象被作为索引使用的时候|
|\__nonzero__(self)|bool(self)|对象的布尔值|
|\__getattr__(self, name)|self.name # name 不存在|访问一个不存在的属性时|
|\__setattr__(self, name, val)|self.name = val|对一个属性赋值时|
|\__delattr__(self, name)|del self.name|删除一个属性时|
|\__getattribute__(self, name)|self.name|访问任何属性时|
|\__getitem__(self, key)|self[key]|使用索引访问元素时|
|\__setitem__(self, key, val)|self[key] = val|对某个索引值赋值时|
|\__delitem__(self, key)|del self[key]|删除某个索引值时|
|\__iter__(self)|for x in self|迭代时|
|\__contains__(self, value)|value in self, value not in self|使用 in 操作测试关系时|
|\__concat__(self, value)|self + other|连接两个对象时|
|\__call__(self [,...])|self(args)|“调用”对象时|
|\__enter__(self)|with self as x:|with 语句环境管理|
|\__exit__(self, exc, val, trace)|with self as x:|with 语句环境管理|
|\__getstate__(self)|pickle.dump(pkl_file, self)|序列化|
|\__setstate__(self)|data = pickle.load(pkl_file)|序列化|

内部完整文档可以参考 [官方](https://docs.python.org/zh-cn/3/reference/datamodel.html)

## 类方法和静态方法

`classmethod` 通常用来创造此类的实例。例如你需要通过别人的参数，来创造一个实例。但是参数可以包括对象、json 等。

好处:

1. 简单且逻辑直观。
2. 不需要实例化就可以使用。
3. 还可以在内部调用静态方法。完整复杂的操作。

`staticmethod` 是为了解决各种尴尬的问题。当你需要一个通用的 Tools 类时，内部都写成静态方法是不错的选择。

可能遇到的尴尬之处:

1. 写做外部方法，但不够通用。
2. 作为内部普通方法，却想不需要实例化就使用。
3. 和类方法对比起来。却又不需要和类对象有任何关系。

## 好的技巧资料

### [Python Cookbook](https://python3-cookbook.readthedocs.io/zh_CN/latest/)
