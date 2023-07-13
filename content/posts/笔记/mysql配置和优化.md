---
title: mysql配置和优化
tags:
  - blog
  - mysql
  - docker
date: 1993-07-06
lastmod: 2023-07-05
categories:
  - blog
description: "有时候会自建 mysql [[笔记/point/mysql|mysql]] 测试配置. 所以记录一下配置和操作."
---

## 简介

有时候会自建 [[笔记/point/mysql|mysql]] 测试配置. 所以记录一下配置和操作.

## 操作

### sql 命令

```shell
# 创建用户
CREATE USER 'ttt'@'%' IDENTIFIED BY '123456';
grant all privileges on  *.* to 'ttt'@'%';

# 授权
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX,TRIGGER,CREATE VIEW,SHOW VIEW ON `db`.`table` TO 'ttt'@'%';

# 改密码
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
FLUSH PRIVILEGES;

```

### docker 启动

```shell
# 名称ken-mysql
# 数据在本地/data/mysql-data
# 密码123
docker run --name ken-mysql -v /data/mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123 -p3306:3306 -d mysql:latest
```

## 配置

### 最大连接数

```shell
# 配置最大连接数
show variables like '%max_connection%';
set global max_connections=1000;

# 配置文件
[mysqld]
max_connections = 1000
```

### 慢 sql

```shell
# 先配置保存的位置
# 如果是写入到file，那么就不会输出到表
show variables like "%log_output%";
set global log_output = file;
set global log_output = "TABLE";
# 慢日志的地址
show variables like '%slow_query_log%'
# 查看慢查询的定义
show global variables like 'long_query_time';
# 改成1秒就算慢查询
set global long_query_time=1

# 开启log
show variables like "general_log%";
set global general_log = 'ON';
# 非常占用性能，测试完就关闭
SET GLOBAL general_log = 'OFF';

# 输出到表的话，就查这里
select * from mysql.slow_log;
# 转换blob为text
select CONVERT( `sql_text`  USING utf8) from mysql.slow_log;


# 配置文件
[mysqld]
log_output = TABLE
long_query_time = 1
general_log = ON
```
