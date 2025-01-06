---
title: csharp知识碎片
tags:
  - blog
  - csharp
date: 2024-09-13
lastmod: 2024-12-29
categories:
  - blog
description: 
---

## 简介

这里记录在使用 [[笔记/point/csharp|csharp]] 的过程中学习的内容, 主要是碎片化的知识点.

## 开发

### 枚举查询

```csharp
// 使用
[HttpGet]
public ResultModel<List<EnumObject>> ResultStatusApi()
{
    // var data = typeof(ResultStatus).EnumToEnumObject<ResultStatus>();
    var data = ResultStatus.Success.EnumValueToEnumObject();
    return ResultModel.Ok(data);
}

// 枚举
// https://github.com/EngRajabi/Enum.Source.Generator
[EnumGenerator]  
public enum ResultStatus  
{  
    /// <summary>  
    ///     成功  
    /// </summary>  
    [Display(Name = "成功", Description = "请求成功返回")]  
    Success = 20000,  
  
    /// <summary>  
    ///     失败  
    /// </summary>  
    [Display(Name = "失败", Description = "内部服务异常")]  
    Error = 50000  
}

// 也可以使用
// https://github.com/andrewlock/NetEscapades.EnumGenerators
using NetEscapades.EnumGenerators;
[EnumExtensions]
public enum ResultStatus
{
    /// <summary>
    ///     成功
    /// </summary>
    [Display(Name = "成功", Description = "请求成功返回")]
    Success = 20000,

    /// <summary>
    ///     失败
    /// </summary>
    [Display(Name = "失败", Description = "内部服务异常")]
    Error = 50000
}


// 静态方法
/// <summary>
/// 使用方法 typeof(MyEnum).EnumToEnumObject<MyEnum>()
/// </summary>
public static List<EnumObject> EnumTypeToEnumObject<T>(this Type enumType) where T : Enum
{
    if (!enumType.IsEnum)
    {
        throw new ArgumentException("必须是enum类型");
    }

    var enumList = new List<EnumObject>();
    foreach (T enumValue in Enum.GetValues(enumType))
    {
        enumList.Add(new EnumObject
        {
            EnumKey = Convert.ToInt32(enumValue),
            EnumName = enumValue.ToString(),
            EnumDisplayName = enumValue.GetEnumDisplay()?.Name ?? string.Empty
        });
    }

    return enumList;
}

/// <summary>
/// 使用方法 MyEnum.Value1.EnumToEnumObject2();
/// </summary>
public static List<EnumObject> EnumValueToEnumObject<T>(this T enumType) where T : Enum
{
    var enumList = new List<EnumObject>();
    var t = enumType.GetType();
    foreach (T enumValue in Enum.GetValues(t))
    {
        enumList.Add(new EnumObject
        {
            EnumKey = Convert.ToInt32(enumValue),
            EnumName = enumValue.ToString(),
            EnumDisplayName = enumValue.GetEnumDisplay()?.Name ?? string.Empty
        });
    }

    return enumList;
}

// 结果保存
public class EnumObject
{
    public int EnumKey { get; set; }
    public string EnumName { get; set; } = string.Empty;
    public string EnumDisplayName { get; set; } = string.Empty;
}
```

### 随机字符串

```csharp
/// <summary>
///     生成随机字符串
/// </summary>
/// <param name="length">目标字符串的长度</param>
/// <param name="useNum">是否包含数字，1=包含，默认为包含</param>
/// <param name="useLow">是否包含小写字母，1=包含，默认为包含</param>
/// <param name="useUpp">是否包含大写字母，1=包含，默认为包含</param>
/// <param name="useSpe">是否包含特殊字符，1=包含，默认为不包含</param>
/// <param name="custom">要包含的自定义字符，直接输入要包含的字符列表</param>
/// <returns>指定长度的随机字符串</returns>
public static string GetRandomString(int length, bool useNum, bool useLow, bool useUpp, bool useSpe = false,
    string custom = "")
{
    //var b = new byte[4];
    //new System.Security.Cryptography.RNGCryptoServiceProvider().GetBytes(b);
    //RandomNumberGenerator.GetBytes(b);
    //var r = new Random(BitConverter.ToInt32(b, 0));
    string s = "", str = custom;
    if (useNum)
    {
        str += "0123456789";
    }

    if (useLow)
    {
        str += "abcdefghijklmnopqrstuvwxyz";
    }

    if (useUpp)
    {
        str += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    }

    if (useSpe)
    {
        str += "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~";
    }

    for (var i = 0; i < length; i++)
    {
        s += str.Substring(RandomNumberGenerator.GetInt32(0, str.Length), 1);
    }

    return s;
}
```

### 映射

引入 `Riok.Mapperly`

```csharp
using Riok.Mapperly.Abstractions;
using Uni.Webapi.Models.DB;
using Uni.Webapi.Models.RO;

namespace Uni.Webapi.Common;

[Mapper]
public static partial class MyMapper
{
    public static partial User LoginROToUser(LoginRO loginRO);
}
```

### 全局变量

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

## 打包

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
