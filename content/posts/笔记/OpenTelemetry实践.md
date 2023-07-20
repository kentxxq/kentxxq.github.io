---
title: OpenTelemetry实践
tags:
  - blog
  - OpenTelemetry
  - grafana
  - prometheus
  - csharp
date: 2023-07-20
lastmod: 2023-07-20
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
description: "[[笔记/point/OpenTelemetry|OpenTelemetry]] 实践会涉及到 [[笔记/point/csharp|csharp]] 应用的集成, [[笔记/grafana-ui教程|grafana-ui的展示]] + [[笔记/grafana-loki教程|grafana-loki日志处理]] + [[笔记/grafana-tempo教程|grafana-tempo链路追踪处理]] + [[笔记/prometheus教程|prometheus指标处理]] + [[笔记/minio教程|minio存储]] + [prometheus存储后端Mimir](https://grafana.com/oss/mimir/)."
---

## 简介

[[笔记/point/OpenTelemetry|OpenTelemetry]] 实践会涉及到 [[笔记/point/csharp|csharp]] 应用的集成, [[笔记/grafana-ui教程|grafana-ui的展示]] + [[笔记/grafana-loki教程|grafana-loki日志处理]] + [[笔记/grafana-tempo教程|grafana-tempo链路追踪处理]] + [[笔记/prometheus教程|prometheus指标处理]] + [[笔记/minio教程|minio存储]] + [prometheus存储后端Mimir](https://grafana.com/oss/mimir/).

## 内容

组件非常的多, 但是现在 `2023年7月20日20:32:49` 还不完善, 后续再更新.

不想通过普通的文本采集方式, 因为这样觉得很傻.

- [官方的OTLP Receiver](https://github.com/open-telemetry/opentelemetry-collector/blob/main/receiver/otlpreceiver/README.md) log 处于 beta 阶段.
- OpenTelemetry.Exporter.OpenTelemetryProtocol.Logs 现在 1.5.0-rc.1 才有日志 [[笔记/point/OpenTelemetry|OTLP]] exporter, 而 [1.6版本](https://github.com/open-telemetry/opentelemetry-dotnet/releases/tag/core-1.6.0-alpha.1) 开始会合并掉, 所以 api 不稳定.
- Grafana 的 agent, loki 无法支持 OTLP 收集日志 [Support receiving logs in Loki using OpenTelemetry OTLP · Issue #5346 · grafana/loki · GitHub](https://github.com/grafana/loki/issues/5346)

其他有用的信息

- [serilog-sinks-grafana-loki](https://github.com/serilog-contrib/serilog-sinks-grafana-loki) 可以直接发送日志到 loki ,http 接口的方式
- [serilog-sinks-opentelemetry](https://github.com/serilog/serilog-sinks-opentelemetry) 通过 otlp 协议发送出去, 但是现在 loki 无法直接接收....
- [Send logs to Loki with filelog receiver | OpenTelemetry documentation](https://grafana.com/docs/opentelemetry/collector/send-logs-to-loki/filelog-receiver/) opentelemetry-collector 收集到日志以后, 如何转发给 loki
- [Configuration | OpenTelemetry](https://opentelemetry.io/docs/collector/configuration/#receivers) opentelemetry-collector 的配置文档
