---
title: UUID
tags:
  - point
  - UUID
date: 2024-03-14
lastmod: 2024-07-13
categories:
  - point
---

UUID 是唯一标识符.

- 没有绝对唯一, 但可能性忽略不计. `103 万亿个版本 4 UUID 中找到重复项的概率是十亿分之一`
- 通常是 8-4-4-4-12 格式. `0f8fad5b-d9cb-469f-a165-70867728950e`
 - 有很多的版本标准. [[笔记/point/csharp|csharp]] 的 [Guid](https://learn.microsoft.com/en-us/dotnet/api/system.guid.newguid?view=net-8.0) 就是实现之一
     - v 4 版本是现在最常用的版本 `Guid.NewGuid()`
     - v 7 版本最新兼容 v 4 格式, 同时支持排序! 理论上可以完全替代 v 4 `Guid.CreateVersion7()`
         - api 的相关讨论 [Extend System.Guid with a new creation API for v7 · Issue #103658 · dotnet/runtime · GitHub](https://github.com/dotnet/runtime/issues/103658)
         - 默认使用 `DateTime.UtcNow`, 没有时区信息
         - 建议使用 `DateTimeOffset.UtcNow` 的时区信息来解决全球分布式 id 的问题, 可以让全球的数据排序的时候更准确.
        - 如果想指定时区, 在 aspnetcore 通过依赖注入的方式就实现 `ITimeProvider` 接口, 然后注入 `_timeProvider`, 使用 `Guid.CreateVersion7(_timeProvider.GetUtcNow()`

相关链接

- [Universally unique identifier - Wikipedia](https://en.wikipedia.org/wiki/Universally_unique_identifier)
