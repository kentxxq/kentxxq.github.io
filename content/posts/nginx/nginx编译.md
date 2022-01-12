---
title:  nginx编译
date: 2022-01-12 11:40:00+08:00
categories: ["笔记"]
tags: ["nginx"]
keywords: ["nginx","编译"]
description: "随着网络架构的日益复杂，开始全方面了解nginx的各种配置和功能，而很多功能没有默认编入nginx，所以nginx的编译就必不可少了"
---


> 随着网络架构的日益复杂，开始全方面了解nginx的各种配置和功能，而很多功能没有默认编入nginx，所以nginx的编译就必不可少了。


## 安装编译

```sh
# 下载
curl http://nginx.org/download/nginx-1.20.2.tar.gz
tar -zxvf nginx-1.20.2.tar.gz
cd nginx-1.20.2/
# 编译
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-stream --with-stream_realip_module
# 可加参数
# 指定用户名和组
# --user=nginx --group=nginx
```

## 配置tcp代理

切记是放到`nginx.conf内的根节点`，不是放到`http`下！！

```conf
# 监听10022端口，代理到10.0.0.2:222端口
stream {
    upstream GITLAB {
        hash   $remote_addr consistent;
        server 10.0.0.2:222;
    }

    server {
        listen  10022;
        proxy_connect_timeout   30s;
        proxy_timeout   300s;
        proxy_pass  GITLAB;
    }
}
```