---
title: watchtower
tags:
  - point
  - watchtower
date: 2023-08-24
lastmod: 2023-08-24
categories:
  - point
---

`watchtower` 是一个 [[笔记/point/docker|docker]] 容器过期, 自动更新的程序.

### 部署

```yml
version: "3"
services:
  watchtower:
    image: containrrr/watchtower
    environment:
      # 清理过期镜像
      WATCHTOWER_CLEANUP: true
      # 开启debug日志, WATCHTOWER_TRACE 日志会更多
      WATCHTOWER_DEBUG: true
      # 检测间隔时间, 86400/1天 3600/1小时
      WATCHTOWER_POLL_INTERVAL: 86400
      
      # token
      WATCHTOWER_HTTP_API_TOKEN: token
      # 抓取metrics,需要用到token
      WATCHTOWER_HTTP_API_METRICS: true
      
      # 远程主机
      # DOCKER_HOST: "tcp://10.0.1.2:2375"
      # 运行后退出, 可以用crontab一次行运行
      # WATCHTOWER_RUN_ONCE: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```
