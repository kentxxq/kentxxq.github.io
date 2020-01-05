---
title:  mysql首次使用出现的问题
date:   1993-07-06 00:00:00 +0800
categories: ["笔记"]
tags: ["mysql"]
keywords: ["mysql","首次使用出现的问题"]
description: "mysql首次使用出现的问题"
---


## 关于中文问题

1. 默认安装后的sys库不进行修改
2. 在新建数据库时,进行数据库字符集的设置,推荐utf8

## 关于mysql引擎问题

1. 普遍使用innodb、myisam两种。前者支持事务、后者有更快的查询速度和索引
2. 在建表后加**engine=utf8**
2. 查看当前支持的mysql引擎
```sql
show engines
```

## 查看mysql安装后的初始密码

```bash
grep 'temporary password' /var/log/mysqld.log
```

## 让指定用户可以进行远程连接

```bash
[root@centos1 test]# mysql -uroot -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 7
Server version: 5.7.18 MySQL Community Server (GPL)

Copyright (c) 2000, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use mysql;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> update user set host='%' where user='root';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 1  Changed: 0  Warnings: 0
# 切记要刷新权限:
mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

```

### 如果还是有登陆问题

```bash
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';

flush privileges;


use mysql;

update user set host='%' where user='root';

flush privileges;


ALTER USER 'root'@'%' IDENTIFIED BY 'Aa5227860!';

flush privileges;


一些兼容问题
alter user 'root'@'%' identified with  mysql_native_password by 'password'

flask-sqlacodegen  --flask mysql+pymysql://root:'password'@47.75.155.134/test

```