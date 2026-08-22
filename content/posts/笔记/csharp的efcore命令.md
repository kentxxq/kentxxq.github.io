---
title: sharp的efcore命令
tags:
  - blog
  - csharp
date: 2023-07-11
lastmod: 2023-09-27
categories:
  - blog
description: 
---

## 简介

这里记录 [[笔记/point/csharp|csharp]] 的 efcore 命令.

## 内容

### 数据库连接池

配置文件 `appsettings.json`

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "BloggingDatabase": "Data Source=your_server_ip;Database=your_database_name;User ID=your_username;Min Pool Size=10;Password=your_password;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False"
  }
}
```

注入依赖

```csharp
services.AddDbContextPool<BloggingContext>(
    options =>{
options.UseSqlServer(Configuration.GetConnectionString("BloggingDatabase")); }
    ,poolSize:64
);
```
