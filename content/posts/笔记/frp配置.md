---
title: frp配置
tags:
  - blog
  - frp
date: 2023-08-16
lastmod: 2024-08-17
categories:
  - blog
description: "`frp` 是一个内网穿透工具.这里记录一下之前用过的配置."
---

## 简介

`frp` 是一个内网穿透工具, 同样的工具还有 [[笔记/point/ngrok|ngrok]], [Tunnelmole](https://tunnelmole.com/)

- [官方文档地址](https://gofrp.org/zh-cn/docs/examples/ssh/)

## 配置文件

#### 服务端 frps

配置 `frps.toml`

```toml
# 限制主机、监听端口
bindAddr = "0.0.0.0"
bindPort = 7000

# 密码
auth.token = "你的token"

# http的web端口
vhostHTTPPort = 20000
subdomainHost = "kentxxq.com"

# 日志路径
log.to = "console"
```

#### 客户端 frpc

客户端工具有

- [GitHub - koho/frpmgr: Windows 平台的 FRP GUI 客户端 / A user-friendly desktop GUI client for FRP on Windows.](https://github.com/koho/frpmgr)
- [GitHub - luckjiawei/frpc-desktop: 一个frpc桌面客户端](https://github.com/luckjiawei/frpc-desktop)

下面是 [frpmgr](https://github.com/koho/frpmgr) 的使用方法

如图配置基本信息, 认证 tab 栏配置 token 信息

![[附件/frps连接配置.png]]

然后配置 http 代理

![[附件/frps域名配置.png]]

#todo/笔记 `frpc.toml` 版本

#### 反向代理 nginx

代理页面:

```nginx
server {
    listen 443 ssl;
    server_name ~frp-.*;
    access_log /tmp/frp.kentxxq.com.log main;
    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;

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

## 运行

[[笔记/point/Systemd|systemd]] 守护起来, [官网也建议这么做](https://gofrp.org/zh-cn/docs/setup/systemd/)

`vim /etc/systemd/system/frps.service`

```ini
[Unit]
# 服务名称，可自定义
Description = frp server
After = network.target syslog.target
Wants = network.target

[Service]
Type = simple
# 启动frps的命令，需修改为您的frps的安装路径
ExecStart = /root/frp/frps -c /root/frp/frps.toml

[Install]
WantedBy = multi-user.target
```
