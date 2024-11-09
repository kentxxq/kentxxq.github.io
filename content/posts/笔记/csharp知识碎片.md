---
title: csharp知识碎片
tags:
  - blog
  - csharp
date: 2024-09-13
lastmod: 2024-10-16
categories:
  - blog
description: 
---

## 简介

这里记录在使用 [[笔记/point/csharp|csharp]] 的过程中学习的内容, 主要是碎片化的知识点.

## 知识点

### in , out, ref

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

### 嵌入任意文件

参考 [这篇文章](https://khalidabuhakmeh.com/how-to-use-embedded-resources-in-dotnet) 使用 MSbuild 的 `EmbeddedResource`

嵌入特定文件

```xml
<ItemGroup>  
  <EmbeddedResource Include="Embedded\test.txt" />  
</ItemGroup>
```

访问文件

```csharp
// 拿到所有的资源文件名称
var names = Assembly  
        .GetExecutingAssembly()  
        .GetManifestResourceNames();  

foreach (var name in names)  
{  
    Console.WriteLine(name);  
    // 通过资源文件名称,获取到stream流
    using var stream = Assembly  
        .GetExecutingAssembly()  
        .GetManifestResourceStream(name)!;  
    using var streamReader = new StreamReader(stream, Encoding.UTF8);  
    var data = streamReader.ReadToEnd();  
    Console.WriteLine(data);  
}
```
