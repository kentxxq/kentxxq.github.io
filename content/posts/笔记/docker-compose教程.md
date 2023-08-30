---
title: docker-compose教程
tags:
  - blog
  - docker
date: 2023-08-29
lastmod: 2023-08-29
categories:
  - blog
description: "[[笔记/point/docker|docker]] 的 `docker-compose`.独立于 [[笔记/docker教程|docker教程]], 方便查找和使用."
---

## 简介

[[笔记/point/docker|docker]] 的 `docker-compose`.独立于 [[笔记/docker教程|docker教程]], 方便查找和使用.

## 配置解析

```yml
version: "3"

services:
  container_name: web
  # 构建相关
  build:
    context: web-directory
    dockerfile: web-directory/Dockerfile
  # 依赖与db服务
  depends_on:
    - db
  web:
    image: kentxxq/web:1
    restart: always
    env_file:
      # 文件内容类似 CORECLR_ENABLE_PROFILING="1"
      - xxx.env
    environment:
      A: a
    volumes:
      # 盘挂载
      - ./data:/var/lib/gitea
      # 只读挂载
      - /etc/localtime:/etc/localtime:ro
    ports:
      # web端口
      - "3000:3000"
  db:
    image: ...
    ...
```

## 操作 docker-compose

虽然在生产环境 [[笔记/point/docker-compose|docker-compose]] 很少用到, 但是在开发, 测试, [[笔记/point/poc|poc]] 的时候经常会用到.

> [[笔记/point/docker-compose|docker-compose]] 现在集成到了 [[笔记/point/docker|docker]] 里, 所以 `docker-compose` 和 `docker compose` 等效

```shell
# 只拉取镜像
docker compose -f xxxx.yml pull
# -d表示后台启动 --build表示构建镜像
docker compose up -d --build
# 停止
docker compose down --remove-orphans

# 重建容器
docker compose up -d --force-recreate
```
