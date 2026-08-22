---
title: OpenAPI接口规范
tags:
  - blog
date: 2024-07-04
lastmod: 2025-10-31
categories:
  - blog
description: 
---

## 简介

这里放我自己的 API 规范, 也是我在日常开发中的考量和实践.

## 响应格式

```json
{
    "code": 20000,
    "message": "登录成功",
    // "data":[]
    "data": {
        "token": ""
        // age : null
    }
}
```

- `http状态码`: 永远都是 `200`
    - 简化异常判断
    - http 状态码非常多, 每个人的理解都不一样. 放到应用内部进行规范. 减少歧义,减少心智负担
- `code`:
    - `20000` 正常
    - `50000` 异常
- `message`: 都可以自定义内容.
    - 默认 `操作成功`
    - 默认 `操作失败`
- `data`
    - data 可以是数组 , 数值, bool 或对象
    - 可以不返回没有的字段. 例如用户没有设置年龄, 那个 `age` 字段就可以不传输

## 响应内容

### 分页

```json
{
    "code": 20000,
    "message": "获取数据成功",
    "data": {
        "pageIndex": 2,
        "pageSize": 2,
        "pageData": ["1","2"],
        "totalCount": 320,
    }
}
```

- 接口名称通过 `getUsersByPage` 的 `ByPage` 区分接口是否分页
- 传入参数
    - `pageIndex` 当前页码
    - `pageSize` 每页大小, 同时返回 pageSize 个数据
        - 可以考虑限制分页大小, 避免一次性超大数据量返回
        - [Model validation in ASP.NET Core MVC \| Microsoft Learn](https://learn.microsoft.com/en-us/aspnet/core/mvc/models/validation?view=aspnetcore-9.0)
            - 使用 `aspnetcore` 内置的 [Model validation](https://learn.microsoft.com/en-us/aspnet/core/mvc/models/validation?view=aspnetcore-9.0)
                - `[Range(1, 500, ErrorMessage = "PageSize必须大于0,小于500")]` 直接也可以用在 controller 的参数上
            - 自定义实现 [ValidationAttribute](https://learn.microsoft.com/en-us/dotnet/api/system.componentmodel.dataannotations.validationattribute?view=net-9.0)
- 返回数据
    - `pageIndex` 同上
    - `pageSize` 同上
    - `pageData` 数据
    - `totalCount` 数据总量

### CURD

下面的操作返回就是 `data` 的值 (不要存放在 data 对象内)

- `insert`
    - http-post
    - 传入 `InsertRO`
    - 返回实体 id
    - 批量 insert 返回 `true/false` 代表操作成功
- `update`
    - http-post
    - 传入 `UpdateRO`
    - 返回 `true/false` 代表操作成功
    - 批量修改，拿邮箱记录
	    - 通常很少批量修改邮箱的整体内容, 传入 `List<UpdateRO>`
	    - 批量修改成已读，未读，归档，标签
		    - 1 个接口处理已读/未读状态
		    - 1 个接口移动邮件到特定文件夹/归档
		    - 1 个接口批量添加标签
- `delete`
    - http-post
    - 传入 id 列表 `List<int>`
    - 返回 `true/false` 代表操作成功
- 优缺点，真有需要也可以单独改接口
	- insert 返回 id 很有必要。而其他场景都是有 id 的
		1. 进入详情页/展示详情页入口。比如提交订单以后，需要进入订单详情页
		2. 新建后立即展示。聊天信息插入成功后本地 append，不需要重新拉取所有聊天记录
		3. 拿到 id，绑定给其他实体
			- 用户界面提交信息可能是一次性的，这个场景较少。
			- 微服务调用接口会有问题，这里拿邮箱举例。创建邮件后添加邮件附件。这时候有 id 就可以直接添加到关联表。否则创建邮件的时候，邮件的发件人/内容/标题都空的，你没办法获取到刚创建的邮件对象。
	- update/delete/批量 insert
		- 接口简单清晰。true 就操作成功，false 就操作失败（可能是记录已经不存在，或者操作超时）。直接提示用户刷新重试
		- 编写方便。通常数据库只返回了 true/false，减少了不必要的数据库查询和实体映射。
		- 批量 update/delete/insert 操作都可以兼容，减少了认知成本。
		- 无法获取影响的数据条数，数据是否有实际的变化。只有操作成功

## 时间

- 前后端接口传输, 使用 `iso8601` 示例 `2024-08-28T16:35:39.0952381+08:00`
- 后端代码内都使用 `DateTimeOffset`
- 数据库存放 `Utc` 时间, 很多数据库不能保存时区

```csharp
// 不指定时区,不指定DateTimeKind为utc. 直接把datetime赋值给datetimeoffset,默认会加上服务器的时区

Console.WriteLine(DateTime.Now);
Console.WriteLine(DateTime.UtcNow);
Console.WriteLine("---");
Console.WriteLine(DateTimeOffset.Now);
Console.WriteLine(DateTimeOffset.UtcNow);

2024/7/13 13:40:52
2024/7/13 5:40:52
---
2024/7/13 13:40:52 +08:00
2024/7/13 5:40:52 +00:00
```

## 上传文件

使用 `multipart/form-data` 编写前后端 api 比较清晰。

> `application/x-www-form-urlencoded` 传输文件需要先 `base64`，表单字段被编码为 `key=value&key2=value2`

### axios

```ts
var data = new FormData();
data.append('file', fs.createReadStream('C:\Users\Apifox\Desktop\Apifox 上传文件.txt'));
data.append('name', '张三');
await axios.post("/api/upload", data)
```

### aspnetcore

```csharp
public class WebdavUploadModel
{
    [Description("服务器: https://a.com/dav")]
    public string Server { get; set; }
    [Description("用户名")] public string Username { get; set; }
    [Description("密码")] public string Password { get; set; }
    [Description("文件夹路径(相对路径): a/b/c")] public string FolderPath { get; set; }
    [Description("文件")] public IFormFile UserFile { get; set; }
}


// api
[EndpointDescription("上传文件到webdav")]
[HttpPost]
[Consumes("multipart/form-data")] // FromForm同时支持multipart/form-data和application/x-www-form-urlencoded,强制使用form-data
public async Task<ResultModel<bool>> PostWebdavFile([FromForm] WebdavUploadModel model)
{
    var clientParams = new WebDavClientParams
    {
        BaseAddress = new Uri(model.Server),
        Credentials = new NetworkCredential(model.Username, model.Password)
    };
    var client = new WebDavClient(clientParams);
    var streamContent = new StreamContent(model.UserFile.OpenReadStream());

    var response =
        await client.PutFile($"{model.Server.UrlCombine(model.FolderPath)}/{model.UserFile.FileName}",
            streamContent);
    return ResultModel.Ok(response.IsSuccessful);
}
```
