---
title: mysql教程
tags:
  - blog
  - mysql
  - docker
date: 1993-07-06
lastmod: 2024-03-20
categories:
  - blog
description: "有时候会自建 mysql [[笔记/point/mysql|mysql]] 测试配置. 所以记录一下配置和操作."
---

## 简介

有时候会自建 [[笔记/point/mysql|mysql]] 测试配置. 所以记录一下配置和操作.

## 安装

### docker 启动

```shell
# 名称ken-mysql
# 数据在本地/data/mysql-data
# 密码123
# 配置了字符集
# 优化资源占用 --table-open-cache=400 --table-definition-cache=400 --performance-schema=OFF
docker run --name ken-mysql -v /data/mysql-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123 -p3306:3306 -d mysql:latest --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

### deb 安装

```bash
mkdir mysql
cd mysql
# 下载地址 https://downloads.mysql.com/archives/community/
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-server_5.7.36-1ubuntu18.04_amd64.deb-bundle.tar
# 解压
tar xvf mysql-server_5.7.36-1ubuntu18.04_amd64.deb-bundle.tar
# 删掉测试包
rm -rf mysql-community-test_5.7.36-1ubuntu18.04_amd64.deb mysql-testsuite_5.7.36-1ubuntu18.04_amd64.deb
# 安装依赖
apt install libtinfo5 libmecab2 -y
# 安装
dpkg -i mysql*.deb
# 配置
systemctl enable mysql --now
mysql -uroot -p
password
```

### 集群 slave

`master` 节点操作

```bash
# /etc/mysql/mysql.conf.d/mysqld.cnf 配置文件开启
[mysqld]
log-bin
server-id=1
# 重启mysql
systemctl restart mysql

# 登录创建用户
show master status;
CREATE USER 'slave'@'%' IDENTIFIED BY 'slave';
grant replication slave, replication client on *.* to 'slave'@'%';
flush privileges;

flush table with read lock;
mysqldump -uroot -pmsb123 -A -B --events --master-data=2 > /root/mysql/db-bak-all.sql
unlock tables;
```

`slave` 节点操作

```shell
# 安装好mysql后,拷贝master的db-bak-all.sql文件过来
mysql -uroot -p  </root/mysql/db-bak-all.sql
systemctl restart mysql

# 下面要ip、用户名、密码、log文件、log-id。后面两个是show master status;的输出
change master to
master_host='master节点的ip',
master_user='slave',
master_password='slave',
# db-bak-all.sql会有写具体的值,抄过来就好
MASTER_LOG_FILE='mysql-bin-bin.000001',
MASTER_LOG_POS=769 ;

# 验证
show slave status\G
```

### 双主集群

主要原理：

- 不同的 `server_id`，使得节点在集群内唯一
- 开启 `gtid` 配置
- 通过不同的 `auto_increment_offset` 确定初始时的 id 不重复，通过 `auto_increment_increment` 确保自增 id 不重复
- 开启 `log-salve-updates` 使得节点直接的数据会互相同步
- `sync_binlog` 为 1 确保事务的完整性
- 创建数据同步账户，执行 `change master to...`，然后 `start slave`

参考链接：

- [MySQL集群部署：多主多从 | 程序猿DD](https://www.didispace.com/installation-guide/middleware/mysql-cluster-2.html#master%E8%8A%82%E7%82%B9%E9%85%8D%E7%BD%AE)
- [MySql集群之双主双从架构&集群主从配置（四）\_双服务器主从模式怎么设置-CSDN博客](https://blog.csdn.net/tianzhonghaoqing/article/details/125922812)
- [MYSQL-双主集群搭建 - 掘金](https://juejin.cn/post/7004991624061124622)

## 操作

### 处理锁

开启 `performance_schema` 参数, 才能查询这个库

1. 查看相关情况

    ```sql
    # 事务表
    # state是running说明事务持有锁
    select
    trx_mysql_thread_id '会话/线程id',
    trx_id 事务id,
    trx_state 事务状态,
    trx_started 事务开始时间,
    trx_tables_locked 锁表数量,
    trx_rows_locked 锁行数量
    from information_schema.innodb_trx;

    # 锁住的表
    select 
    wait_started 开始等待的时间,
    wait_age 等待时长,
    wait_age_secs 等待秒数,
    locked_table 锁住的表,
    blocking_lock_id 事务id,
    blocking_pid 进程id,
    sql_kill_blocking_connection 解决办法
    from sys.innodb_lock_waits
    where blocking_lock_id = '事务id';

    # 查看客户端的连接信息:用户名,ip,端口,连接的数据库等
    SELECT *
    FROM performance_schema.threads
    WHERE processlist_id = '会话/线程id'
    ```

2. 查看具体事务内容

    ```sql
    SELECT trx.trx_mysql_thread_id '会话/线程id', # 不是所有线程都有进程记录 select thread_id 线程id,processlist_id 进程id from performance_schema.threads;
            esh.event_name 'events_statements_history-事件名',
            esh.sql_text 'events_statements_history-sql'
    FROM information_schema.innodb_trx trx
    JOIN information_schema.processlist ps ON trx.trx_mysql_thread_id = ps.id
    JOIN performance_schema.threads th ON trx.trx_mysql_thread_id = th.processlist_id
    JOIN performance_schema.events_statements_history esh ON esh.thread_id = th.thread_id
    WHERE trx.trx_started < CURRENT_TIME - INTERVAL 10 SECOND
      and trx.trx_mysql_thread_id = 35405
      AND ps.USER != 'SYSTEM_USER'
    ORDER BY esh.EVENT_ID;
    ```

3. 杀掉连接

    ```sql
    # 杀死会话id
    kill 32
    ```

可以设置锁超时时间，自动杀掉超时会话

```sql
# 会话级别的锁超时，当前连接生效
set innodb_lock_wait_timeout=50;
# 全局级别的锁超时，对新连接生效
set global innodb_lock_wait_timeout=50;
```

> [Tracking MySQL query history in long running transactions](https://www.psce.com/en/blog/2015/01/22/tracking-mysql-query-history-in-long-running-transactions/)

### 用户/授权/密码

```sql
# 创建用户
CREATE USER 'ttt'@'%' IDENTIFIED BY '123456';
grant all privileges on  *.* to 'ttt'@'%';

# 授权
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX,TRIGGER,CREATE VIEW,SHOW VIEW ON `db`.`table` TO 'ttt'@'%';

# 改密码
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
FLUSH PRIVILEGES;
```

### 查看 binlog

使用 [[笔记/point/docker|docker]] 镜像来临时解析 binlog 是不错的。

使用哪个版本可以在 [mysql的docker页面](https://hub.docker.com/_/mysql) 找到。**注意**只有 `8.0.35-bullseye, 8.0-bullseye, 8.0.35-debian, 8.0-debian` 这几个 `-debian` 的版本里有 mysqlbinlog 工具

```shell
docker run -d -v /root/binlog_folder/:/tmp/binlog_folder/ -e MYSQL_ROOT_PASSWORD=123456 --name mysql mysql:8.0-debia

mysqlbinlog /tmp/binlog_folder/binlog_file > xxx.txt
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
