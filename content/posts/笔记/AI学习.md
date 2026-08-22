---
title: AI学习
tags:
  - blog
date: 2025-01-07
lastmod: 2026-05-29
categories:
  - blog
description: 
---

## 简介

这里记录 AI 学习。

- chat completion  对话
- tool calling 工具调用
- structured output 结构化输出（json 或特定格式）
- streaming 流式渲染
- image api 图像生成
- embedding 嵌入自己的文件，向量搜索

问与答

- tool calling 和 mcp 的区别
	- tool calling 是模型决定用 a 参数来调用 b 函数，是一种能力。
	- mcp 是一种标准，类似于 http api。
		- MCP 通常会被转换成 Tool Definitions，然后交给支持 Tool Calling 的模型使用。
		- 美团暴露 mcp 接口，然后我对接 mcp，转换成 tool 给大模型。
	- 举例：a 模型可以使用 tool，b 模型不行。那么即使把 mcp 接口转成 tool，b 模型也调用不了

## 简单使用

### 接口使用

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

### structured-outputs 结构化输出

问模型一个问题, 模型以 json 的形式返回给你. 类似于请求 api

- 每个模型的结构化输出方式不同
	- 千问 [生成JSON字符串](https://help.aliyun.com/zh/model-studio/qwen-structured-output?spm=a2c4g.11186623.0.0.c183240aNFcgmE#afab010a9018)
	- openai  [structured-outputs文档](https://platform.openai.com/docs/guides/structured-outputs)
		- sdk 支持定义一个 class 对象, 就不用自己写 json schema 了
		    - 支持 Python 的 [Pydantic](https://docs.pydantic.dev/latest/)
		    - 支持 js 的 [Zod](https://zod.dev/)
		    - dotnet 暂时还不行... [dotnet的 structured outputs](https://github.com/openai/openai-dotnet?tab=readme-ov-file#how-to-use-chat-completions-with-structured-outputs)

### function calling 方法调用

[function calling文档](https://platform.openai.com/docs/guides/function-calling)

告诉模型你有一个函数, 让模型从用户回答中提取出参数, 然后告诉我们，参数和要调用的函数, 我们执行这个函数，将结果返回给模型。模型拿到结果，再返回给用户.

流程如下

1. 自己写一个函数
2. 告诉模型我的函数定义
3. message 和函数一起传递给模型
4.
- 模型决定不调用函数（字段 tool_calls 为空）, 直接响应给用户, 继续让用户输入.
- 模型调用函数（字段 tool_calls 不为空，里面包含了  ）, 读取模型提供的参数, 我用这个参数调用函数, 最后把所有内容传给模型, 再把模型结果返回给用户

>  记得要处理边缘情况 (请求被 max token 截断), 做错误处理

### temperature 调试

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

## 生图

- 模型
	- `stable diffusion 1.5`，简称 `sd1.5` 支持 512 分辨率
	- `sdxl` 支持 1024 分辨率
		- turbo 版本 512 分辨率，官方的
		- lighting 版本 1024 分辨率，字节训练的
		- **SDXL 训练 + SDXL Lightning 推理** ，这种是属于可接受，常见的用法
- comfyUI
