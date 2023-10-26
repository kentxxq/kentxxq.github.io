---
title: grafana-tempo教程
tags:
  - blog
  - tempo
  - grafana
date: 2023-07-19
lastmod: 2023-10-26
categories:
  - blog
description: "grafana-tempo 是 [[笔记/point/grafana|grafana]] 公司的链路追踪组件"
---

## 简介

`grafana-tempo` 是 [[笔记/point/grafana|grafana]] 公司的链路追踪组件

## 内容

### 安装

前置条件:

- [[笔记/minio教程#安装|安装minio]]
- [[笔记/grafana-ui教程#安装|安装grafana-ui]]

开始安装

```shell
curl -Lo tempo_2.2.4_linux_amd64.tar.gz https://github.com/grafana/tempo/releases/download/v2.2.4/tempo_2.2.4_linux_amd64.tar.gz

# 安装
dpkg -i tempo_2.1.1_linux_amd64.deb
```

配置文件 `/etc/tempo/config.yml`

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
    block_retention: 48h                # configure total trace retention here

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
      endpoint: 192.168.31.210:9000
      bucket: demo1
      forcepathstyle: true
      #set to true if endpoint is https
      insecure: true
      access_key:  # TODO - Add S3 access key
      secret_key:  # TODO - Add S3 secret key
    wal:
      path: /tmp/tempo/wal         # where to store the the wal locally
    local:
      path: /tmp/tempo/blocks
overrides:
  metrics_generator_processors: [service-graphs, span-metrics]
```

启动:

```shell
systemctl enable tempo --now
```
