---
title: grafana-loki教程
tags:
  - blog
  - promtail
  - loki
  - grafana
date: 2023-07-17
lastmod: 2024-06-05
categories:
  - blog
description: "grafana-loki 是 [[笔记/point/grafana|grafana]] 公司的日志采集组件"
---

## 简介

`grafana-loki` 是 [[笔记/point/grafana|grafana]] 公司的日志采集组件

## 安装

### 快速验证

[Loki安装文档链接](https://grafana.com/docs/loki/latest/setup/install/local/),因为网络不佳, 所以使用二进制安装方式.

1. 去 [Releases · grafana/loki](https://github.com/grafana/loki/releases/) 下载 `loki-linux-amd64.zip` 和 `promtail-linux-amd64.zip` 压缩文件
2. 下载配置文件

    ```shell
    # loki启动配置文件
    wget https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml

    # promtail启动配置文件
    wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml
    ```

3. 启动

    ```shell
    # windows
    .\loki-windows-amd64.exe --config.file=loki-local-config.yaml
    # linux
    ./loki-linux-amd64 -config.file=loki-local-config.yaml
    ```

### loki 配置文件

相关配置链接:

- [loki的Storage文档](https://grafana.com/docs/loki/v2.9.x/storage/#on-premise-deployment-minio-single-store)
- [阿里云OSS配置](https://grafana.com/docs/loki/latest/configure/examples/#alibaba-cloud-storage-configyaml)
- [s3集群配置](https://grafana.com/docs/loki/latest/configure/examples/#2-s3-cluster-exampleyaml)

#todo/笔记  loki 集群的配置?

[[笔记/point/minio|minio]] 版本 (需要提前准备好 minio 的 key ,并创建名为 loki 的 buckets)

```yml
# 多租户的话,要启用这个. 每个租户一个文件夹
# 一个租户的话, 数据都会放在 fake 文件夹下面
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 3101

common:
  instance_addr: 0.0.0.0
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

query_range:
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        max_size_mb: 100

storage_config:
  aws:
    # Note: use a fully qualified domain name, like localhost.
    # full example: http://loki:supersecret@localhost.:9000
    s3: https://你的id:你的key@minio-api.kentxxq.com.:443/loki
    s3forcepathstyle: true
  tsdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/index_cache
    cache_ttl: 24h         # Can be increased for faster performance over longer query periods, uses more disk space

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: s3
      schema: v13
      index:
        prefix: index_
        period: 24h

limits_config:
  # 全局保留一周数据
  retention_period: 168h

compactor:
  working_directory: /tmp/loki/compactor
  # 必须配置要操作的store
  delete_request_store: aws
  retention_enabled: true
  # 因为组件的机制问题,避免查询失败. 必须延迟删除. 所以要设置一个时间
  retention_delete_delay: 2h
  compaction_interval: 5m
```

### 守护进程

[[笔记/point/Systemd|Systemd]] 配置文件 `/etc/systemd/system/loki.service`

```ini
[Unit]
Description=loki
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

ExecStart=/root/om/loki/loki -config.file=/root/loki.yaml

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

## 查询日志 LogQL

### 常用语法

```shell
# 查询标签
{filename="/var/log/syslog"}
=相等 !=不相等 =~正则匹配 !~正则不匹配

# 标签+包含字符
{filename="/var/log/syslog"}|= "Day"
|=包含 !=不包含 |~正则匹配 !~正则不匹配

# 向量和运算符
# 最近5分钟的日志记录数
count_over_time({filename="/var/log/syslog"}[$__range])
```

### 日志分割

官网有几个日志分析的示例放在 [LogQL Analyzer | Grafana Loki documentation](https://grafana.com/docs/loki/latest/logql/analyzer/),下面写一个日常会遇到的.

如果有多行日志, 可以在采集的时候配置 [multiline | Grafana Loki documentation](https://grafana.com/docs/loki/latest/clients/promtail/stages/multiline/)

```shell
# 日志格式
level=info|ts=2022-03-23T11:55:29.846163306Z|caller=main.go:112|msg="Starting|Grafana|Enterprise|Logs"
level=debug|ts=2022-03-23T11:55:29.846226372Z|caller=main.go:113|version=v1.3.0|branch=HEAD|Revision=e071a811|LokiVersion=v2.4.2|LokiRevision=525040a3
level=warn|ts=2022-03-23T11:55:45.213901602Z|caller=added_modules.go:198|msg="found|valid|license"|cluster=enterprise-logs-test-fixture
level=info|ts=2022-03-23T11:55:45.214611239Z|caller=server.go:269|http=[::]:3100|grpc=[::]:9095|msg="server|listening|on|addresses"
level=debug|ts=2022-03-23T11:55:45.219665469Z|caller=module_service.go:64|msg=initialising|module=license
level=warm|ts=2022-03-23T11:55:45.219678992Z|caller=module_service.go:64|msg=initialising|module=server
level=error|ts=2022-03-23T11:55:45.221140583Z|caller=manager.go:132|msg="license|manager|up|and|running"
level=info|ts=2022-03-23T11:55:45.221254326Z|caller=loki.go:355|msg="Loki|started"

# 查询语句
{job="analyze"} | pattern "<level>|<time>|<caller>|<msg>"  | level="level=info"
```
