---
title: csharp知识碎片
tags:
  - blog
  - csharp
  - 知识碎片
  - 语言特性
date: 2024-09-13
lastmod: 2025-10-31
categories:
  - blog
description: 
---

## 简介

这里记录在使用 [[笔记/point/csharp|csharp]] 的过程中学习的内容, 主要是碎片化的知识点.

## 语言特性

### 属性 properties 和字段 Fields

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
- 虽然 `public int age` 和 `public int age{get;set;}` 的用法一样, 但是不符合设计理念. 如下:
    - json 序列化默认不包含字段, 需要配置 [[笔记/csharp的json教程#JsonSerializerOptions 对象|JsonSerializerOptions对象]]

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

### required

```csharp
public class WebhookConfig
{
    public required string NotifyUrl { get; set; }
}
```

这里 `required` 代表初始化的时候必须赋值, 例如 `var config = new WebhookConfig();` 就会报错

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

// 枚举,除了ToStringFast还有ToDisplayFast,ToDescriptionFast
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

### 遍历对象

参考这 [一篇博客](https://www.claudiobernasconi.ch/2013/07/22/when-to-use-ienumerable-icollection-ilist-and-list/)，总结一下使用方法。

1. `public interface IEnumerable<out T> : IEnumerable` 只能遍历使用
2. `public interface ICollection<T> : IEnumerable<T>, IEnumerable` 你关心它的大小, 添加，删除，清空操作
3. `public interface IList<T> : ICollection<T>, IEnumerable<T>, IEnumerable` 你要修改它并且需要排序，例如插入指定位置，查找指定下标数据。
4. `List<>` 则是一个实现。

List 是继承于接口 IEnumerable 的，所以返回 List 是可以的。

### DateTimeOffset 打印

```csharp
// 默认会根据不同文化信息,有输出差异
// 中国 2025/3/28 15:30:15 +08:00
// 美国 3/28/2025 3:30:15 PM +08:00
DateTimeOffset.Now.ToString()

// ISO8601
// 2025-03-28T17:30:54.2649425+08:00
// 等同 yyyy-MM-ddTHH:mm:ss.fffffffzzz
DateTimeOffset.Now.ToString("O")
```

### 时区信息

- [[笔记/point/mysql|mysql]] 的 datetime 存储永远都是不带时区信息的, 不会因为切换 mysql 会话的 `time_zone` 而改变 sql 结果
- 数据库时间就是当地时间, 建议**跨时区的数据查询必须通过上层服务进行转换! 不能跨时区查询!**
- 或者用 pgsql？有时区，无需设置字符串长度

保留毫秒数

```csharp
[SugarColumn(ColumnDataType = "DATETIME(3)")]
public DateTimeOffset CreateTime { get; set; }
```

### 密码存放/验证

`bcrypt` 算法多语言兼容, 很难被暴力/彩虹表突破, 难度也可以设置

```csharp
// https://www.nuget.org/packages/BCrypt.Net-Next/
using BCryptNet;

// Hash a password
string passwordHash =  BCrypt.HashPassword("my password");
// Validate a password
var isValid = BCrypt.Verify("my password", passwordHash);
```

### nacos/服务发现

- 推荐根据 swagger 生成 cs 文件, 然后统一配置 http 策略,  [参考官方这部分内容](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/http-requests?view=aspnetcore-9.0#generated-clients)
- 使用 [nacos-sdk-csharp注入的NacosNamingService](https://github.com/nacos-group/nacos-sdk-csharp/blob/dev/src/Nacos/V2/Naming/NacosNamingService.cs) 获取微服务信息

```csharp
// 即使每次服务发现到的是ip+port,也应该使用_httpClientFactory,这样会服用tcp连接,且复用polly,log规则

var client = _httpClientFactory.CreateClient(); // ✅ 共享连接池
// 下面使用INacosNamingService
// https://github.com/nacos-group/nacos-sdk-csharp/blob/dev/src/Nacos/V2/Naming/NacosNamingService.cs
var endpoint = await _svc_.SelectOneHealthyInstance("user-service");
client.BaseAddress = new Uri($"http://{endpoint.Ip}:{endpoint.Port}");
await client.GetAsync("/login");
```

### SIGTERM 信号处理

- [SIGTERM handling · Issue #5932 · dotnet/aspnetcore](https://github.com/dotnet/aspnetcore/issues/5932)

### 代码分层 aspnetcore

- controller 控制层
	- 输入验证
	- 返回请求，SO 对象映射
- service
	- 判断是否属于 xx 用户
	- 在这里把 RO 对象映射到 model

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
