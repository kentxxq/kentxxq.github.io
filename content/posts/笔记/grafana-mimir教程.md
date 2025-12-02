---
title: grafana-mimir教程
tags:
  - blog
  - mimir
  - grafana
date: 2023-07-22
lastmod: 2024-06-05
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
curl -Lo mimir https://github.com/grafana/mimir/releases/latest/download/mimir-linux-amd64
chmod +x mimir
```

配置文件 `vim mimir.yml`

```yml
# 禁用多租户
multitenancy_enabled: false

# 端口
server:
  http_listen_port: 9090
  grpc_listen_port: 9091
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

### minio 配置文件

参考 [官方存储文档](https://grafana.com/docs/mimir/latest/configure/configure-object-storage-backend/)

```yaml
# 禁用多租户
multitenancy_enabled: false

# 端口
server:
  http_listen_port: 9090
  grpc_listen_port: 9091
  log_level: error

blocks_storage:
  s3:
    bucket_name: mimir-blocks

alertmanager_storage:
  s3:
    bucket_name: mimir-alertmanager

ruler_storage:
  s3:
    bucket_name: mimir-ruler

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

# 分片
store_gateway:
  sharding_ring:
    replication_factor: 1


common:
  storage:
    backend: s3
    s3:
      endpoint: minio-api.kentxxq.com
      region: us-east-1
      access_key_id: "你的id"
      secret_access_key: "你的key"
```

运行 `./mimir -config.file=mimir.yml`

### 守护进程

[[笔记/point/Systemd|Systemd]] 守护进程配置 `/etc/systemd/system/mimir.service`

```ini
[Unit]
Description=mimir
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3


[Service]
# 环境变量 $MY_ENV1
# Environment=MY_ENV1=value1
# Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
# EnvironmentFile=/path/to/environment/file1

#WorkingDirectory=/root/myApp/TestServer
ExecStart=/root/om/mimir/mimir -config.file=/root/om/mimir/mimir.yaml

# 总是间隔30s重启,配合StartLimitIntervalSec实现无限重启
RestartSec=30s 
Restart=always
# 相关资源都发送term后,后发送kill
KillMode=mixed
# 最大文件打开数不限制
LimitNOFILE=infinity
# 子线程数量不限制
TasksMax=infinity

[Install]
WantedBy=multi-user.target
#Alias=testserver.service
```

## 使用

- [[笔记/point/prometheus|prometheus]] 接口地址
    - `remote_write` : `http://localhost:9090/api/v1/push`
    - `grafana查询接口地址`: `http://localhost:9090/prometheus`
