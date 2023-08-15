---
title: minio教程
tags:
  - blog
date: 2023-07-19
lastmod: 2023-08-15
categories:
  - blog
description: "[[笔记/point/minio|minio]] 的搭建和使用."
---

## 简介

[[笔记/point/minio|minio]] 的搭建和使用.

## 内容

### 安装

#### 单点单驱动

安装 `minio`

```shell
wget https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20230711212934.0.0_amd64.deb -O minio.deb
dpkg -i minio.deb
```

数据目录准备

```shell
# 数据目录
mkdir -p /data/minio-data
# 添加组和用户
groupadd -r minio-user
useradd -M -r -g minio-user minio-user
# 配置权限
chown minio-user:minio-user /data/minio-data
```

编辑配置文件 `/etc/default/minio`

```shell
# 用户名和密码
MINIO_ROOT_USER=myminioadmin
MINIO_ROOT_PASSWORD=minio-secret-key-change-me

# 数据存放位置
MINIO_VOLUMES="/data/minio-data"
# 如果通过nginx反向代理https,或者集群的时候,可以配置MINIO_SERVER_URL
# MINIO_SERVER_URL="http://minio.example.net:9000"
```

[[笔记/point/Systemd|Systemd]] 守护配置 `/etc/systemd/system/minio.service`

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

启动, 配置文件中默认 9000 端口

```shell
systemctl enable minio --now
```

### 基础使用

1. 浏览器打开登录 `ip:9000` 端口, 输入用户名和密码
2. 创建 `demo1` bucket
3. 创建 `ak`
