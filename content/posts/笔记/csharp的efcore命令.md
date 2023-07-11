---
title: csharp的efcore命令
tags:
  - blog
date: 2023-07-11
lastmod: 2023-07-11
categories:
  - blog
description: 
---

## 简介

这里记录 [[笔记/point/csharp|csharp]] 的 efcore 命令.

## 内容

### 生成 Models

```shell
# Sqlite
Dotnet ef dbcontext  scaffold "Data Source=test. Db" -o Models Microsoft. EntityFrameworkCore. Sqlite -c "TestDbContext" -f
# Mysql
Dotnet ef dbcontext scaffold "server=localhost; port=3306; user=root; password=mypass; database=sakila" MySql. Data. EntityFrameworkCore -o sakila -f
# 或者
Scaffold-DbContext "server=localhost; port=3306; user=root; password=mypass; database=sakila" MySql. Data. EntityFrameworkCore -OutputDir sakila -f
# Oracle 
Scaffold-DbContext "Data Source=(DESCRIPTION =(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST = 192.168.0.220)(PORT = 1521)))(CONNECT_DATA =(SERVICE_NAME = orcl))); User ID=kentxxq; Password=mypass;" Oracle. EntityFrameworkCore -OutputDir Models
```

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
