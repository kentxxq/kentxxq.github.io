---
title: prometheus教程
tags:
  - blog
  - prometheus
  - devops
  - 监控
date: 2023-07-11
lastmod: 2023-07-19
categories:
  - blog
description: "记录 [[笔记/point/prometheus|prometheus]] 的相关使用."
---

## 简介

记录 [[笔记/point/prometheus|prometheus]] 的相关使用.

## 内容

### 安装

参考官网 [Installation | Prometheus](https://prometheus.io/docs/prometheus/latest/installation/)

1. 下载解压

    ```shell
    # 下载 https://prometheus.io/download/
    wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz 
    tar -xzvf prometheus-2.45.0.linux-amd64.tar.gz
    ```

2. [[笔记/point/supervisor|supervisor]] 配置文件 `/etc/supervisor/conf.d/prometheus.yml`

    ```toml
    [program:prometheus]
    command = /root/prometheus-2.45.0.linux-amd64/prometheus --config.file=/root/prometheus-2.45.0.linux-amd64/prometheus.yml
    
    # 自动重启
    autorestart = true
    # 启动失败的尝试次数
    startretries = 3
    # 进程20s没有退出，则判断启动成功
    startsecs = 20
    
    # 标准输出的文件路径
    stdout_logfile = /tmp/prometheus-supervisor.log
    # 日志文件最大大小
    stdout_logfile_maxbytes=20MB
    # 日志文件保持数量 默认为10 设置为0 表示不限制
    stdout_logfile_backups = 5
    
    # 标准输出的文件路径
    stderr_logfile = /tmp/prometheus-supervisor.log
    # 日志文件最大大小
    stderr_logfile_maxbytes=20MB
    # 日志文件保持数量 默认为10 设置为0 表示不限制
    stderr_logfile_backups = 5
    ```

3. 验证 `curl 127.0.0.1:9090`

### 常用配置

#### 启动配置

存储配置文档 [Storage | Prometheus](https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects)

```shell
# 指定配置文件
--config.file /etc/prometheus/prometheus.yml
# 默认存放路径
--storage.tsdb.path data/
# 保存多大默认是0 可以是512MB,2GB,1TB等等
--storage.tsdb.retention.size
# 默认15天
--storage.tsdb.retention.time 15d
```

#### 主配置文件

官网完整配置查看 [Configuration | Prometheus](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)

```yml
global:
  scrape_interval: 15s # 每15s采集一次
  evaluation_interval: 15s # 每15s进行一次规则计算,数据汇总
  # scrape_timeout: 10s # 默认10s超时

scrape_configs:
  # 极简
  - job_name: "demo_node"
    static_configs:
      - targets: ["localhost:9100"]
      
  # 常用配置
  - job_name: "demo_app"
    tls_config:
      insecure_skip_verify: true # 忽略证书
    scheme: https            # 默认http
    metrics_path: "/metrics" # 默认
    static_configs:
      - targets: ["192.168.31.100:5001"]
```

### 高可用采集

- 存储: [[笔记/point/prometheus|prometheus]] 的后端存储使用 mimir, 实际存放在 [[笔记/point/minio|minio]] 里. 通过集群的方式保证两者高可用.
- [[笔记/point/k8s|k8s]] 采集: 使用 [shards-and-replicas.md](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/shards-and-replicas.md) 多实例分片拓展.
- 动态服务发现: 使用现有方案过滤, 例如 [consul_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config), 通过 label 进行花费, 使多个节点均匀分配指标采集. 也可以使用 [file_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#file_sd_config) 自己编写一个动态服务发现
- 手动管理: 通常来说 [[笔记/point/prometheus|prometheus]] 的性能不弱, 部署一个起码能服务 1000 个以上的微服务, 即使手动部署, 也不会是一件太困难的事情.
