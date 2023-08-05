---
title: grafana-loki教程
tags:
  - blog
  - promtail
  - loki
  - grafana
date: 2023-07-17
lastmod: 2023-08-02
categories:
  - blog
description: "grafana-loki 是 [[笔记/point/grafana|grafana]] 公司的日志采集组件"
---

## 简介

`grafana-loki` 是 [[笔记/point/grafana|grafana]] 公司的日志采集组件

## 内容

### 安装

1. 下载 Loki 和 Promtail 的 zip 压缩文件 [Releases · grafana/loki](https://github.com/grafana/loki/releases/)
2. 下载配置文件

    ```shell
    wget https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-local-config.yaml

    wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml
    ```

3. 启动

    ```shell
    # windows
    .\loki-windows-amd64.exe --config.file=loki-local-config.yaml
    # linux
    ./loki-linux-amd64 -config.file=loki-local-config.yaml
    ```

4. 守护进程 [[笔记/point/supervisor|supervisor]]

    ```toml
    [program:promtail]
    directory = /root
    command = /root/promtail-linux-amd64 -config.file=promtail-local-config.yaml
    
    # 自动重启
    autorestart = true
    # 启动失败的尝试次数
    startretries = 3
    # 进程20s没有退出，则判断启动成功
    startsecs = 20
    # 标准输出的文件路径
    stdout_logfile = /tmp/promtail-supervisor.log
    # 日志文件最大大小
    stdout_logfile_maxbytes=20MB
    # 日志文件保持数量 默认为10 设置为0 表示不限制
    stdout_logfile_backups = 5
    # 标准输出的文件路径
    stderr_logfile = /tmp/promtail-supervisor.log
    # 日志文件最大大小
    stderr_logfile_maxbytes=20MB
    # 日志文件保持数量 默认为10 设置为0 表示不限制
    stderr_logfile_backups = 5



    [program:loki]
    directory = /root
    command = /root/loki-linux-amd64 -config.file=loki-local-config.yaml
    
    # 自动重启
    autorestart = true
    # 启动失败的尝试次数
    startretries = 3
    # 进程20s没有退出，则判断启动成功
    startsecs = 20
    # 标准输出的文件路径
    stdout_logfile = /tmp/loki-supervisor.log
    # 日志文件最大大小
    stdout_logfile_maxbytes=20MB
    # 日志文件保持数量 默认为10 设置为0 表示不限制
    stdout_logfile_backups = 5
    # 标准输出的文件路径
    stderr_logfile = /tmp/loki-supervisor.log
    # 日志文件最大大小
    stderr_logfile_maxbytes=20MB
    # 日志文件保持数量 默认为10 设置为0 表示不限制
    stderr_logfile_backups = 5
    ```

### 查询日志 LogQL

#### 常用语法

```shell
# 查询标签
{filename="/var/log/syslog"}
=相等 !=不相等 =~正则匹配 !~正则不匹配

# 标签+包含字符
{filename="/var/log/syslog"}|= "Day"
|=包含 !=不包含 |~正则匹配 !~正则不匹配

# 向量和运算符
# 最近5分钟的日志记录数
count_over_time({filename="/var/log/syslog"}[$__range])
```

#### 日志分割

官网有几个日志分析的示例放在 [LogQL Analyzer | Grafana Loki documentation](https://grafana.com/docs/loki/latest/logql/analyzer/),下面写一个日常会遇到的.

如果有多行日志, 可以在采集的时候配置 [multiline | Grafana Loki documentation](https://grafana.com/docs/loki/latest/clients/promtail/stages/multiline/)

```shell
# 日志格式
level=info|ts=2022-03-23T11:55:29.846163306Z|caller=main.go:112|msg="Starting|Grafana|Enterprise|Logs"
level=debug|ts=2022-03-23T11:55:29.846226372Z|caller=main.go:113|version=v1.3.0|branch=HEAD|Revision=e071a811|LokiVersion=v2.4.2|LokiRevision=525040a3
level=warn|ts=2022-03-23T11:55:45.213901602Z|caller=added_modules.go:198|msg="found|valid|license"|cluster=enterprise-logs-test-fixture
level=info|ts=2022-03-23T11:55:45.214611239Z|caller=server.go:269|http=[::]:3100|grpc=[::]:9095|msg="server|listening|on|addresses"
level=debug|ts=2022-03-23T11:55:45.219665469Z|caller=module_service.go:64|msg=initialising|module=license
level=warm|ts=2022-03-23T11:55:45.219678992Z|caller=module_service.go:64|msg=initialising|module=server
level=error|ts=2022-03-23T11:55:45.221140583Z|caller=manager.go:132|msg="license|manager|up|and|running"
level=info|ts=2022-03-23T11:55:45.221254326Z|caller=loki.go:355|msg="Loki|started"

# 查询语句
{job="analyze"} | pattern "<level>|<time>|<caller>|<msg>"  | level="level=info"
```
