---
title: grafana-tempo教程
tags:
  - blog
  - tempo
  - grafana
date: 2023-07-19
lastmod: 2024-06-05
categories:
  - blog
description: "grafana-tempo 是 [[笔记/point/grafana|grafana]] 公司的链路追踪组件"
---

## 简介

`grafana-tempo` 是 [[笔记/point/grafana|grafana]] 公司的链路追踪组件

## 安装

### 下载

```shell
curl -Lo tempo_2.5.0_linux_amd64.tar.gz https://github.com/grafana/tempo/releases/download/v2.5.0/tempo_2.5.0_linux_amd64.tar.gz

# 解压,得到可执行文件 tempo
tar xf tempo_2.5.0_linux_amd64.tar.gz 
```

### 配置文件

配置示例 `tempo.yaml`

```yml
server:
  http_listen_port: 3200

distributor:
  receivers:
    otlp:
      protocols:
        http:
          endpoint: 0.0.0.0:3201
        grpc:
          endpoint: 0.0.0.0:3202

compactor:
  compaction:
    block_retention: 48h   # configure total trace retention here

      #metrics_generator:
      #  registry:
      #    external_labels:
      #      source: tempo
      #      cluster: linux-microservices
      #  storage:
      #    path: /tmp/tempo/generator/wal
      #    remote_write:
      #    - url: http://localhost:9090/api/v1/write
      #      send_exemplars: true

storage:
  trace:
    backend: s3
    s3:
      endpoint: minio-api.kentxxq.com
      bucket: tempo
      forcepathstyle: true
      # 如果使用https,就注释掉下面这一行
      # insecure: true
      access_key:  # TODO - Add S3 access key
      secret_key:  # TODO - Add S3 secret key
    wal:
      path: /tmp/tempo/wal   # where to store the the wal locally
    local:
      path: /tmp/tempo/blocks
overrides:
  metrics_generator_processors: [service-graphs, span-metrics]
```

### 守护进程

[[笔记/point/Systemd|Systemd]] 守护进程配置文件 `/etc/systemd/system/tempo.service`

```ini
[Unit]
Description=tempo
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

ExecStart=/root/om/tempo/tempo -config.file=/root/om/tempo/tempo.yaml

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
