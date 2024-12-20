---
title: csharp的json教程
tags:
  - blog
  - csharp
date: 2023-09-27
lastmod: 2024-12-19
keywords:
  - csharp
  - json
  - 教程
  - 转换
categories:
  - blog
description: "介绍 [[笔记/point/csharp|csharp]] 关于 json 的用法. 本文的所有源码均存放在 [kentxxq/csharpDEMO (github.com)](https://github.com/kentxxq/csharpDEMO). 为什么会有这篇文章? 因为 json 非常的流行, 而且存在有很多细节. 例如性能, 格式, 类库用法等等."
---

## 简介

介绍 [[笔记/point/csharp|csharp]] 关于 json 的用法. 本文的所有源码均存放在 [kentxxq/csharpDEMO (github.com)](https://github.com/kentxxq/csharpDEMO/blob/main/PackageUsage/Convert/MyConvert/Program.cs).

为什么会有这篇文章?

因为 json 非常的流行, 而且存在有很多细节. 例如性能, 格式, 类库用法等等.

## 准备数据

准备一个用于演示的示例对象 `Person`. 同时涵盖了 `List`, `string`, `int`, `枚举`, `日期`.

```cs
/// <summary>人</summary>  
public class Person  
{  
    [Display(Name = "人名", Description = "人的名字")]  
    public string Name { get; set; } = null!;  
  
    [Display(Name = "性别", Description = "人的性别")]  
    public Sex SexType { get; set; }  

    [Display(Name = "生日", Description = "人的生日")]  
    public DateTime Birthday { get; set; }

    [Display(Name = "年纪", Description = "人的年纪")]  
    public int Age { get; set; }  
  
    [Display(Name = "头", Description = "人的头")]  
    public Head PersonHead { get; set; } = null!;  
  
    [Display(Name = "鞋子", Description = "人的鞋子")]  
    public List<Shoes>? PersonShoes { get; set; }  
}

/// <summary>头</summary>  
public class Head  
{  
    [Display(Name = "宽", Description = "头的宽")]  
    public int Width { get; set; }  
  
    [Display(Name = "高", Description = "头的高")]  
    public int Height { get; set; }  
}

/// <summary>性别</summary>  
public enum Sex  
{  
    [Display(Name = "男")] Man,  
    [Display(Name = "女")] Woman  
}

/// <summary>鞋子</summary>  
public class Shoes  
{  
    [Display(Name = "鞋名", Description = "鞋子的名字")]  
    public string ShoesName { get; set; } = null!;  
  
    [Display(Name = "鞋颜色", Description = "鞋子的颜色")]  
    public Color ShoesColor { get; set; }  
}
```

初始化一下:

```csharp
public static readonly Person DemoPerson = new()
{
    Name = "ken", Age = 1, PersonHead = new Head { Height = 50, Width = 50 }, PersonShoes = new List<Shoes>
    {
        new() { ShoesColor = Color.Blue, ShoesName = "蓝色" },
        new() { ShoesColor = Color.Red, ShoesName = "红色" }
    }
};
```

## 对象/json 互转

### 标准做法

```csharp
// 转json
var str = JsonSerializer.Serialize(StaticData.DemoPerson, new JsonSerializerOptions
{
    // 空格缩进
    WriteIndented = true,
    // 宽松转义规则,虽然不规范,但中文会正常打印出来. 否则中文会变成unicode字符,例如'蓝'-'\u84DD'
    Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
});

// 转对象
var d1 = JsonSerializer.Deserialize<Person>(str);
```

得到字符串

```json
{
  "Name": "ken",
  "SexType": 0,
  "Birthday": "1234-05-06T00:00:00",
  "Age": 1,
  "PersonHead": {
    "Width": 50,
    "Height": 50
  },
  "PersonShoes": [
    {
      "ShoesName": "蓝色",
      "ShoesColor": {
        "R": 0,
        "G": 0,
        "B": 255,
        "A": 255,
        "IsKnownColor": true,
        "IsEmpty": false,
        "IsNamedColor": true,
        "IsSystemColor": false,
        "Name": "Blue"
      }
    },
    {
      "ShoesName": "红色",
      "ShoesColor": {
        "R": 255,
        "G": 0,
        "B": 0,
        "A": 255,
        "IsKnownColor": true,
        "IsEmpty": false,
        "IsNamedColor": true,
        "IsSystemColor": false,
        "Name": "Red"
      }
    }
  ]
}

```

### 源生成

#todo/笔记  [net8新增UseStringEnumConverter](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/source-generation-modes?pivots=dotnet-8-0#blanket-policy)

编写一个 Context 类

```csharp
[JsonSourceGenerationOptions(WriteIndented = true)] // 全局设置
[JsonSerializable(typeof(Person))] // 需要转换的类
[JsonSerializable(typeof(User))]   // 可以多个
internal partial class JsonContext : JsonSerializerContext
{
}
```

使用:

```csharp
var s1 = JsonSerializer.Serialize(StaticData.DemoPerson, JsonContext.Default.Person);
var o1 = JsonSerializer.Deserialize(s1, JsonContext.Default.Person);
var s2 = JsonSerializer.Serialize(StaticData.DemoUser, JsonContext.Default.User);
Console.WriteLine(s1);
Console.WriteLine(s2);
```

## 自定义类型转换

- [enum枚举](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/customize-properties?pivots=dotnet-8-0#enums-as-strings) 默认是枚举值 (数字), 使用名称替代
- 日期/timestamp 互转示例

```csharp
public class DateTimeJsonConverter2Timestamp : JsonConverter<DateTime>
{
    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        var tsDatetime = reader.GetInt64().MillisecondsToDateTime();
        return tsDatetime;
    }

    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
    {
        var jsonDateTimeFormat = value.ToTimestampMilliseconds();
        writer.WriteNumberValue(jsonDateTimeFormat);
    }
}
```

**推荐**使用 `JsonConverter` 特性:

```csharp
public class WeatherForecastWithConverterAttribute
{
    [JsonConverter(typeof(DateTimeJsonConverter2Timestamp))]
    public DateTime Date { get; set; }
    public int TemperatureCelsius { get; set; }
    public string? Summary { get; set; }
}
```

或加入到 [[笔记/csharp的json教程#JsonSerializerOptions 对象|JsonSerializerOptions]] 中:

```csharp
var opt = new JsonSerializerOptions
{
    // enum用名称,而不是数字表示
    Converters =
    {
        new JsonStringEnumConverter(JsonNamingPolicy.CamelCase)
    }
};
```

aspnetcore 使用

```csharp
services.AddControllers()
        .AddJsonOptions(
            opt => opt.JsonSerializerOptions.Converters.Add(new DateTimeJsonConverter2Timestamp())
        );
```

## json 字符串数据查询

### 如何使用

什么情况使用? **json 数据没有固定的字段, 或者数据类型**.

使用选型:

- [JsonDocument](https://learn.microsoft.com/en-us/dotnet/api/system.text.json.jsondocument?view=net-7.0): 只读, 性能更好.
- [JsonNode](https://learn.microsoft.com/en-us/dotnet/api/system.text.json.nodes.jsonnode?view=net-7.0): 可改动, [且改动方便](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-dom#create-a-jsonnode-dom-with-object-initializers-and-make-changes)

> 在不规范的 json 中, 存在有重复的 key.
> JsonDocument 取最后一个 key 的值. JsonNode 会报错!

### JsonNode

```csharp
var jNode = JsonNode.Parse(str)!;  
var name = jNode["Name"]!.GetValue<string>();  
// 修改
jNode["Name"] = "kent";  
name = jNode["Name"]!.GetValue<string>();
// 移除, JsonObject继承JsonNode
var jObject = jNode.AsObject();
jObject.Remove("Name");
```

### JsonDocument

```csharp
using var jDoc = JsonDocument.Parse(str);  
name = jDoc.RootElement.GetProperty("Name").Deserialize<string>();
```

## JsonSerializerOptions 对象

#todo/笔记  

- [JsonSerializerOptions.UnmappedMemberHandling Property](https://learn.microsoft.com/en-us/dotnet/api/system.text.json.jsonserializeroptions.unmappedmemberhandling?view=net-8.0#system-text-json-jsonserializeroptions-unmappedmemberhandling)
- `TypeInfoResolver = JsonContext.Default` 没有了?

```csharp
var opt = new JsonSerializerOptions
{
    // 空格
    WriteIndented = true,
    // 宽松转义规则,虽然不规范,但中文会正常打印出来. 否则中文会变成unicode字符,例如'蓝'-'\u84DD'
    Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping,

    // 下面的不常用
    // 默认不包含字段
    IncludeFields = true,
    // 允许存在注释,例如 "a":1, // a是id
    ReadCommentHandling = JsonCommentHandling.Skip,
    // 允许结尾的逗号
    AllowTrailingCommas = true,
    // 默认大小写不敏感
    PropertyNameCaseInsensitive = true,
    // 默认允许从string中读取数字
    NumberHandling = JsonNumberHandling.AllowReadingFromString,
    // 默认驼峰. JsonNamingPolicy.SnakeCaseLower 是小写下划线分割
    // https://learn.microsoft.com/zh-cn/dotnet/standard/serialization/system-text-json/customize-properties?pivots=dotnet-8-0#use-a-built-in-naming-policy
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    // 对象内部驼峰 "AB":{"aB":1,"bB":1}
    DictionaryKeyPolicy = JsonNamingPolicy.CamelCase,
    // enum用名称,而不是数字表示
    Converters =
    {
        new JsonStringEnumConverter(JsonNamingPolicy.CamelCase)
    }
    // 从源生成中获取类型转换信息
    TypeInfoResolver = JsonContext.Default
};
```

## 相关特性 attribute

这些特性都是用在 POCO/实例类的.

### 自定义转化名称 JsonPropertyName

```csharp
[JsonPropertyName("Wind")]
public int WindSpeed { get; set; }
```

[How to customize property names and values with System.Text.Json - .NET | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/customize-properties?pivots=dotnet-8-0#customize-individual-property-names)

### 必须存在 JsonRequired

```csharp
[JsonRequired]
public int WindSpeed { get; set; }
```

[Require properties for deserialization - .NET | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/required-properties)

### 忽略 ignore

常用

- `[JsonIgnore]`: 总是忽略
- `[JsonIgnore(Condition = JsonIgnoreCondition.Never)]`: 永远显示, 是 `JsonSerializerOptions` 对象中, `DefaultIgnoreCondition`,`IgnoreReadOnlyProperties`, `IgnoreReadOnlyFields` 的默认值
- `[JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]`: null 就忽略
- `[JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingDefault)]`: 忽略 null 或者值类型的默认值 (例如 int 默认值是 0 )

[How to ignore properties with System.Text.Json - .NET | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/ignore-properties?pivots=dotnet-7-0)

### 多余字段 JsonExtensionData

```csharp
[JsonExtensionData]
public Dictionary<string, JsonElement>? ExtensionData { get; set; }
```

[How to handle overflow JSON or use JsonElement or JsonNode in System.Text.Json - .NET | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/handle-overflow?pivots=dotnet-7-0#handle-overflow-json)

## 不规范的 json 字符串

下面是一些可能遇到的情况:

- 不传递值, 会使用实体类的默认值. 所以实体类如果不能为 null, 一定要配置默认值.
- `null` 会破坏代码中不允许为 `null` 的问题. 需要 [等待这个讨论完结](https://github.com/dotnet/runtime/issues/1256) 来最终加入一个新的 `jsonserializerOptions` 选项或者 [特殊处理](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/converters-how-to?pivots=dotnet-7-0#handle-null-values). 因此**建议在 json 字符串中去掉值为 ` null ` 的数据!**
- 也可以不管这些, 通过用户提交的数据进行验证避免错误. 因为用户请求是一定要进行验证的.

```csharp
// 不标准的json
// 不完整的json,缺少的字段默认值
var j1 = """{"Name": "ken"}""";
var j11 = JsonSerializer.Deserialize(j1, JsonContext.Default.Person);

// 带null的json
// age为null报错.
// name为null则会传递到对象里,即使Name不允许为null值
var j2 = """{"Name": null,"Age":4}""";
var j22 = JsonSerializer.Deserialize(j2, JsonContext.Default.Person);

// 多余的字段不受影响.正常默认值  
var j3 = """{"HHH":null}""";  
var j33 = JsonSerializer.Deserialize(j3, JsonContext.Default.Person);
```

## 不常用的东西

- [处理引用和循环引用](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/preserve-references?pivots=dotnet-7-0)
- 使用 [Utf8JsonWriter](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-utf8jsonwriter) 和 [Utf8JsonReader](https://learn.microsoft.com/en-us/dotnet/standard/serialization/system-text-json/use-utf8jsonreader) 这样的低级 api 处理 json, 甚至可以处理不完整或残缺的字符串

    ```csharp
    var options = new JsonWriterOptions
    {
        Indented = true
    };
    
    using var stream = new MemoryStream();
    using var writer = new Utf8JsonWriter(stream, options);
    
    writer.WriteStartObject();
    writer.WriteString("date", DateTimeOffset.UtcNow);
    writer.WriteNumber("temp", 42);
    // writer.WriteEndObject(); // 不输出结尾的大括号
    writer.Flush();
    var json = Encoding.UTF8.GetString(stream.ToArray());
    Console.WriteLine(json);
    
    // 读取这个不完整的json
    // 因为最后的42没有截止符,无法读取
    var reader = new Utf8JsonReader(Encoding.UTF8.GetBytes(json),isFinalBlock:false,state:default);
    while (reader.Read())
    {
        Console.WriteLine(reader.TokenType);
        if (reader.TokenType == JsonTokenType.PropertyName)
        {
            var property = reader.GetString();
            if (property == "date")
            {
                reader.Read();
                Console.WriteLine(reader.GetDateTime());
            }
        }
    }
    ```
