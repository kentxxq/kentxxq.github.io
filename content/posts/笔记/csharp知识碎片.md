---
title: csharp知识碎片
tags:
  - blog
  - csharp
date: 2024-09-13
lastmod: 2024-12-02
categories:
  - blog
description: 
---

## 简介

这里记录在使用 [[笔记/point/csharp|csharp]] 的过程中学习的内容, 主要是碎片化的知识点.

## 嵌入任意文件

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

## 全局变量

```csharp
public class GlobalVar  
{  
    /// <summary>最后一次请求ip-api.com失败的时间. 一旦无法联通ip-api.com,一定时间不再重新尝试.</summary>  
    public DateTime IpApiErrorTime { get; set; }  
}

// 注入DI
builder.Services.AddSingleton<GlobalVar>();

// 注入使用
private readonly GlobalVar _globalVar;
```
