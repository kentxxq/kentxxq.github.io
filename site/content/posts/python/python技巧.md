---
title:  python技巧
date:   2019-11-26 00:00:00 +0800
categories: ["笔记"]
tags: ["python"]
keywords: ["python"]
description: "最近把手上的事情都忙完了。准备来好好巩固自己的python知识。为什么标题是技巧呢，因为这部分是它和其他语言最大的不同，或者说特点。要玩得6，不熟这一些知识点，肯定是不行"
---


> 最近把手上的事情都忙完了。准备来好好巩固自己的python知识。为什么标题是技巧呢，因为这部分是它和其他语言最大的不同，或者说特点。要玩得6，不熟这一些知识点，肯定是不行。


python的类
===

python可以用函数式编程。也支持面向对象编程。

在使用函数式编程的时候，多数都是用来写脚本。同时这也是python最开始发光发亮的点。但是在处理结构性数据以及架构项目的时候，面向对象的优势就会凸显出来。同时也有很多的黑魔法让你快速完成原型的构造。

先说type函数
---

我们经常用type函数来查看对象的类型信息。但还有一个用法，就是用type来生成对象。当你在写python class代码的时候，解析器遇到class代码块，就会解析class结构，然后用type来构造对象。  
```python
# name代表类名，base代表父类或者说基类，attrs为字典形式，代表属性值。
type(name, base, attrs)
```

type和元类
---

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

1. type可以通常被继承来使用。用法是`type.__new__`，如果`__new__`方法返回的不是实例化时的类型，不会进入到`__init__`方法。
2. Person指定元类以后，在定义过程中会进入元类`__new__`和`__init__`方法。而Man继承Person以后，定义过程也是进入元类的方法。在python中类也是对象，这里说的定义过程，也就是构建一个类对象。
3. 而在实例化的过程中。使用的都是各自的`__new__`方法。这里的实例化是将类对象进行实例化。

你在正常的代码编写过程中，很容易想到剥离相同的代码。放到一个基类中。那你什么时候应该要想到用基类呢？当你想要控制子类的行为时。

可以参考orm的做法，那么是实际代码中的使用方法应该如下:

1. 在元类中编写构建类时需要做的事情。例如把子类所有的数据存放到一个__mapping__字典中。
2. 编写一个基类，把所有继承者通用特性综合到一起。
3. 在继承者内部编写不同之处(调用者)。调用者可以非常方便的去使用基类，编写简单明了的代码。

上面的例子，是判断字段是否为Field类型。如果是的，那么这个变量代表的就是数据库内的字段名。

再举个例子，别人在继承你的基类时，加上了一个名字为kentxxq的变量，但是你对这个名字深恶痛绝！你就可以在基类指定metaclass，而metaclass里对attrs进行判断，然后去掉它。这样别人要是不理解元类，就只能改变量名了！同样的方法，你也可以修改name和base。也就是说，你可以通过条件操作这个子类会变成什么样子。

还来一个例子，哈哈。你写了一个很牛逼很牛逼的通用工具模块。别人只需要继承你，就可以让代码性能提高10000%！你想看看到底有多少人再用！那么你就可以在这里做个统计，不就明白啦！

当然还有很多的地方可以用上，关键在于你的需求。

特殊的内部函数
---

方法|调用方式|解释
---|---|---
\_\_new\_\_(cls [,...])|instance = MyClass(arg1, arg2)|\_\_new\_\_ 在创建实例的时候被调用
\_\_init\_\_(self [,...])|instance = MyClass(arg1, arg2)|\_\_init\_\_ 在创建实例的时候被调用
\_\_cmp\_\_(self, other)|self == other, self > other, 等。|在比较的时候调用
\_\_pos\_\_(self)|+self|一元加运算符
\_\_neg\_\_(self)|-self|一元减运算符
\_\_invert\_\_(self)|~self|取反运算符
\_\_index\_\_(self)|x[self]|对象被作为索引使用的时候
\_\_nonzero\_\_(self)|bool(self)|对象的布尔值
\_\_getattr\_\_(self, name)|self.name # name 不存在|访问一个不存在的属性时
\_\_setattr\_\_(self, name, val)|self.name = val|对一个属性赋值时
\_\_delattr\_\_(self, name)|del self.name|删除一个属性时
\_\_getattribute\_\_(self, name)|self.name|访问任何属性时
\_\_getitem\_\_(self, key)|self[key]|使用索引访问元素时
\_\_setitem\_\_(self, key, val)|self[key] = val|对某个索引值赋值时
\_\_delitem\_\_(self, key)|del self[key]|删除某个索引值时
\_\_iter\_\_(self)|for x in self|迭代时
\_\_contains\_\_(self, value)|value in self, value not in self|使用 in 操作测试关系时
\_\_concat\_\_(self, value)|self + other|连接两个对象时
\_\_call\_\_(self [,...])|self(args)|“调用”对象时
\_\_enter\_\_(self)|with self as x:|with 语句环境管理
\_\_exit\_\_(self, exc, val, trace)|with self as x:|with 语句环境管理
\_\_getstate\_\_(self)|pickle.dump(pkl_file, self)|序列化
\_\_setstate\_\_(self)|data = pickle.load(pkl_file)|序列化

内部完整文档可以参考[官方](https://docs.python.org/zh-cn/3/reference/datamodel.html)


好的技巧资料
===

[Python Cookbook](https://python3-cookbook.readthedocs.io/zh_CN/latest/)
---