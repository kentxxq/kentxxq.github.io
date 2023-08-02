---
title: grafana-mimir教程
tags:
  - blog
  - mimir
  - grafana
date: 2023-07-22
lastmod: 2023-08-02
categories:
  - blog
description: 
---

## 简介

`grafna-mimir` 是 [[笔记/point/grafana|grafana]] 公司的存储产品, 是 [[笔记/point/prometheus|prometheus]] 的远程存储后端.

## 内容

### 单机安装

文档地址 [Get started with Grafana Mimir | Grafana Mimir documentation](https://grafana.com/docs/mimir/latest/get-started/#start-grafana-mimir)

下载对应版本

```shell
curl https://github.com/grafana/mimir/releases/latest/download/mimir-linux-amd64 -o mimir
chmod +x mimir
```

配置文件 `vim mimir-demo.yml`

```yml
# 禁用多租户
multitenancy_enabled: false

# 端口
server:
  http_listen_port: 9009
  grpc_listen_port: 9010
  log_level: error

blocks_storage:
  backend: filesystem
  bucket_store:
    sync_dir: /tmp/mimir/tsdb-sync
  filesystem:
    dir: /tmp/mimir/data/tsdb
  tsdb:
    dir: /tmp/mimir/tsdb

# 压缩,加速查询
compactor:
  data_dir: /tmp/mimir/compactor
  sharding_ring:
    kvstore:
      store: memberlist

# 接收数据,验证准确性,无状态
distributor:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist

# 写入数据的组件,有状态
ingester:
  ring:
    instance_addr: 127.0.0.1
    kvstore:
      store: memberlist
    replication_factor: 1

# 告警规则的存储位置
ruler_storage:
  backend: filesystem
  filesystem:
    dir: /tmp/mimir/rules
    
# 分片
store_gateway:
  sharding_ring:
    replication_factor: 1
```

运行 `./mimir --config.file=mimir-demo.yml`

### 守护进程

[[笔记/point/supervisor|supervisor]] 配置文件 `/etc/supervisor/conf.d/mimir.conf`

```toml
[program:mimir]
directory = /root
command = /root/mimir --config.file=/root/mimir-demo.yml

# 自动重启
autorestart = true
# 启动失败的尝试次数
startretries = 3
# 进程20s没有退出，则判断启动成功
startsecs = 20

# 标准输出的文件路径
stdout_logfile = /tmp/mimir-supervisor.log
# 日志文件最大大小
stdout_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stdout_logfile_backups = 5
# 标准输出的文件路径
stderr_logfile = /tmp/mimir-supervisor.log
# 日志文件最大大小
stderr_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stderr_logfile_backups = 5
```
