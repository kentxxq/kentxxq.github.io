---
title: csharp语言特性
tags:
  - blog
date: 2024-07-11
lastmod: 2024-12-02
categories:
  - blog
description: 
---

## 简介

[[笔记/point/csharp|csharp]] 更新非常快, 有很多好用的新语法糖.

## 属性和字段

```csharp
public class Person
{
    private int age;      // 这是一个字段field
    public int Age       // 这是一个属性property
    {
        get { return age; }
        set 
        { 
            if (value >= 0)
            {
                age = value; 
            }
        }
    }
}
```

- 字段 `field`: 通常是私有的, 通过属性对外保留
- 属性 `properties`: 对外暴露访问, 可以进行数据验证

## in , out, ref

- `in`: 参数**必须**在传递前初始化，方法内部**只能读取**参数，不能修改其值（适用于只读引用传递）
- `ref`: 参数**必须**在传递前初始化，方法内部可以读取和修改参数的值。
- `out`: 参数**无需**在传递前初始化，但**必须**在方法内部初始化，方法内部可以读取和修改参数的值。

因为 `in` 和 `ref` 需要初始化变量, 代码没有简化, 所以用的比较少.  在日常使用中默认函数是值传递, 使用 `in` 和 `ref` 可以进行性能优化.

`out` 使用量是最大的, 因为有 `TryParse` 系列函数 : 返回 bool, 赋值给新变量

下面是 `int.TryParse` 的示例.

```csharp
string input = "123";
if (int.TryParse(input, out int result))  // 对解析结果进行判断
{
    Console.WriteLine($"解析成功: {result}");  // 解析成功时的处理
}
else
{
    Console.WriteLine("解析失败，输入不是有效的整数。");  // 解析失败时的处理
}
```
