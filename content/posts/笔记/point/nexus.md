---
title: nexus
tags:
  - point
  - nexus
date: 2023-08-18
lastmod: 2025-11-26
categories:
  - point
---

`nexus` 是一个包仓库管理工具. 可以存储 [[笔记/point/java|java]], [[笔记/point/csharp|csharp]], [[笔记/point/docker|docker]] 等等包.

要点:

- 免费易用
- 用户量大
- 主流支持

## 安装

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

## 配置使用

### 配置代理

可以通过设置一个代理, 这样就可以分流直接拉取国内无法访问的内容. [HTTP Request and Proxy Settings](https://help.sonatype.com/en/http-request-and-proxy-settings.html)

### 替换镜像里的配置文件

```sh
sh "sed -i '/<mirrors>/a <mirror><id>nexus-server</id><mirrorOf>*</mirrorOf><name>nexus</name><url>https://1111111111111.com/repository/maven-public/</url><serverId>nexus-server</serverId></mirror>' /usr/share/maven/conf/settings.xml"
sh "sed -i '/<servers>/a <server><id>nexus-server</id><username>1111111111111</username><password>1111111111111</password></server>' /usr/share/maven/conf/settings.xml"
```

### 资源清理

```shell
#!/bin/bash
#清理nexus镜像
#Edit by xiayu@2021.5.12

#定义保留的tag数量
KEEP_TAG() {
  for PROJECT in `/usr/local/bin/nexus-cli image ls|grep $ENV`
    do
      /usr/local/bin/nexus-cli image delete --name $PROJECT --keep $1
    done
}

#定义保留的tag数量
REMOVE_ITSM() {
  for PROJECT in `/usr/local/bin/nexus-cli image ls|grep prd\/itsm-`
    do
      /usr/local/bin/nexus-cli image delete --name $PROJECT --tag latest
    done
}

#根据环境清理镜像
for ENV in dev prd pre test vs enfly
  do
    #替换配置文件中的仓库参数
    #sed -i '5d' /usr/local/bin/.credentials && echo "nexus_repository = \"$ENV\"" >> /usr/local/bin/.credentials
    
    if [ $ENV == prd ] || [ $ENV == dsx ] || [ $ENV == vs ] || [ $ENV == enfly ]
    then
    #生产环境保留5个
    KEEP_TAG 5
    #REMOVE_ITSM
    elif [ $ENV == pre ]
    then
    #准生产环境保留3个
    KEEP_TAG 3
    elif [ $ENV == test ]
    then
    #测试环境保留2个  
    KEEP_TAG 1
    REMOVE_ITSM
    else
    #开发保留一个
    KEEP_TAG 1
    fi
  done
```

### 权限

1. 禁用匿名访问。security => anonymous access => 取消勾选
2. docker 仓库配置独立 http 端口，外层 nginx 配置域名和 ssl
3. npm，pypi，maven 都可以创建 groups，包含国内源和自己仓库的，顺序拉取
