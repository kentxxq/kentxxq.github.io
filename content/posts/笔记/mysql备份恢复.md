---
title: mysql备份恢复
tags:
  - blog
  - mysql
date: 1993-07-06
lastmod: 2023-07-11
categories:
  - blog
keywords:
  - "mysql"
  - "备份"
  - "恢复"
description: "mysql备份恢复"
---

## 简介

这里介绍 [[笔记/point/mysql|mysql]] 的几种备份恢复方法.

1. into outfile，适合在工作中导出指定的报表数据等
2. mysqldump 轮流进行锁表
3. innobakcupex(暂时发现最好用的备份工具，且开源)

## into outfile---load infile

```sql
# 导入到指定的文件位置
select * into outfile 'secure_file_priv' fields terminated by ',' from test
# 导入指定的文件到表
load data infile '/var/lib/mysql-files/20170628' into table test fields terminated by ',';

# 注意 secure_file_priv路径位置，否则无法导出
# 注意 表必须存在，然后导入数据。 并不是删除表后可以重建表
```

## mysqldump 导出为 sql 脚本，可以直接运行进行恢复

```bash
# 指定表
mysqldump -u root -p databasename tablename > /tmp/20170628_databasename_tablename.sql
# 指定数据库
mysqldump -u root -p --databases databasename1 databasename2  > /tmp/20170628_databasename.sql
# 备份全部数据库
mysqldump -u root -p -all-databases  > /tmp/20170628_databasename.sql
```

## innobackupex 的使用 (这个是 xtrabackup 的封装，可以备份多种类的存储引擎文件)

```bash
# 备份
innobackupex --user=root --password=password /tmp/backups
# 把备份里面日志等进行检查提交操作，让备份可以正常使用
innobackupex --apply-log /extrabackup/2016-04-27_07-30-48/
# 这里需要把文件全部都清空，并且需要注意文件的所有者、读写权限。
# 进行恢复，然后重启即可正常使用
innobackupex --copy-back /tmp/backups/2017-07-02_00-51-21/


# 增量备份
innobackupex --user=root --password=password /tmp/backups --incremental --incremental-basedir=/tmp/backups/full_bak
# 增量恢复
innobackupex --apply-log --redo-only /tmp/backups/full_bak --incremental-dir=/tmp/backups/incremental_bak

# 在上面要注意--redo-only参数,在合并最后一个增量备份的时候，不需要加上这个参数！！
# 如果没有redo-log这个参数，会进行回滚操作。将无法添加增量事务。最后一个因为则没有了后续的增量事务。
```

> 关于 redo-only，我翻来覆去看了官网文档和各种 blog，想了 2 天......终于理解了。
 
1. 在完全备份的时候，数据库可能正在进行一个 update 操作，数据量很大，时间很长，差不多需要 2 天时间。为了保证备份可用，进行了回滚操作。在日志中 update 语句没有能够正确保存结果到备份。
2. 在第二天，你开始进行增量备份。这一个 update 已经完成了操作，日志只记录并且进行 commit 提交。由于之前的备份进行了回滚，导致这个 commit 是不成功的。这一个 update 操作回滚掉后，没有了数据需要提交。
3. 这样下来，就造成了数据的丢失。
4. 在官方文档中说，无法添加后续的增量事务。应该是说这个 update 操作后续 (完成备份后第二天 update 语句进行的操作) 的改动，都没有办法应用。
5. 同理，无论第一步中式完全备份还是增量备份，都会导致这个问题。所以使用 redo-only 参数保证 update 操作在是最后一个可用备份之前，没有回滚掉。
6. 如果在之后的备份中，日志记录了提交或者回滚，则正常提交或回滚了这个 update 操作的数据。  如果没有后续记录，则说明这个 update 操作还没有完成，为了保证备份可用，回滚掉。并将在之后的备份中进行 commit 或回滚,而不进行 redo-only
7. 第六步中都保证了备份可用。

## 冷备份

1. 关掉 mysql
2. 直接拷贝数据文件
3. 到指定机器上面粘贴即可
> 注意：只有 myisam 存储引擎的表，才能这样备份！
