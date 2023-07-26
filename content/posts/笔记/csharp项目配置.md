---
title: csharp项目配置
tags:
  - blog
  - csharp
date: 2023-07-26
lastmod: 2023-07-26
categories:
  - blog
description: 
---

## 简介

[[笔记/point/csharp|csharp]] 的项目相关配置, 帮助组织规范项目.

## 内容

### 锁定依赖版本

在项目文件 `csproj` 中添加 `RestorePackagesWithLockFile`

```xml
<Project>
    <PropertyGroup>
        <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
    </PropertyGroup>
</Project>
```
