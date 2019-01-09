---
title:  DML_Error_Logging特性
date:   2017-07-19 00:00:00 +0800
categories: ["笔记"]
tags: ["oracle"]
---



> 在工作中，常常要进行数据的临时备份，还有导入数据的需求。但是却因为在源数据中**个别数据不合法**，导致无法插入。
功能效果：
1. 把合法的数据导入进入目标表
2. 把不合法的数据插入一张指定的表，并且记录下原因

需要用到dbms包(10gR2后版本支持)
---
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

创建源表source的目标表dest
---
```sql
BEGIN
  DBMS_ERRLOG.create_error_log (dml_table_name => 'SOURCE');
END;
```

 
在insert语句后按照固定格式填写
---
```sql
INSERT INTO dest
SELECT *
FROM   source
LOG ERRORS INTO err$_source('INSERT') REJECT LIMIT UNLIMITED;
```







