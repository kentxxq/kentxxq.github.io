---
title: prometheus教程
tags:
  - blog
  - prometheus
  - devops
  - 监控
date: 2023-07-11
lastmod: 2023-12-27
categories:
  - blog
description: "记录 [[笔记/point/prometheus|prometheus]] 的相关使用."
---

## 简介

记录 [[笔记/point/prometheus|prometheus]] 的相关使用.

## 安装和配置

### 安装

参考官网 [Installation | Prometheus](https://prometheus.io/docs/prometheus/latest/installation/)

1. 下载解压

    ```shell
    # 下载 https://prometheus.io/download/
    wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz 
    tar -xzvf prometheus-2.45.0.linux-amd64.tar.gz
    ```

2. [[笔记/point/Systemd|Systemd]] 配置文件 `/etc/systemd/system/prometheus.service`

    ```toml
    [Unit]
    Description=prometheus
    # 启动区间30s内,尝试启动3次
    StartLimitIntervalSec=30
    StartLimitBurst=3
    
    [Service]
    # 环境变量 $MY_ENV1
    # Environment=MY_ENV1=value1
    # Environment="MY_ENV2=value2"
    # 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
    # EnvironmentFile=/path/to/environment/file1
    
    WorkingDirectory=/root/prometheus-2.48.1.linux-amd64
    ExecStart=/root/prometheus-2.48.1.linux-amd64/prometheus --config.file=/root/prometheus-2.48.1.linux-amd64/prometheus.yml
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
    Alias=prometheus.service
    ```

3. 启动 `systemctl daemon-reload ; systemctl enable prometheus.service --now`
4. 验证 `curl 127.0.0.1:9090`

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

  # 服务发现 file_sd_config可以从文本文件去发现
  # 下面把注入到eureka的元数据prometheus_path的值,覆盖掉默认的metrics_path,使得prometheus能采集到metrics
  - job_name: "eureka_sd"
    relabel_configs:
      - source_labels: ["__meta_eureka_app_instance_metadata_prometheus_path"]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
    eureka_sd_configs:
      - server: 'http://172.26.54.108:8761/eureka'
```

### 高可用采集

- 存储: [[笔记/point/prometheus|prometheus]] 的后端存储使用 mimir, 实际存放在 [[笔记/point/minio|minio]] 里. 通过集群的方式保证两者高可用.
- [[笔记/point/k8s|k8s]] 采集: 使用 [shards-and-replicas.md](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/shards-and-replicas.md) 多实例分片拓展.
- 动态服务发现: 使用现有方案过滤, 例如 [consul_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config), 通过 label 进行花费, 使多个节点均匀分配指标采集. 也可以使用 [file_sd_config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#file_sd_config) 自己编写一个动态服务发现
- 手动管理: 通常来说 [[笔记/point/prometheus|prometheus]] 的性能不弱, 部署一个起码能服务 1000 个以上的微服务, 即使手动部署, 也不会是一件太困难的事情.

## 指标与查询

### 查询类型

1. `vector` 一个时刻的结果 instant query
2. `matrix` 一段时间的结果 range query

### 数据类型

1. `gauge` 当前值
2. `counter` 计数器  时间选择器只能用在这
3. `histogram` 直方图
4. `summary` 摘要

### 常用函数

- `rate` 配合时间，生成条状图
- `sum by(code) (rate(prometheus_http_requests_total[1m]))` 仅添加指定标签
- `sum without(code) (rate(prometheus_http_requests_total[1m]))` 去除标签
- `topk(5,xxx) xxx` 的前 5
- `bottomk(5,xxx) xxx` 的后 5
- `sum (rate(prometheus_http_requests_total[1m] offset 1h ) ) -sum (rate(prometheus_http_requests_total[1m]))` 环比增加与减少
- `absent(qweoj)===1` 表示指标 qweoj 不存在
- `histogram_quantile(0.99,sum (rate(prometheus_http_requests_total[1m])))` 分位置
- `rate(node_cpu_seconds_total{mode="idle"}[10m])*100` cpu 空闲率

### 查询示例

#### Pod 内存使用率

`取每个容器的最大内存值` / `requests 内存` * 100

```shell
(max(container_memory_working_set_bytes{namespace="default"}) by (pod) / sum(kube_pod_container_resource_requests_memory_bytes{namespace="default"}) by (pod)) * 100
```
