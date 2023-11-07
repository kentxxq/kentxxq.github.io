---
title: OpenTelemetry实践
tags:
  - blog
  - OpenTelemetry
  - grafana
  - prometheus
  - csharp
date: 2023-07-20
lastmod: 2023-11-07
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

- [APP代码放着这里](https://github.com/kentxxq/csharpDEMO/tree/main/Aspnetcore/AddOpentelemetry),是 [[笔记/point/csharp|csharp-aspnetcore]] Web 应用
- [[笔记/OpenTelemetry-Collector教程|OpenTelemetry-Collector]] 接收应用数据
- [[笔记/grafana-loki教程|loki]] 处理日志
- [[笔记/grafana-mimir教程|mimir]] 处理指标
- [[笔记/grafana-tempo教程|tempo]] 处理链路追踪
- [[笔记/point/minio|minio]] 存放着所有的数据
- [[笔记/grafana-ui教程|grafana]] 做展示

![[附件/opentelemetry架构图.excalidraw.svg]]

## 使用

按照教程搭建完成以后, 应该有如下端口:

| 服务                    | 地址                                                                                                     |
| ----------------------- | -------------------------------------------------------------------------------------------------------- |
| minio                   | api 请求 `minio-api.kentxxq.com`, ui 操作 `minio-ui.kentxxq.com`                                                          |
| loki                    | 接收 oc 发送的日志数据 `http_listen_port/3100`, `grpc_listen_port/3101`                                                         |
| mimir                   | 接收 oc 发送的指标数据 `http_listen_port/9009`, `grpc_listen_port/9010`                                                         |
| tempo                   | 接收 oc 发送的追踪数据 `http_listen_port/3200`, `distributor.receivers.otlp.http/3201`, `distributor.receivers.otlp.grpc/3202` |
| opentelemetry-collector | 接收应用数据 `grpc/4317`, `http/4318`                                                                                 |
| grafana-ui              | ui 操作 `ip:3000`                                                                                                |

配置好 `OC_Endpoint`, [启动APP程序](https://github.com/kentxxq/csharpDEMO/tree/main/Aspnetcore/AddOpentelemetry) 即可在 [[笔记/grafana-ui教程|grafana-ui]] 查询到数据.

- 日志数据: ![[附件/OC实践-loki查询日志.png]]
- 链路数据: ![[附件/OC实践-tempo链路展示.png]]
- 指标数据: ![[附件/OC实践-mimir指标数据.png]]

## 相关内容

- [opentelemetry-collector 的配置文档](https://opentelemetry.io/docs/collector/configuration/#receivers)
- [官方的OTLP Receiver](https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md) log 处于 beta 阶段.
- Java 通过 agent 方式注入即可 [opentelemetry-java-instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)

其他有用的信息

- [serilog-sinks-grafana-loki](https://github.com/serilog-contrib/serilog-sinks-grafana-loki) 可以直接发送日志到 loki ,http 接口的方式
- loki 无法接受 otlp 协议日志
    - [serilog-sinks-opentelemetry](https://github.com/serilog/serilog-sinks-opentelemetry) 通过 otlp 协议发送出去, 但是现在 loki 无法直接接收....
    - Grafana 的 agent, loki 无法支持 OTLP 收集日志 [Support receiving logs in Loki using OpenTelemetry OTLP · Issue #5346 · grafana/loki · GitHub](https://github.com/grafana/loki/issues/5346)
