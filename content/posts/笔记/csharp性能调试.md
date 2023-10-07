---
title: csharp性能调试
tags:
  - blog
  - csharp
date: 2023-08-16
lastmod: 2023-09-27
categories:
  - blog
description: "记录 [[笔记/point/csharp|csharp]] 的性能调试. #todo/笔记"
---

## 简介

记录 [[笔记/point/csharp|csharp]] 的性能调试. #todo/笔记

所有的 dotnet 全局工具在这里 [.NET Diagnostic tools overview - .NET | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/tools-overview)

## 内容

### 采集所有监控数据

[dotnet-monitor](https://learn.microsoft.com/en-us/dotnet/core/diagnostics/dotnet-monitor)

### 查看 dotnet 应用

```bash
dotnet-counters.exe ps
```

### 查看指定进程的状态

```bash
# 每秒刷新1次进程22884的情况
dotnet-counters monitor --refresh-interval 1 -p 22884
```

### 内存转储

```bash
dotnet-dump collect -p 4807
```

### 分析转储文件

```bash
dotnet-dump analyze core_20190430_185145

# 输入 SOS 命令
# 分析对象大小与占用
dumpheap -stat

# 查看指定对象的情况  方法表 (MT)
dumpheap -mt 00007faddaa50f90

# 查看此资源大多被什么对象所持有，由此定位问题
gcroot -all 00007f6ad09421f8
```

### 追踪 cpu 等资源变化

```bash
dotnet-trace collect -p pid
# 等待一段时间后enter或ctrl+c关闭
# 抓到本地以后用perfview打开分析
https://github.com/microsoft/perfview
```
