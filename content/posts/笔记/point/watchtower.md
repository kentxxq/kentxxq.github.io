---
title: watchtower
tags:
  - point
  - watchtower
date: 2023-08-24
lastmod: 2024-11-01
categories:
  - point
---

[watchtower](https://github.com/containrrr/watchtower) 是一个 [[笔记/point/docker|docker]] 容器过期, 自动更新的程序.

### 部署

```yml
version: "3"
services:
  watchtower:
    image: containrrr/watchtower
    environment:
      # 清理过期镜像 --cleanup
      WATCHTOWER_CLEANUP: true
      # 开启debug日志 --debug, WATCHTOWER_TRACE 日志会更多
      WATCHTOWER_DEBUG: true
      # 检测间隔时间 --interval, 86400/1天 3600/1小时
      WATCHTOWER_POLL_INTERVAL: 3600
      
      # token
      # WATCHTOWER_HTTP_API_TOKEN: token
      # 抓取metrics,需要用到token
      # WATCHTOWER_HTTP_API_METRICS: true
      
      # 远程主机
      # DOCKER_HOST: "tcp://10.0.1.2:2375"
      # 运行后退出, 可以用crontab一次行运行 --run-once
      # WATCHTOWER_RUN_ONCE: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

[[笔记/linux命令与配置#定时任务 crontab|定时任务crontab]] 使用

```shell
6 6 * * * root /usr/bin/docker run --rm --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --run-once [特定容器,不填则全部容器]
```
