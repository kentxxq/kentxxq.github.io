---
title: minio教程
tags:
  - blog
  - minio
date: 2023-07-19
lastmod: 2024-06-03
categories:
  - blog
description: "[[笔记/point/minio|minio]] 的搭建和使用."
---

## 简介

[[笔记/point/minio|minio]] 的搭建和使用.

## 安装

### 单机版

#### 前期准备

- 创建数据存放目录 `mkdir -p /data/minio`

#### 快速验证

[[笔记/point/docker|docker]] 版本:

```shell
# 数据存在容器/data目录
# 端口 api接口/9000 ui操作/9001
# 默认 minioadmin/minioadmin
docker run --rm -d \
 --name minio \
 -p 9000:9000 -p 9001:9001 \
 -e "MINIO_ACCESS_KEY=admin" -e "MINIO_SECRET_KEY=admin" \
 -v /data/minio/data:/data -v /data/minio/config:/root/.minio \
 minio/minio server /data --console-address ":9001"
```

或者二进制版本:

```shell
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
MINIO_ROOT_USER=admin MINIO_ROOT_PASSWORD=password ./minio server /data/minio --console-address ":9001"
```

> [!info]
> [官方快速验证文档地址](https://min.io/download)

#### 守护进程

创建配置文件 `vim minio.conf`

```
# 用户名和密码,集群之间是通过这个来校验的
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=密码
# api/9001 console-ui/9091
MINIO_OPTS="--address :9000 --console-address :9001"
MINIO_DATA_PATH=/data/minio
```

守护进程 `/etc/systemd/system/minio.service`

```toml
[Unit]
Description=minio
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3


[Service]
# 环境变量 $MY_ENV1
# Environment=MY_ENV1=value1
# Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
# EnvironmentFile=/path/to/environment/file1

EnvironmentFile=/root/om/minio/minio.conf

WorkingDirectory=/root/om/minio
ExecStart=/root/om/minio/minio server $MINIO_DATA_PATH $MINIO_OPTS
# 总是间隔30s重启,配合StartLimitIntervalSec实现无限重启
RestartSec=30s 
Restart=always
# 相关资源都发送term后,后发送kill
KillMode=mixed
# 最大文件打开数不限制
LimitNOFILE=infinity
# 子线程数量不限制
TasksMax=infinity


[Install]
WantedBy=multi-user.target
```

### 集群部署

#### 二进制安装

我有 2 个机器。给每个节点加上一个 DNS 解析记录, 最好有统一的名称:

```shell
minio1.kentxxq.com
minio2.kentxxq.com
```

除了系统盘外，每个节点还有 2 个空的数据盘 (必须)。[[笔记/linux命令与配置#挂载磁盘|把数据盘挂载到系统]] 的 `/mnt/minio{1,2}` 目录

用户和目录准备:

```shell
groupadd -r minio-user
useradd -M -r -g minio-user minio-user
# 模拟2个硬盘,2个节点
chown minio-user:minio-user /mnt/minio{1,2}
```

安装 `minio`, [官网安装页面](https://min.io/download#/linux)

```shell
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
mv minio /usr/local/bin/
```

环境配置文件 `/etc/default/minio`

```shell
# 用户名和密码,集群之间是通过这个来校验的
MINIO_ROOT_USER=myminioadmin
MINIO_ROOT_PASSWORD=minio-secret-key-change-me
# api/9001 console-ui/9091
MINIO_OPTS="--address :9001 --console-address :9091"

# 2个节点互相发现,2个磁盘(除开系统盘)
MINIO_VOLUMES="http://minio{1...2}.kentxxq.com:9000/mnt/minio{1...2}"
# 或者空格间隔
# MINIO_VOLUMES="http://minio1.kentxxq.com:9001/mnt/vdb1 http://minio2.kentxxq.com:9002/mnt/vdc1 http://minio3.kentxxq.com:9003/mnt/vdd1 http://minio4.kentxxq.com:9004/mnt/vde1"

# 请求地址
MINIO_SERVER_URL="https://minio-api.kentxxq.com"
MINIO_BROWSER_REDIRECT_URL="https://minio-ui.kentxxq.com"
```

#### 守护进程

[官方推荐](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-multi-drive.html#id5) 的 [[笔记/point/Systemd|Systemd]] 守护配置存在位置 `/etc/systemd/system/minio.service`

```toml
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
WorkingDirectory=/usr/local

User=minio-user
Group=minio-user
ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemctl setups where other services use `After=minio.server`
# Uncomment the line to enable the functionality
# Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target

# Built for ${project.name}-${project.version} (${project.name})
```

启动

```shell
systemctl enable minio --now
```

#### nginx 代理配置

```nginx
upstream minio_s3 {
    least_conn;
    server 10.0.1.152:9001;
    server 10.0.1.152:9002;
    server 10.0.1.152:9003;
    server 10.0.1.152:9004;
}

upstream minio_console {
    least_conn;
    server 10.0.1.152:9091;
    server 10.0.1.152:9092;
    server 10.0.1.152:9093;
    server 10.0.1.152:9094;
}

server {
    listen 80;
    server_name minio-api.kentxxq.com;
    return 301 https://$server_name$request_uri;
    include /usr/local/nginx/conf/options/normal.conf;
    access_log /usr/local/nginx/conf/hosts/logs/minio-api.kentxxq.com.log k-json;
}

server {
    http2 on;
    listen 443 ssl;
    server_name minio-api.kentxxq.com;
    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;
    access_log /usr/local/nginx/conf/hosts/logs/minio-api.kentxxq.com.log k-json;
    # Allow special characters in headers
    ignore_invalid_headers off;
    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;
    # Disable buffering
    proxy_buffering off;
    proxy_request_buffering off;
    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 300;
        # Default is HTTP/1, keepalive is only enabled in HTTP/1.1
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        chunked_transfer_encoding off;
        proxy_pass http://minio_s3;
    }
}

# ui
server {
    listen 80;
    server_name minio-ui.kentxxq.com;
    return 301 https://$server_name$request_uri;
    include /usr/local/nginx/conf/options/normal.conf;
    access_log /usr/local/nginx/conf/hosts/logs/minio-ui.kentxxq.com.log k-json;
}

server {
    http2 on;
    listen 443 ssl;
    server_name minio-ui.kentxxq.com;

    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;
    access_log /usr/local/nginx/conf/hosts/logs/minio-ui.kentxxq.com.log k-json;

    # Allow special characters in headers
    ignore_invalid_headers off;
    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;
    # Disable buffering
    proxy_buffering off;
    proxy_request_buffering off;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-NginX-Proxy true;
        # This is necessary to pass the correct IP to be hashed
        #real_ip_header X-Real-IP;
        proxy_connect_timeout 300;
        # To support websocket
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        chunked_transfer_encoding off;
        proxy_pass http://minio_console/;
    }
}
```

## 使用

1. 浏览器打开登录 `minio-ui.kentxxq.com` 端口, 输入用户名和密码
2. 查看集群信息 ![[附件/minio集群信息.png]]
3. 边栏 `bucket` 创建 `demo1`![[附件/minio桶bucket.png]]
4. 边栏 `access keys` 创建 `ak` ![[附件/minio秘钥ak.png]]


> [!info]
> 默认地域 `us-east-1`
