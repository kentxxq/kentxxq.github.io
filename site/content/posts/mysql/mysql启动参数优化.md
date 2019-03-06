---
title:  mysql启动参数优化
date:   2017-07-19 00:00:00 +0800
categories: ["笔记"]
tags: ["mysql"]
keywords: ["mysql","启动参数","优化"]
description: "mysql启动参数优化"
---


参数文件
===
```bash
[mysqld]

### 
#  基本相关配置
###
server-id=1
pid-file=/var/run/mysqld/mysqld.pid
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# 在linux中，文件可以进行ln，类似快捷方式。如果设置为1，则有可能会出现安全问题，默认配置中设置为0，进行关闭
symbolic-links=0
# 设置数据库字符集
character_set_server=utf8
# 禁止MySQL对外部连接进行DNS解析，使用这一选项可以消除MySQL进行DNS解析的时间。但需要注意，如果开启该选项，则所有远程主机连接授权都要使用IP地址方式，否则MySQL将无法正常处理连接请求
skip-name-resolve
character_set_filesystem=utf8
# 统一使用小写的表名
lower_case_table_names = 1




### 
#  日志配置
###
log-error=/var/log/mysqld.log
# 二进制日志路径
log-bin=/tmp/logbin
# 超过30天的binlog删除
expire_logs_days = 30
# 慢查询时间 超过1秒则为慢查询
long_query_time = 1
slow_query_log_file = /tmp/mysql-slow.log




### 
#  性能提升参数
###
# mysql最大连接数 查看max_used_connections，在最大值的70%左右最好
max_connections = 1000
# 官方：8 + (max_connections / 100)，上限100. 缓存的线程池不应该过多。
# 暂时我的业务高峰期，估计是200+的并发一直保持。50个应该足够
# 一般来说，大于4G的内存，预先缓存50个线程没有问题
thread_cache_size=10
# 表缓存分为多个区。5.7开始16为默认值，非常好！
# table_open_cache_instances=16
# 查询缓存关闭
# 听起来很美好的参数而已：如果表有insert、update等操作，表的相关所有cache失效
# 保存的是一个sql的查询结果集，而不是执行计划之类的
query_cache_size=0

# INNODB
# innodb非常好！所以默认使用它做存储引擎。 设置为总内存的80%
innodb_buffer_pool_size=800m
# 为提高性能，MySQL可以以循环方式将日志文件写到多个文件。推荐设置为3
innodb_log_files_in_group = 3
# SHOW GLOBAL STATUS like '%innodb_os_log_written%' 单位：字节
# 官方推荐innodb_log_files_in_group*innodb_log_file_size * 0.75 > 209MB，可以设置更大一些，但1小时内最好内进行一次刷入磁盘
innodb_log_file_size=140m
## 这里我启用的搭配模式，满足性能要求，系统一般情况下不会断电就不会崩溃。
# 控制数据库的事务日志刷到磁盘上
# 0:最快，但是进程崩溃就会丢失数据
# 1:最慢，数据会回滚没有提交的操作，数据保证一致
# 2:性能不错，除非操作系统不可用，才会丢失数据
innodb_flush_log_at_trx_commit=2
# 控制数据库的binlog刷到磁盘上
# 0:最快 系统决定
# n:10000>n>1 多少条日志记录后开刷
# 1:每次提交就开刷
sync_binlog=0
# O_DIRECT直接跨过os缓存，直接写入到文件。  直接在raid上操作数据会更快
# 默认为空：fsync                        直接连接到san存储，会更快
# O_DSYNC很少使用，没有上两个设置的优点
innodb_flush_method=O_DIRECT
# 不限制线程并发的数量，在大型系统中会进行集群，同时会分配好任务，所以不需要调整
# 如果是单个的数据库，最高并发数量达到了100，那么设置为80，将会很好的满足需求
innodb_thread_concurrency=0
# mysql5.7的默认值，会提高速度
innodb_checksum_algorithm=crc32
# 不会有很大的提升，但是如果你的磁盘非常快，可以提高到16-32之间
innodb_read_io_threads=8
innodb_write_io_threads=8
# 刷新脏数据时每秒写 IO请求数 默认200即可，除非用sysbench压力测试，tps一段时间内为0，是因为它的问题。而且磁盘速度非常快
# 数值过大，mysql认为磁盘能力很强，不会着急得把redo log刷到磁盘。而不大或者100这样比较小的值，则会认为磁盘能力一般，提早刷入磁盘
innodb_io_capacity=200
# 关闭的时候把缓冲了的数据记录id记录到文件，启动的时候加载进来，这样尽可能的让它在重启的时候，缓冲数据完全一致
innodb_buffer_pool_load_at_startup=on
innodb_buffer_pool_dump_at_shutdown=on




### 
#  连接相关参数
###
# 设置同一主机，最大可连接报错数。设置成100万没有特别大的影响，但是极大减少了flush hosts的次数
max_connect_errors=1000000
# 连接到达数量之后，排队的请求格式。超过600就会拒绝
back_log = 600
# 会话超过多久自动断开，默认秒，8小时
wait_timeout = 28800


# mysql可以打开的文件数       
open_files_limit = 65535


### 
# 备份工具innobackupex的备份路径
###
[xtrabackup]
target_dir = /tmp/backups

```



随记
===
为了搞定这一系列的参数，真是花了好大力气，也加深了对`mysql`的了解
```
2015-06-17 17:28:53 26720 [Warning] Buffered warning: Changed limits: max_connections: 5000 (requested 65535)
2015-06-17 17:28:53 26720 [Warning] Buffered warning: Changed limits: table_open_cache: 1995 (requested 2000)
```
这个问题的[解决办法](https://dev.mysql.com/doc/refman/5.7/en/using-systemd.html)
```bash
# 修改系统的参数
vi /etc/security/limits.conf
# 加入这两行，或者把*指定为mysql用户
*                soft    nofile          65535
*                hard    nofile          65535

# 这个是mysql服务的参数，也要加上
mkdir /etc/systemd/system/mysqld.service.d  //if not exists
vi limits.conf

[root@centos1 system]# cat /etc/systemd/system/mysql.service.d/override.conf
[Service]
LimitNOFILE=65535
```