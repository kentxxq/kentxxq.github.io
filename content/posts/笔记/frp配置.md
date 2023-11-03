---
title: frp配置
tags:
  - blog
  - frp
date: 2023-08-16
lastmod: 2023-11-02
categories:
  - blog
description: "`frp` 是一个内网穿透工具.这里记录一下之前用过的配置."
---

## 简介

`frp` 是一个内网穿透工具.

这里记录一下之前用过的配置.

## 内容

#### 服务端 frps

```ini
[common]
# 限制主机、监听端口
bind_addr = 0.0.0.0
bind_port = 7000
# http的web访问端口
# https用vhost_https_port
vhost_http_port = 20000
# 验证
token = 验证密码

# web监控面板
dashboard_addr = 127.0.0.1
dashboard_port = 7001
dashboard_user = 用户名
dashboard_pwd = 验证密码

# 日志路径
log_file = console

# 一级域名
subdomain_host = kentxxq.com

[frp]
type = http
subdomain = frp-python5001
# 可以指定token
token = frp-python5
```

#### 客户端 frpc

```ini
[common]
server_addr = frp.kentxxq.com
server_port = 7000
token = 验证密码,对应服务端
log_file = console

[frp-python5000]
# 访问地址frp-python5000.kentxxq.com
type = http
local_port = 5000
subdomain = frp-python5000
```

#### 反向代理 nginx

代理页面:

```nginx
server {
    listen 443 ssl;
    server_name ~frp-.*;
    ssl_certificate /etc/nginx/ssl/kentxxq.cer;
    ssl_certificate_key /etc/nginx/ssl/kentxxq.key;
    access_log /tmp/frp.kentxxq.com.log main;

    location / {
        proxy_pass http://127.0.0.1:20000;
        proxy_set_header   Host $host;
    }
}

server {
        listen 80;
        server_name  frp.kentxxq.com;
        return 301 https://$server_name$request_uri;
}
```

监控页面:

```nginx
server {
    listen 443 ssl;
    server_name frps-static.kentxxq.com;
    ssl_certificate /etc/nginx/ssl/kentxxq.cer;
    ssl_certificate_key /etc/nginx/ssl/kentxxq.key;
    access_log /tmp/frps-static.kentxxq.com.log main;

    location / {
        proxy_pass http://127.0.0.1:7001;
    }
}

server {
        listen 80;
        server_name  frps-static.kentxxq.com;
        return 301 https://$server_name$request_uri;
}
```
