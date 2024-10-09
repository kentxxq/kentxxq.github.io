---
title: Transfer-Encoding和Content-Length
tags:
  - blog
  - http
  - csharp
date: 2024-10-09
lastmod: 2024-10-09
keywords:
  - Transfer-Encoding
  - Content-Length
  - http2
  - chunked
  - HttpClient
  - TransferEncodingChunked
categories:
  - blog
description: 
---

## 简介

我开发 [pusher](https://pusher.kentxxq.com) 的时候对接了 [Qmsg酱](https://qmsg.zendee.cn/), 中间遇到了一些问题, 是关于 `Transfer-Encoding` 和 `Content-Length` 这两个 Header.

## 问题处理

我通过 HttpClient 发送请求的代码如下

```csharp
var httpResponseMessage = await httpClient.PostAsJsonAsync(url,data)
```

报错信息

```csharp
System.Net.Http.HttpRequestException: An error occurred while sending the request.
---> System.Net.Http.HttpI0Exception: The response ended prematurely. (ResponseEnded)
at System.Net.Http.HttpConnection.SendAsync(HttpRequestMessage request, Boolean async, CancellationToken cancellationToken)
--- End of inner exception stack trace ---
...
```

通过网络搜索发现了 [这个文章转发](https://www.cnblogs.com/yexiaoyanzi/p/16309697.html) 和 [stack overflow问题](https://stackoverflow.com/questions/59590012/net-httpclient-accept-partial-response-when-response-header-has-an-incorrect),  手动组装了一个 `StringContent` , 使用 `SendAsync` 正常发送了请求.

## 原因分析

这里用到了我的 [TestServer](https://github.com/kentxxq/TestServer) 服务, 地址是 [test.kentxxq.com](https://test.kentxxq.com) 访问 `test.kentxxq.com/request` 会返回你的请求信息.

下面来对比 `PostAsJsonAsync` 和 `SendAsync` 这两种方式发出的 web 请求有什么区别.

```csharp
// SendAsync
var httpResponseMessage = await httpClient.PostAsJsonAsync(url,data)

// SendAsync
using var req = new HttpRequestMessage(HttpMethod.Post, url);  
req.Content = new StringContent(JsonSerializer.Serialize(data), Encoding.UTF8, MediaTypeNames.Application.Json);  
var httpResponseMessage = await httpClient.SendAsync(req);
```

`PostAsJsonAsync` 和 `SendAsync` 请求的区别在于 `Header`

```csharp
{
    "Headers":{
        "Transfer-Encoding": "chunked" // PostAsJsonAsync
        "Content-Length": "45"         // SendAsync
    },
    ...
}
```

- `Content-Length` 代表传递的 `body/form/文件` 的大小. 否则服务器不知道你传输的数据是否结束.  
- 代表客户端不知道数据的具体大小, 采用分片传输. 假设你在传输一个 10 g 的文件, 你可以直接开始 chunked 传输, 而不需要提前计算这个文件的大小, 从而加快了**传输速度**
- 也就是说除了没有消息体的请求 (例如 get ,head 请求), 必须在 `Content-Length` 或 `Transfer-Encoding` 里**2 选 1**, **否则服务器可能无法正确响应**

当我使用 curl 或 postman 等工具的时候, 会带上 `Content-Length`. 结果会和 `SendAsync` 一样可以正常工作, **所以问题出在了** `Transfer-Encoding`

通过搜索找到了 [Transfer-Encoding - HTTP | MDN](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Transfer-Encoding) 文档, 在第一行就写着 `http2` **禁用**除了 `trailers` 以外的所有 `Transfer-Encoding` 标头. 而 Qmsg 恰好就使用了 `http2`.

## httpClient 的正确姿势

```csharp
using var req = new HttpRequestMessage(HttpMethod.Post, url);

// 失败
// JsonContent.Create会返回stream,所以不会计算长度,也就无法获得Content-Length
// 即使设置req.Headers.TransferEncodingChunked = false,因为没有Content-Length, 导致TransferEncodingChunked也没有生效
// req.Content = JsonContent.Create(data);
// req.Headers.TransferEncodingChunked = false;

// 这里提前序列化成string, 采用StringContent就会带上 Content-Length
req.Content = new StringContent(JsonSerializer.Serialize(data), Encoding.UTF8, MediaTypeNames.Application.Json);

var httpResponseMessage = await httpClient.SendAsync(req);
```
