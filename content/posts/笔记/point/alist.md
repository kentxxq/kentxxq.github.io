---
title: alist
tags:
  - point
  - 未命名
date: 2023-08-31
lastmod: 2023-08-31
categories:
  - point
---

[alist](https://github.com/alist-org/alist) 是一个支持多存储的网盘/WebDAV 工具.

## 运行

### 服务启动

[[笔记/point/docker-compose|docker-compose]] 配置

```yml
version: "3.3"
services:
  alist:
    restart: always
    volumes:
      - "/etc/alist:/opt/alist/data"
      - "/opt/alist/data/temp/aria2:/opt/alist/data/temp/aria2"
    ports:
      - "5244:5244"
    environment:
      - PUID=0
      - PGID=0
      - UMASK=022
    container_name: alist
    image: "xhofe/alist-aria2:latest"
```

### 反向代理

[[笔记/point/nginx|nginx]] 代理配置

```nginx
server {
    listen 80;
    server_name alist.kentxxq.com;
    return 301 https://$server_name$request_uri;

    include /usr/local/nginx/conf/options/normal.conf;
    access_log /usr/local/nginx/conf/hosts/logs/tmp.mashibing.cn.log k-json;
}

server {
    listen 443 ssl;
    server_name alist.kentxxq.com;
    client_max_body_size 204800M;

    ssl_certificate /usr/local/nginx/conf/ssl/a.pem;
    ssl_certificate_key /usr/local/nginx/conf/ssl/a.key;

    access_log /usr/local/nginx/conf/hosts/logs/tmp.mashibing.cn.log k-json;

    location / {
        proxy_pass http://10.0.1.157:5244;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Range $http_range;
	    proxy_set_header If-Range $http_if_range;
        proxy_redirect off;
    }
}
```
