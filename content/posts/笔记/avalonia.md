---
title: avalonia
tags:
  - blog
date: 2025-03-28
lastmod: 2025-03-28
categories:
  - blog
description: 
---

## 命令

创建

```shell
// 安装模板
dotnet new install Avalonia.Templates

// 创建sln
dotnet new avalonia.xplat -n ava

// 创建csproj项目
dotnet new avalonia.mvvm -n ava
```

使用

```shell
// 构建
// 构建对应版本, 就去对应的项目执行就好了
dotnet publish -c Release
```

## 配置

### 减少内存占用

在 `Program.cs` 配置使用软件渲染, 不使用 gpu 加速. 就会加快

```cs
.With(new Win32PlatformOptions  
{  
    RenderingMode = [Win32RenderingMode.Software]  
})  
.WithInterFont()
```

### android 报错

```xml
<AndroidSdkDirectory>D:\Android\android-sdk</AndroidSdkDirectory>
```
