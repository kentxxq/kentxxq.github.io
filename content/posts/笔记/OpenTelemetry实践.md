---
title: OpenTelemetry实践
tags:
  - blog
  - OpenTelemetry
  - grafana
  - prometheus
  - csharp
date: 2023-07-20
lastmod: 2024-06-27
keywords:
  - OpenTelemetry
  - grafana
  - loki
  - minio
  - mimir
  - prometheus
  - csharp
  - tempo
categories:
  - blog
description: "这篇文章会把关于 [[笔记/point/OpenTelemetry|OpenTelemetry]] 的相关文章串联起来, 从 0 到 1 完成所有的实践."
---

## 简介

这篇文章会把关于 [[笔记/point/OpenTelemetry|OpenTelemetry]] 的相关文章串联起来, 从 0 到 1 完成所有的实践.

其中会涉及到如下组件, 搭建顺序是**从下往上**:

- [APP代码放着这里](https://github.com/kentxxq/TestServer),是 [[笔记/point/csharp|csharp-aspnetcore]] Web 应用
    - 引入了 [opentelemetry-dotnet](https://github.com/open-telemetry/opentelemetry-dotnet/tree/main/src),  [opentelemetry-dotnet-contrib](https://github.com/open-telemetry/opentelemetry-dotnet-contrib/tree/main/src)
    -
    -
- [[笔记/grafana-alloy教程|alloy]] 接收应用数据.
    - 这里没有使用 [[笔记/OpenTelemetry-Collector教程|OpenTelemetry-Collector]], 是因为 `alloy` 会完全兼容它
    - 可以 [采集日志文件](https://grafana.com/docs/alloy/latest/tutorials/logs-and-relabeling-basics/) 等一些有用的拓展功能
    - 如果你是 [[笔记/point/golang|golang]] , [[笔记/point/python|python]], `rust` 等语言, 可以 [无代码侵入采集指标](https://grafana.com/docs/pyroscope/latest/configure-client/grafana-agent/ebpf/configuration/)
- [[笔记/grafana-loki教程|loki]] 处理日志
- [[笔记/grafana-mimir教程|mimir]] 处理指标
- [[笔记/grafana-tempo教程|tempo]] 处理链路追踪
- [[笔记/grafana-pyroscope教程|pyroscope]] 持续性能分析
- [[笔记/point/minio|minio]] 存放着所有的数据
- [[笔记/grafana-ui教程|grafana]] 做展示

![[附件/opentelemetry架构图.excalidraw.svg]]

- [官方的OTLP Receiver](https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md) log 处于 beta 阶段, 但使用起来没问题. 变动可能性较小了
- 可以看到 [[笔记/grafana-pyroscope教程|pyroscope]] 有点奇葩, 但这不是最终方案. [[笔记/point/elastic|elastic]] 捐献了自己的 profiling-agent. 等正式上线后, 应该会切换
    - elastic
        - [elastic 的捐献文章](https://www.elastic.co/observability-labs/blog/elastic-donation-proposal-to-contribute-profiling-agent-to-opentelemetry)
        - [elastic的开源profiling-agent](https://github.com/elastic/otel-profiling-agent)
    - opentelemetry
        - [OpenTelemetry关于profiling的博客](https://opentelemetry.io/blog/2024/elastic-contributes-continuous-profiling-agent/)
        - [接收 elastic 的捐献]( https://github.com/open-telemetry/community/issues/1918 )
    - 云原生博客
        - [Charting new territory: OpenTelemetry embraces profiling | CNCF](https://www.cncf.io/blog/2024/04/11/charting-new-territory-opentelemetry-embraces-profiling/)
        - [An improved OpenTelemetry continuous profiling agent | CNCF](https://www.cncf.io/blog/2024/06/07/an-improved-opentelemetry-continuous-profiling-agent/)

## 使用

### 搭建信息

按照教程搭建完成以后, 应该有如下端口:

| 服务          | 地址                                                                                                                           |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| minio         | api 请求 `minio-api.kentxxq.com`, ui 操作 `minio-ui.kentxxq.com`                                                               |
| loki          | 接收 oc 发送的日志数据 `http_listen_port/3100`, `grpc_listen_port/3101`                                                        |
| mimir         | 接收 oc 发送的指标数据 `http_listen_port/9090`, `grpc_listen_port/9091`                                                        |
| pyroscope     | 接收应用发送的 profile 数据 `http_listen_port/4040`, `grpc_listen_port/4041`                                                                                                                               |
| tempo         | 接收 oc 发送的追踪数据 `http_listen_port/3200`, `distributor.receivers.otlp.http/3201`, `distributor.receivers.otlp.grpc/3202` |
| grafana-alloy | 接收应用数据 `grpc/4317`, `http/4318`                                                                                          |
| grafana-ui    | ui 操作 `ip:3000`                                                                                                              |

配置好 `OC_Endpoint`, [启动web程序](https://github.com/kentxxq/TestServer) 即可在 [[笔记/grafana-ui教程|grafana-ui]] 查询到数据.

> 这里提供测试只读 grafana 账号
> 地址 [https://grafana.kentxxq.com/](https://grafana.kentxxq.com/)
> 用户名密码 `testuser/bTcgfGvZVw56jL`

### 查询流程

请求拿到 `traceid`

![[附件/OC实践-请求拿到traceid.jpg]]

查询 trace 链路信息

![[附件/OC实践-查询trace.jpg]]

关联的 log 日志数据

![[附件/OC实践-traceToLog.jpg]]

关联的 profiling 性能数据

![[附件/OC实践-traceToProfiling.jpg]]

关联的 metrics 指标数据

![[附件/OC实践-traceToMetrics.jpg]]

## 相关资料

- [opentelemetry-collector 的配置文档](https://opentelemetry.io/docs/collector/configuration/#receivers)
- Java 通过 agent 方式注入即可 [opentelemetry-java-instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)
