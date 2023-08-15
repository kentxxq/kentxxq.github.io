---
title: csharp代码配置与命令
tags:
  - blog
date: 2023-08-15
lastmod: 2023-08-15
categories:
  - blog
description: "记录 [[笔记/point/csharp|csharp]] 的代码配置."
---

## 简介

记录 [[笔记/point/csharp|csharp]] 的代码配置.

## 配置


### 数据库连接字符串

#### Mysql

```
Server=ip或域名;Database=数据库;Uid=root;Pwd=密码;MinimumPoolSize=10;maximumpoolsize=50;
```

#### SqlServer

[[笔记/point/mssql|sql server]] 连接配置

```json
{
    "ConnectionStrings": {
        "BloggingDatabase": "Data Source=your_server_ip;Database=your_database_name;User ID=your_username;Min Pool Size=10;Password=your_password;Connect Timeout=30;Encrypt=False;TrustServerCertificate=False;ApplicationIntent=ReadWrite;MultiSubnetFailover=False"
  }
}
```

代码使用

```csharp
services.AddDbContextPool<BloggingContext>(
    options =>{
options.UseSqlServer(Configuration.GetConnectionString("BloggingDatabase")); }
    ,poolSize:64
);
```

## 命令

### 生成 user-jwts

```shell
dotnet user-jwts create  --role admin --role superadmin --audience ken(一般是url地址)  --claim is_allow=true(自定义claim)
```

### 更新所有 dotnet-tools

```powershell
dotnet tool list -g | ForEach-Object {$index = 0} { $index++; if($index -gt 2) { dotnet tool update -g $_.split(" ")[0] } }
```

### 生成 model

#### EFCore

```shell
# Sqlite
dotnet ef dbcontext  scaffold "Data Source=test. Db" -o Models Microsoft. EntityFrameworkCore. Sqlite -c "TestDbContext" -f
# Mysql
dotnet ef dbcontext scaffold "server=localhost; port=3306; user=root; password=mypass; database=sakila" MySql. Data. EntityFrameworkCore -o sakila -f
# 或者
Scaffold-DbContext "server=localhost; port=3306; user=root; password=mypass; database=sakila" MySql. Data. EntityFrameworkCore -OutputDir Models -f
# Oracle 
Scaffold-DbContext "Data Source=(DESCRIPTION =(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST = 192.168.0.220)(PORT = 1521)))(CONNECT_DATA =(SERVICE_NAME = orcl))); User ID=kentxxq; Password=mypass;" Oracle. EntityFrameworkCore -OutputDir Models
```

#### Freesql

```bash
FreeSql.Generator -Razor 1 -NameOptions 0,0,0,0 -NameSpace WebApplication1 -DB "MySql,data source=ip或地址;port=3306;user id=用户名;password=密码;initial catalog=库名;charset=utf8;sslmode=none;max pool size=2"
```
