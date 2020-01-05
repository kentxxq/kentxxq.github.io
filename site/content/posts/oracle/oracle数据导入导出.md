---
title:  oracle数据导入导出
date:   2020-01-05 15:42:00 +0800
categories: ["笔记"]
tags: ["oracle"]
keywords: ["oracle","expdp","impdp","imp","exp","csv","文本导入"]
description: "虽然现在的互联网公司都流行mysql这样的免费数据库。但是在各行各业oracle还是非常主流的选择。无论是否有授权，很多的数据迁移都是在oracle之间进行的。所以这篇文章用来迁移一下自己的笔记，并进行梳理"
---

> 虽然现在的互联网公司都流行mysql这样的免费数据库。但是在各行各业oracle还是非常主流的选择。无论是否有授权，很多的数据迁移都是在oracle之间进行的。
> 
> 所以这篇文章用来迁移一下自己的笔记，并进行梳理。

开篇说明
===
我喜欢东西精简而不出错。所以尽量不给自己找麻烦。

所以很多的命令参数，但是我都没有用上。主要是因为在我的使用过程中，没有解决多余的问题，或者说没有提升体验。


plsql_develop
===
plsql是一个收费软件。但是国内你懂的，非常多的破解和绿色版。在我遇到的公司中，都是统一使用的工具。

特点
---

1. 适用于数据量不大的操作。非常简便。如果只是几千条数据，甚至我经常复制粘贴来处理日常工作。
2. 有自己的pde格式。可以导出导入tables数据。
3. 同时支持文本导入器。例如打开一个csv文件。然后通过字段映射，导入oracle。

exp和imp
===
一个历史悠长的工具。但是操作简单，oracle自带。

在我交接数据的过程中，生成dmp结尾文件几乎是统一标准。

特点
---

1. 适合统一的oracle的环境操作。
2. 你需要关注字符集问题(源数据库字符集、导出端字符集、导入端字符集、目标数据库字符集)。
3. 高版本兼容低版本，但是反之则不然！

exp表模式
---

```bash
# 导出数据。不导出索引。指定导出表名
exp user/pawd rows=y indexes=n file=path/exp.dmp log=exp.log tables=tab1,tab2,tab3
```

exp用户模式
---

```bash
# 指定导出用户
exp user/pawd owner=user rows=y indexes=n file=exp.dmp log=exp.log
```

exp完全模式
---

```bash
# 需要用高权限用户，然后导出全库。用到的极少。
exp user/pawd rows=y indexes=n full=y file=exp.dmp log=exp.log
```

imp导入方法
---

```bash
# 指定以前的用户名，导入到现在的用户名。不导入索引
# 可以指定导入的表名
# ignore=n 可以忽略创建错误，直接追加数据
# commit=y 可以定量提交。否则会占用大量的回滚空间后一次性提交
# 不加表名默认导入所有。适合用户模式。如果再加上full=y，那么就是全库导入了
imp user/pawd fromuser=user touser=pawd rows=y indexes=n commit=y file=exp.dmp log=imp.log tables=t1,t2,t3
```

expdp和impdp
===
这是一个比较新的oracle自带工具。更加强大易用。

但是运维方面你懂的，很多都是老油条了。所以主要用来自己处理工作中的问题。

特点
---

1. 性能好，速度快
2. 可以远程通过网络导入导出！
3. 提供参数跨oracle版本导入导出

前提条件
---
expdp和impdp都需要在数据库中指定目录。oracle自带也有目录给你用，但是我推荐自己放一个容易找的地方。

```sql
create directory dump_path_name as '/path/backup';
```

如果你不是在oracle服务器上操作，则需要在本地oracle建立dblink。然后通过参数network_link参数进行操作。


expdp使用方法
---

```bash
expdp system/123456 
# 指定用户接收数据
schemas=xiangxi 
directory=EXPDP_DIR 
# 不需要统计信息，源数据库的统计信息可能会让目标数据库的查询策略改变，可能影响性能。
# 还可以加上indexes等等，加快导出速度。
exclude=STATISTICS 
# 并行导出，速度翻倍！
parallel=4
# %U可以让文件自动从01,02...来命名，主要用来配合上面的并行参数。
dumpfile=xiangxi20160726_%U.dmp
logfile=xiangxi20160726.log 
# 可以过滤指定目标表的数据
query='xiangxi.T_SYS_LOGS:"WHERE 1=2"'
# 指定按照什么版本的dmp格式导出
version=11.2.0.1.0 
# 用来处理用户名不一致
remap_schema=old_schema:new_schema
# 用来处理表空间不一致
remap_tablespace=old_tablespace:new_tablespace
# 表如果存在，就跳过。还可以truncate清空表。APPEND追加。REPLACE替换。
TABLE_EXISTS_ACTION=SKIP
# network_link=dblink_name用来远程导出。
```

impdp使用方法
---

```bash
# 可以看到几乎相同。都是根据对应的expdp导出方法来进行参数设定
impdp xiangxi2/123456
directory=EXPDP_DIR 
dumpfile=xiangxi20160726_01.dmp,xiangxi20160726_02.dmp,xiangxi20160726_03.dmp,xiangxi20160726_04.dmp 
remap_schema=old_schema:new_schema
version=11.2.0.1.0
parallel=4
```

如何中止expdp
---

查看任务状态

```sql
select job_name,state from dba_datapump_jobs;
```

连接进去，看以查看状态
```sql
expdp \"sys/oracle as sysdba\" attach=SYS_EXPORT_SCHEMA_02
```

停止任务
```bash
stop_job=immediate 
```

干掉人物
```bash
kill_job
```

总结
===

其实只是一次笔记的搬迁整理。不过也正好巩固了一下知识。

后续可能还会追加信息，不过数据的交接已经足够使用了。