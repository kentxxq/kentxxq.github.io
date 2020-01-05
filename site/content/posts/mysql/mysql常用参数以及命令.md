---
title:  mysql常用参数以及命令
date:   1993-07-06 00:00:00 +0800
categories: ["笔记"]
tags: ["mysql"]
keywords: ["mysql","常用参数","命令"]
description: "mysql常用参数以及命令"
---


## 参数

```sql
# 允许导出数据的文件路径
secure-file-priv
```


## 常用命令

```sql
# 查看当前mysql版本支持的存储引擎
show engine
# 查看当前的参数
show variables 
show variables like '%engine%'

# 查看安装的插件
show plugins;

flush
# 一台机器只能保持一定的连接，如出现max_connect_errors问题
flush hosts 
# 关闭当前的日志文件，后续的日志记录到新的文件
flush logs
# 新建用户，修改权限之后，需要立即刷新，否则很有可能无法使用
flush privileges
# 把内存中的数据写入到表内
flush tables
# 锁住所有表以及解锁
flush tables with read lock
unlock tables
# 内存中的数据碎片整理
flush query cache



reset
# 清空所有缓存
reset query cache
```