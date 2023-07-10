---
title: mssql的配置和使用
tags:
  - blog
  - mssql
  - docker
date: 2023-07-05
lastmod: 2023-07-06
categories:
  - blog
description: "这里记录 [[笔记/point/mssql|mssql]] 的常用命令和配置."
---

## 简介

这里记录 [[笔记/point/mssql|mssql]] 的常用命令和配置.

## 操作手册

### docker 启动

```shell
# ACCEPT_EULA=Y 接收用户协议
# SA_PASSWORD 密码
# MSSQL_PID 指定版本,默认 -e 'MSSQL_PID=Developer' 
# 版本参考 https://learn.microsoft.com/zh-cn/sql/sql-server/editions-and-components-of-sql-server-2019?view=sql-server-ver16
docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=123456' -p 1433:1433 -v /data/msdata:/var/opt/mssql/data -v /data/mslog:/var/opt/mssql/log -v /data/secrets:/var/opt/mssql/secrets -d --name mssql mcr.microsoft.com/mssql/server:latest
```

### sql 语法

```sql
# 日期转字符串
CONVERT(CHAR(8), CURRENT_TIMESTAMP, 112)    ---20060222
CONVERT(CHAR(19), CURRENT_TIMESTAMP, 120)   ---2006-02-22 16:26:08
CONVERT(CHAR(10), CURRENT_TIMESTAMP, 23)    ---2006-02-22

# 字符串转日期
cast('2013-03-01' as datetime)
cast('20130301' as datetime)
```
