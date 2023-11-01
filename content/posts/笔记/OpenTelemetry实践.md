---
title: OpenTelemetry实践
tags:
  - blog
  - OpenTelemetry
  - grafana
  - prometheus
  - csharp
date: 2023-07-20
lastmod: 2023-10-27
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

## 原内容

组件非常的多, 但是现在 `2023年7月20日20:32:49` 还不完善, 后续再更新.

不想通过普通的文本采集方式, 因为这样觉得很傻.

- [官方的OTLP Receiver](https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md) log 处于 beta 阶段.
- ~~OpenTelemetry.Exporter.OpenTelemetryProtocol.Logs 现在 1.5.0-rc.1 才有日志 [[笔记/point/OTLP|OTLP]] exporter, 而 [1.6版本](https://github.com/open-telemetry/opentelemetry-dotnet/releases/tag/core-1.6.0-alpha.1) 开始会合并掉, 所以 api 不稳定.~~
- Grafana 的 agent, loki 无法支持 OTLP 收集日志 [Support receiving logs in Loki using OpenTelemetry OTLP · Issue #5346 · grafana/loki · GitHub](https://github.com/grafana/loki/issues/5346)

其他有用的信息

- [serilog-sinks-grafana-loki](https://github.com/serilog-contrib/serilog-sinks-grafana-loki) 可以直接发送日志到 loki ,http 接口的方式
- [serilog-sinks-opentelemetry](https://github.com/serilog/serilog-sinks-opentelemetry) 通过 otlp 协议发送出去, 但是现在 loki 无法直接接收....
- [Send logs to Loki with filelog receiver | OpenTelemetry documentation](https://grafana.com/docs/opentelemetry/collector/send-logs-to-loki/filelog-receiver/) opentelemetry-collector 收集到日志以后, 如何转发给 loki
- [Configuration | OpenTelemetry](https://opentelemetry.io/docs/collector/configuration/#receivers) opentelemetry-collector 的配置文档

## 相关内容

- Java 通过 agent 方式注入即可 [opentelemetry-java-instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)
