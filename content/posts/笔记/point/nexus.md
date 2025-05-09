---
title: nexus
tags:
  - point
  - nexus
date: 2023-08-18
lastmod: 2025-03-21
categories:
  - point
---

`nexus` 是一个包仓库管理工具. 可以存储 [[笔记/point/java|java]], [[笔记/point/csharp|csharp]], [[笔记/point/docker|docker]] 等等包.

要点:

- 免费易用
- 用户量大
- 主流支持

### 安装

[[笔记/point/docker|docker]] 启动

```shell
docker run -d --restart=always -p 8081:8081 --name nexus -v /data/nexus:/nexus-data sonatype/nexus3
```

[[笔记/point/nginx|nginx]] 配置

```nginx
server {
    listen 80;
    server_name nexus.kentxxq.com;
    return 301 https://$server_name$request_uri;
    include /usr/local/nginx/conf/options/normal.conf;
    access_log /usr/local/nginx/conf/hosts/logs/nexus.kentxxq.com k-json;
}

server {
    listen 443 ssl;
    server_name nexus.kentxxq.com;

    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;
    access_log /usr/local/nginx/conf/hosts/logs/nexus.kentxxq.com k-json;

    client_max_body_size 800M;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto "https";
        proxy_pass http://10.0.1.156:8081;
    }
}
```

### 配置

可以通过设置一个代理, 这样就可以分流直接拉取国内无法访问的内容. [HTTP and HTTPS Request and Proxy Settings](https://help.sonatype.com/repomanager3/nexus-repository-administration/http-and-https-request-and-proxy-settings)

### 替换镜像里的配置文件

```sh
sh "sed -i '/<mirrors>/a <mirror><id>nexus-server</id><mirrorOf>*</mirrorOf><name>nexus</name><url>https://1111111111111.com/repository/maven-public/</url><serverId>nexus-server</serverId></mirror>' /usr/share/maven/conf/settings.xml"
sh "sed -i '/<servers>/a <server><id>nexus-server</id><username>1111111111111</username><password>1111111111111</password></server>' /usr/share/maven/conf/settings.xml"
```
