---
title: OpenTelemetry-Collector教程
tags:
  - blog
  - OpenTelemetry
date: 2023-07-21
lastmod: 2023-10-26
categories:
  - blog
description: "`OpenTelemetry-collector` 是 [[笔记/point/OpenTelemetry|OpenTelemetry]] 官方的数据采集软件. 它和 [[笔记/grafana-agent教程|grafana-agent]] 的功能有些类似."
---

## 简介

`OpenTelemetry-collector` 是 [[笔记/point/OpenTelemetry|OpenTelemetry]] 官方的数据采集软件. 它和 [[笔记/grafana-agent教程|grafana-agent]] 的功能有些类似.

## 安装

### 安装形式

- 直连: ![[附件/opentelemetry-collector-单点部署.png]]
    - 优点
        - 简单, 方便开发测试
        - 上线不需要调整任何内容
    - 缺点
        - 改配置需要改动 app 代码
        - 强耦合
        - 每种开发语言处理起来都不一样
- Agent 采集 ![[附件/opentelemetry-collector-agent采集.png]]
    - 优点
        - 简单 1:1
        - 处理数据的时候, 可以和 app/语言无关
        - 如果用作 sidecar 很不错, 可以集成 [[笔记/OpenTelemetry-Collector教程|OpenTelemetry-Collector]] 配置到代码库中, 在 [[笔记/point/CICD|CICD]] 的过程中使用
    - 缺点
        - 如果不采用 sidecar 模式, 扩展性不好
- Gateway 采集 ![[附件/opentelemetry-collector-gateway采集.png]]
    - 优点
        - 负载均衡
        - 集中管理证书的内容
    - 缺点
        - 复杂性
        - 成本高
        - 延迟高了, 性能差了

### 单点 agent 采集安装

[Getting Started | OpenTelemetry](https://opentelemetry.io/docs/collector/getting-started/) 有很多的安装方法, 我用 deb 安装包方便使用.

```shell
wget https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.88.0/otelcol_0.88.0_linux_amd64.deb
dpkg -i otelcol_0.81.0_linux_amd64.deb

# 启用
systemctl enable otelcol --now
```

### 配置文件

配置文件 `/etc/otelcol/config.yaml`,完整配置参考官网 [Configuration | OpenTelemetry](https://opentelemetry.io/docs/collector/configuration/)

> 因为采用了非标准的 [[笔记/grafana-loki教程|grafana-loki]] 组件, 所以需要 [[笔记/OpenTelemetry-Collector教程#编译 opentelemetry-collector|自行编译]]

```yml
# 接收数据
# 接受prometheus,sdk等来源的数据.也可以是filelog采集本地日志文件
receivers:
  otlp:
    protocols:
      grpc:
      http:

# 处理数据
processors:
  # batch可以帮助压缩整合数据 https://github.com/open-telemetry/opentelemetry-collector/blob/main/processor/batchprocessor/README.md
  batch:
  # 插入loki的标签
  attributes:
    actions:
      - action: insert
        key: loki.attribute.labels
        value: log.file.name

# 导出数据
exporters:
  # debug查看日志
  logging:
    loglevel: debug
  # 推送数据到loki
  loki:
    endpoint: http://192.168.31.210:3100/loki/api/v1/push
  # 发送到mimir存储
  prometheusremotewrite/mimir:
    endpoint: http://192.168.31.210:9009/api/v1/push
  # 发送给tempo, 注意这里是grpc.上面2个是http协议
  otlp/tempo:
    endpoint: 192.168.31.210:3202
    tls:  
      insecure: true

# 必须在下面配置才会生效
service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [logging,otlp/tempo]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [logging,prometheusremotewrite/mimir]
    logs:
      receivers: [otlp]
      processors: [batch,attributes]
      exporters: [logging,loki]
```

### 编译 opentelemetry-collector

[[笔记/golang的使用#安装 golang|安装golang]], 安装 [构建工具builder](https://github.com/open-telemetry/opentelemetry-collector/tree/main/cmd/builder)

```shell
GO111MODULE=on go install go.opentelemetry.io/collector/cmd/builder@latest
```

创建一个临时文件目录 `mkdir oc-builder && cd oc-builder`, 构建配置文件 `oc-builder.yaml`

```yml
dist:
  name: otelcol-custom
  version: "1.0.0"
  description: Local OpenTelemetry Collector binary
  output_path: .
exporters:
  - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/lokiexporter v0.88.0
  # 内置木块 https://pkg.go.dev/go.opentelemetry.io/collector/exporter@v0.81.0#section-directories
  - gomod: go.opentelemetry.io/collector/exporter/loggingexporter v0.88.0
  - gomod: go.opentelemetry.io/collector/exporter/otlpexporter v0.88.0
  - gomod: go.opentelemetry.io/collector/exporter/otlphttpexporter v0.88.0
  - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusexporter v0.88.0
  - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusremotewriteexporter v0.88.0

receivers:
  - gomod: go.opentelemetry.io/collector/receiver/otlpreceiver v0.88.0

processors:
  - gomod: go.opentelemetry.io/collector/processor/batchprocessor v0.88.0
  - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/processor/attributesprocessor v0.88.0
```

- 构建命令 `builder --config=oc-builder.yaml`
> [!warning]
> 如果构建报错说依赖有问题, 更新配置 `ot-builder.yml` 的 `vXXX` 版本号.
- 启动测试 `./otelcol-custom --config=/etc/otelcol/config.yaml`
- [otlpreceiver](https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md) 默认 grpc 端口 4317, http 端口 4318.

### 守护进程

[[笔记/point/Systemd|Systemd]] 守护进程配置 `/etc/systemd/system/oc.service`

```ini
[Unit]
Description=oc
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

ExecStart=/root/oc-builder/otelcol-custom --config=/root/oc-builder/oc.yaml

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

## 有用的资料

### 负载均衡 exporter

[loadbalancingexporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/loadbalancingexporter) 是一个负载均衡 exporter. 例如你的 [[笔记/grafana-mimir教程|grafana-mimir]] 有多个节点的时候, 就可以用上负载均衡来高性能, 高可用.
