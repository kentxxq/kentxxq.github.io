---
title: Task的使用
tags:
  - blog
  - csharp
date: 2023-07-08
lastmod: 2023-07-08
categories:
  - blog
description: "总结一下在 [[笔记/point/csharp|c#]] 中几种 Task 的用法."
---

## 简介

总结一下在 [[笔记/point/csharp|c#]] 中几种 Task 的用法.

## 对比

| 方法                                                   | 适用场景       |
| ------------------------------------------------------ | -------------- |
| Task.Run                                               | 通用，适用异步 |
| Task.Factory.StartNew(TaskCreationOptions.LongRunning) | 钻牛角尖       |

下面全都是你想用 Task.Factory.StartNew 的必备条件

1. 你想要新启一个线程来运行，因为会堵塞太久。
2. 是同步方法。因为异步并不会在新启动的线程运行（参考链接），甚至因为开线程，切换线程影响性能。
3. 会并发。如果最多同时 1 个，那没必要。
4. 你很了解现在的线程池情况，你对线程池扩容的逻辑你不满意，你必须现在就申请一个新线程。否则会自动扩容的。
5. 不想用 `backgroundService后台执行` 和 `mq消息队列替代`

### 参考链接

- [LongRunning 的错误用法](https://www.newbe.pro/Others/0x026-This-is-the-wrong-way-to-use-LongRunnigTask-in-csharp/#%E8%BF%99%E6%A0%B7%E5%85%B6%E5%AE%9E%E6%98%AF%E9%94%99%E8%AF%AF%E7%9A%84)
- [devblog 官方](https://devblogs.microsoft.com/pfxteam/task-run-vs-task-factory-startnew/)
- [线程池](https://learn.microsoft.com/en-us/dotnet/api/system.threading.threadpool?view=net-7.0)
- [问题解答](https://stackoverflow.com/questions/37607911/when-to-use-taskcreationoptions-longrunning)
