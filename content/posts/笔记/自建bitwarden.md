---
title: 自建bitwarden
tags:
  - blog
  - bitwarden
date: 2023-07-31
lastmod: 2024-05-06
categories:
  - blog
description: 
---

## 简介

这里是自建 [[笔记/point/bitwarden|bitwarden]] 的配置和记录.

为什么要自建?

- 完全免费, 不怕跑路
- 上传附件需要收费, 例如 ssh-key
- 自己使用 api 完成一些功能? 公共的可能有限制

> 我使用的是 [vaultwarden](https://github.com/dani-garcia/vaultwarden), 这是服务端的 rust 版本, 更加省内存.

## 内容

### 启动配置

| 命令                      | 说明             |
| ------------------------- | ---------------- |
| SIGNUPS_ALLOWED=false  | 禁止注册         |
| WEBSOCKET_ENABLED=true | 启动 websocket   |
| ADMIN_TOKEN=123444     | 启动 amdmin 界面 |

初次启动进行初始化, 随后关闭 `SIGNUPS_ALLOWED` 和 `ADMIN_TOKEN`.

```yml
# docker-compose.yml
version: "3"
services:
  server:
    container_name: bitwarden
    volumes:
      - "/data/bitwarden/:/data/"
    environment:
      - SIGNUPS_ALLOWED=true # false
      - WEBSOCKET_ENABLED=true
      - ADMIN_TOKEN=你的admin密码 # 注释这一行
    ports:
      - "6000:80"
      - "3012:3012"
    restart: always
    image: "vaultwarden/server:1.30.5"
# 启动
# docker compose up -d
```

### 反向代理

下面是 [[笔记/point/nginx|nginx]] 的代理配置

```nginx
upstream vaultwarden-default {
  zone vaultwarden-default 64k;
  server 127.0.0.1:6000;
  keepalive 2;
}

server {
    http2 on;
    listen 443 ssl;
    server_name bit.kentxxq.com;
    ssl_certificate /etc/nginx/ssl/kentxxq.cer;
    ssl_certificate_key /etc/nginx/ssl/kentxxq.key;

    client_max_body_size 128M;

    location / {
      proxy_http_version 1.1;
      proxy_set_header "Connection" "";

      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      proxy_pass http://vaultwarden-default;
    }
}

server {
        listen 80;
        server_name  bit.kentxxq.com;
        return 301 https://$server_name$request_uri;
}
```
