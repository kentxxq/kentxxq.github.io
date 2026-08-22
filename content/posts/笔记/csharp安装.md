---
title: csharp安装
tags:
  - blog
  - csharp
date: 2023-07-28
lastmod: 2023-07-30
categories:
  - blog
description: "[[笔记/point/csharp|csharp]] 的安装和排错."
---

## 简介

[[笔记/point/csharp|csharp]] 的安装和排错.

## 安装

[.NET 和 Ubuntu 概述 - .NET | Microsoft Learn](https://learn.microsoft.com/zh-cn/dotnet/core/install/linux-ubuntu) 通常 [[笔记/point/ubuntu|ubuntu]] 22.04 以及以上版本自带.

```shell
# 搜索
apt search dotnet

# 安装这个整合包即可
apt install dotnet7
```

## 排错

如果使用过程中出现无法找到 sdk, runtimes, libhostfxr 相关的信息, 是因为你混用了 `微软官方` 和 `Ubuntu官方` 包.

```shell
# 卸载
apt remove 'dotnet*' 'aspnet*' 'netstandard*'
# 移除微软残酷
rm -f /etc/apt/sources.list.d/microsoft-prod.list
apt update -y
# 重新安装
apt install dotnet7
```

可以参考官方文档 [排查 Linux 上的 .NET 包混杂问题 - .NET | Microsoft Learn](https://learn.microsoft.com/zh-cn/dotnet/core/install/linux-package-mixup?pivots=os-linux-ubuntu#my-linux-distribution-provides-net-packages-and-i-want-to-use-them)
