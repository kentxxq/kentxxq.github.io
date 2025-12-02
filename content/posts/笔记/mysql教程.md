---
title: mysql教程
tags:
  - blog
  - mysql
  - docker
date: 1993-07-06
lastmod: 2025-11-27
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

### k8s 单点

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql
  namespace: default
  labels:
    app: mysql
spec:
  type: NodePort
  selector:
    app: mysql
  ports:
    - port: 3306
      name: mysql

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: default
spec:
  serviceName: "mysql"
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          ports:
            - containerPort: 3306
              name: mysql
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "fake_password"
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes:
          - ReadWriteOnce
        storageClassName: nfs184
        resources:
          requests:
            storage: 10Gi
```

### apt 仓库

使用 [mysql-清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/help/mysql/)

```shell
vim /etc/apt/sources.list.d/mysql-community.list
deb https://mirrors.tuna.tsinghua.edu.cn/mysql/apt/ubuntu jammy mysql-8.0 mysql-tools
apt update -y
apt install mysql-server
systemctl status mysql
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

要点:

- 主节点可以写. 从节点 `read_only=1` 不能写. 挂了以后切换到从节点, 只能读.
- 或者
- 从节点可以写. 但是主节点挂了以后, 不再自动切换过去

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
mysqldump -uroot -pmsb123 -A -B --events --source-data=2 > /root/mysql/db-bak-all.sql
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
# db-bak-all.sql的头部会有写这两个值. 
# 示例 CHANGE MASTER TO MASTER_LOG_FILE='binlog.000003', MASTER_LOG_POS=157;
MASTER_LOG_FILE='mysql-bin-bin.000001',
MASTER_LOG_POS=769 ;

# 验证
show slave status\G
```

正常情况切换主库.  或者主库坏了, 延迟很低. 不需要追补数据的时候.

```shell
# 主库只读
set global read_only=ON;
set global super_read_only=ON;
# 查看状态
# slave_io_runnning,slave_sql_runnning 是yes 说明同步正常
# seconds_behind_master为0,说明没有延迟.10就是10秒
show slave status\G
# 确保gtid一致. 主从都执行
select @@global.gtid_executed;
# 从库停止slave,关闭只读
stop slave;
reset slave all;
set global read_only=off;
set global super_read_only=off;
# 主库
change master to ......
start slave;
# 验证状态yes,延迟很低
show slave status\G
```

追补数据需要在**从库/新主库关闭 slave 后操作**

- 主库无法启动. 但是有 binlog.

```shell
select @@global.gtid_executed
# 出现类似uuid的记录

# 生成sql,手动分析这还行
mysqlbinlog -vv --base64-output=decode-rows --exclude-gtids='uuid,uuid' /xxx/binlog-file > /tmp/binlog-file.sql

# 新主库没有写入数据,说明不会冲突,可以直接导入
mysqlbinlog -vv --base64-output=decode-rows --exclude-gtids='uuid,uuid' /xxx/binlog-file > /tmp/binlog-file.sql | mysql -uroot -p -S /xxx/mysql.sock -P3306
```

- 主库可以启动. 新主库没有写入, 那么直接 changbe master 重新同步就好了.

```shell
# https://github.com/liuhr/my2sql
# 如果新主库有写入
my2sql -user xxx -password xxx -work-type 2sql -start-file /xxx/binlog-file -start-pos=10 --add-extraInfo --exclude-gtids='uuid' -output-dir /tmp/sql-folder
# 会出现多个sql文件,选择性追加到新主库
```

相关链接

- [基于Keepalive + MySQL主从实现高可用架构](https://yangcongchufang.com/keepalived-mysql-master-slave.html)
- [MySQL集群部署：一主多从 | 程序猿DD](https://www.didispace.com/installation-guide/middleware/mysql-cluster-1.html#%E7%AC%AC%E4%BA%8C%E6%AD%A5-51%E4%B8%BB%E6%9C%BA%E9%85%8D%E7%BD%AEslave)
- [MySQL 主从切换步骤\_mysql主从切换-CSDN博客](https://blog.csdn.net/sinat_36757755/article/details/124049382)

### 双主集群

主要原理：

- 不同的 `server_id`，使得节点在集群内唯一
- 开启 `gtid` 配置
- 通过不同的 `auto_increment_offset` 确定初始时的 id 不重复，通过 `auto_increment_increment` 确保自增 id 不重复
- `sync_binlog` 为 1 确保事务的完整性
- 创建数据同步账户，执行 `change master to...`，然后 `start slave`
- A-master 认 B-master 是主节点. B-master 认 A-master 是主节点
- 开启 `log-slave-updates` 使得节点直接的数据会互相同步.

阿里云有 mgr 模式, 就是组复制. 这是更高级的集群模式

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

### 数据库空间

库大小排序

```sql
SELECT 
    table_schema AS `Database`,
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS `Size_MB`
FROM 
    information_schema.tables
GROUP BY 
    table_schema
ORDER BY 
    `Size_MB` DESC;
```

单库表大小排序

```sql
SELECT 
    table_name AS `Table`,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS `Size_MB`
FROM 
    information_schema.tables
WHERE 
    table_schema = 'your_database_name'
ORDER BY 
    `Size_MB` DESC;
```

### 导数据

```sql
INSERT INTO new_db.a SELECT * FROM old_db.b;
```

脚本复制库

```shell
#!/bin/bash
# 假设将sakila数据库名改为new_sakila

mysql -uroot -p123456 -e 'create database if not exists new_db'
list_table=$(mysql -uroot -p123456 -Nse "select table_name from information_schema.TABLES where TABLE_SCHEMA='old_db'")

for table in $list_table
do
    mysql -uroot -p123456 -e "rename table old_db.$table to new_db.$table"
done
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

## 压测

使用 [sysbench](https://github.com/akopytov/sysbench) 来压测.

1. 安装

    ```shell
    # 安装
    curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | sudo bash
    apt -y install sysbench
    ```

2. 创建数据库 `sbtest`
3. 准备数据

    ```shell
    sysbench --db-driver=mysql --mysql-host=XXX --mysql-port=XXX --mysql-user=XXX --mysql-password=XXX --mysql-db=sbtest --table_size=25000 --tables=250 --events=0 --time=600  oltp_read_write prepare
    ```

4. 执行压测

    ```shell
    sysbench --db-driver=mysql  --mysql-host=XXX --mysql-port=XXX --mysql-user=XXX --mysql-password=XXX --mysql-db=sbtest --table_size=25000 --tables=250 --events=0 --time=600   --threads=XXX --percentile=95 --report-interval=1 oltp_read_write run
    ```
