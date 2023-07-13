---
title: prometheus教程
tags:
  - blog
  - prometheus
date: 2023-07-11
lastmod: 2023-07-11
categories:
  - blog
description: 
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
