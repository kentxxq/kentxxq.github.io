---
title: oracle-DML_Error_Logging特性
tags:
  - blog
  - oracle
date: 2017-07-19
lastmod: 2023-07-11
categories:
  - blog
keywords:
  - oracle
  - "DML_Error_Logging"
  - 特性
description: "oracle的DML_Error_Logging特性"
---

## 简介

在工作中，常常要进行 [[笔记/point/oracle|oracle]] 数据的临时备份，还有导入数据的需求。但是却因为在源数据中**个别数据不合法**，导致无法插入。

功能效果：

1. 把合法的数据导入进入目标表
2. 把不合法的数据插入一张指定的表，并且记录下原因

### 需要用到 dbms 包 (10gR2 后版本支持)

```sql
SQL> DESC dbms_errlog.create_error_log
Parameter           Type     Mode Default? 
------------------- -------- ---- -------- 
DML_TABLE_NAME      VARCHAR2 IN            
ERR_LOG_TABLE_NAME  VARCHAR2 IN   Y        
ERR_LOG_TABLE_OWNER VARCHAR2 IN   Y        
ERR_LOG_TABLE_SPACE VARCHAR2 IN   Y        
SKIP_UNSUPPORTED    BOOLEAN  IN   Y        
SQL> 
--默认会创建ERR$_SOURCE表，在``第二个``参数可以自己输入表名 
```

### 创建源表 source 的目标表 dest

```sql
BEGIN
  DBMS_ERRLOG.create_error_log (dml_table_name => 'SOURCE');
END;
```

### 在 insert 语句后按照固定格式填写

```sql
INSERT INTO dest
SELECT *
FROM   source
LOG ERRORS INTO err$_source('INSERT') REJECT LIMIT UNLIMITED;
```
