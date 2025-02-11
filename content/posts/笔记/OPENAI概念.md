---
title: OPENAI概念
tags:
  - blog
date: 2025-01-07
lastmod: 2025-01-08
categories:
  - blog
description: 
---

## 简介

这里记录 AI 接口的相关信息

## 简单使用

对话

```csharp
var model = "gpt-4o-mini"; // 豆包是ep-xxx-111这样的格式  
var key = "xxx-xxx-xxx-xxx";  
// 可以填写azure,gptus,或者兼容openai接口的服务商地址
// 豆包地址 https://ark.cn-beijing.volces.com/api/v3
var client = new ChatClient(model,new ApiKeyCredential(key),new OpenAIClientOptions{Endpoint = new Uri("https://ark.cn-beijing.volces.com/api/v3")});  
  
var messages = new List<ChatMessage>  
{  
    // system 是系统设置
    new SystemChatMessage("你是一个叫大大的助手")  
};  
// user 是用户响应
messages.Add(new UserChatMessage("你叫什么名字? 和我说 '你好'"));  
var completion= await client.CompleteChatAsync(messages);  

// assistant 是模型响应内容
messages.Add(new AssistantChatMessage(completion.Value.Content[0].Text));  
  
Console.WriteLine($"[ASSISTANT]: {completion.Value.Content[0].Text}");
```

stream 对话

```csharp
var completionUpdates = client.CompleteChatStreamingAsync(messages);
await foreach (StreamingChatCompletionUpdate completionUpdate in completionUpdates)
{
    if (completionUpdate.ContentUpdate.Count > 0)
    {
        Console.Write(completionUpdate.ContentUpdate[0].Text);
    }
}
```

## structured-outputs

[structured-outputs文档](https://platform.openai.com/docs/guides/structured-outputs)

问模型一个问题, 模型以 json 的形式返回给你. 类似于请求 api

- sdk 支持定义一个 class 对象, 就不用自己写 json schema 了
    - 支持 Python 的 [Pydantic](https://docs.pydantic.dev/latest/)
    - 支持 js 的 [Zod](https://zod.dev/)
    - dotnet 暂时还不行... [dotnet的 structured outputs](https://github.com/openai/openai-dotnet?tab=readme-ov-file#how-to-use-chat-completions-with-structured-outputs)

## function calling

[function calling文档](https://platform.openai.com/docs/guides/function-calling)

告诉模型你有一个函数, 让模型从用户回答中提取出参数, 然后我们调用函数, 给模型总结. 最后将结果返回给用户.

流程如下

1. 自己写一个函数
2. 告诉模型我的函数定义
3. message 和函数一起传递给模型
4.
- 模型不调用函数, 直接响应给用户, 继续让用户输入.
- 模型调用函数, 读取模型提供的参数, 我用这个参数调用函数, 最后把所有内容传给模型, 再把模型结果返回给用户
1. 处理边缘情况 (请求被 max token 截断), 做错误处理

## temperature

- 值越大, 结果越随机
- 随机性大
    - 创作一个美丽的图片. 有很多美丽的形式
    - 对话
    - 翻译
    - 写作
- 随机性小
    - 把图片里的脸换成我的脸. 非常明确, 不需要其他的变化
    - 数学题
    - 有明确注释的代码
    - 数据分析
