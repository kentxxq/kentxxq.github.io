---
title: csharp语言特性
tags:
  - blog
date: 2024-07-11
lastmod: 2024-07-11
categories:
  - blog
description: 
---

## 简介

[[笔记/point/csharp|csharp]] 更新非常快, 有很多好用的新语法糖.

## 内容

### 属性和字段

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
