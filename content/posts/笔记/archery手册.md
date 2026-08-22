---
title: archery手册
tags:
  - blog
date: 2025-05-23
lastmod: 2025-05-23
categories:
  - blog
description: 
---

## 简介

archery 是一个安全审计工具, 审计 mysql, redis, mongo 之类的数据产品

## 挂载 ssl

1. 按照教程部署 archery 的 docker 版本
2. 在 `archery` 创建 `nginx/nginx.conf` 文件
    - 修改原配置里的 `server_name` 为新域名
    - 注释 `proxy_set_header X-Forwarded-Host  $host:9123;`
    - 在 `docker-compose.yml` 的 `archery` 里挂载新的配置文件 `"./archery/nginx/nginx.conf:/etc/nginx/nginx.conf"`
3. 重建容器 `docker compose up -d --force-recreate`
