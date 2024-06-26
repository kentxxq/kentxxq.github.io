---
title: grafana-alloy教程
tags:
  - blog
  - grafana
  - grafana-alloy
date: 2024-06-17
lastmod: 2024-06-20
categories:
  - blog
description: 
---

## 简介

`grafana-alloy` 是 [[笔记/point/grafana|grafana]] 的客户端组件, 替代 [[笔记/grafana-agent教程|grafana-agent]] .

使用它的原因主要是兼容 [[笔记/OpenTelemetry-Collector教程|OpenTelemetry-Collector]], 如果使用 [[笔记/point/grafana|grafana]] 全家桶, 可以减少配置项.

## 安装

- 安装:
    - 参考 [[笔记/grafana-ui教程#服务安装|grafana-ui的服务安装]] ,使用 `apt install alloy -y` 安装即可.
    - 使用 [[笔记/point/Systemd|systemd]] 进行服务管理.

## 配置文件

- 参考 [官方文档](https://grafana.com/docs/alloy/latest/tasks/collect-opentelemetry-data/)
    - `otlp` 是 `grpc` , `otlphttp` 是 `http1.1`

```
// 接收
otelcol.receiver.otlp "default" {
  grpc {
    endpoint = "0.0.0.0:4317"
  }

  http {
    endpoint = "0.0.0.0:4318"
  }

  output {
    metrics = [otelcol.processor.batch.default.input]
    logs    = [otelcol.processor.batch.default.input]
    traces  = [otelcol.processor.batch.default.input]
  }
}


// 处理
otelcol.processor.batch "default" {
  output {
    metrics = [otelcol.exporter.prometheus.default.input,otelcol.exporter.logging.default.input]
    logs    = [otelcol.exporter.loki.default.input,otelcol.exporter.logging.default.input]
    traces  = [otelcol.exporter.otlp.tempo.input,otelcol.exporter.logging.default.input]
  }
}

// 输出

// 日志debug
// https://grafana.com/docs/alloy/latest/reference/components/otelcol.exporter.logging/#example
otelcol.exporter.logging "default" {
    verbosity           = "detailed"
    sampling_initial    = 1
    sampling_thereafter = 1
}

// loki
// https://grafana.com/docs/alloy/latest/reference/components/otelcol.exporter.loki/
otelcol.exporter.loki "default" {
  forward_to = [loki.write.loki_server.receiver]
}

loki.write "loki_server" {
  endpoint {
    url = "http://127.0.0.1:3100/loki/api/v1/push"
  }
}

// mimir
// https://grafana.com/docs/alloy/latest/reference/components/otelcol.exporter.prometheus/
otelcol.exporter.prometheus "default" {
  forward_to = [prometheus.remote_write.mimir_server.receiver]
}

prometheus.remote_write "mimir_server" {
  endpoint {
    url = "http://127.0.0.1:9090/api/v1/push"
  }
}

// tempo
// https://grafana.com/docs/alloy/latest/reference/components/otelcol.exporter.otlp/#send-data-to-a-local-tempo-instance
otelcol.exporter.otlp "tempo" {
    client {
        endpoint = "127.0.0.1:3202"
        tls {
            insecure             = true
            insecure_skip_verify = true
        }
    }
}
```

## 其他

### 启用 debug 页面

`vim /etc/default/alloy`

添加内容

```toml
...
CUSTOM_ARGS="--server.http.listen-addr=0.0.0.0:12345"
...
```
