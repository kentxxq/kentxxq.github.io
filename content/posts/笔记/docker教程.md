---
title: docker教程
tags:
  - blog
  - docker
date: 2023-06-27
lastmod: 2023-08-06
categories:
  - blog
description: "这里记录 [[笔记/point/docker|docker]] 的所有配置和操作."
---

## 简介

这里记录 [[笔记/point/docker|docker]] 的所有配置和操作. 相关的概念可以通过 [[笔记/k8s组件#容器|容器]] 来了解.

## 安装/卸载 docker

```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
apt update -y
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
vim /etc/docker/daemon.json
systemctl daemon-reload
systemctl enable docker --now

apt remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

## 配置参数

 `/etc/docker/daemon.json`,参考 [镜像源](https://docs.docker.com/registry/recipes/mirror/#configure-the-docker-daemon) 和 [http代理](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy)

```json
{
  "registry-mirrors": ["https://1ocw3lst.mirror.aliyuncs.com"],
  "proxies": {
      "http-proxy": "http://proxy.example.com:3128",
      "https-proxy": "https://proxy.example.com:3129",
      "no-proxy": " localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.test.example.com"
    }
  }
}
```

[[笔记/point/Systemd|Systemd]] 配置 http/https 代理

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:3128"
Environment="HTTPS_PROXY=https://proxy.example.com:3129"
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
```

## 格式解析

### docker

```shell
# -d 后台运行,--restart=always 总是重启,
# -v /mydata/:/data/ 本地/mydata/挂载到容器/data/
# 暴露本地12端口,映射到容器34端口
# 默认启动,如果加上/bin/bash,就是进入bash命令
docker run -d --name testserver \
-v /mydata/:/data/ \
-e A=a \
-p 12:34 \
--restart=always \
kentxqq/testserver:1.2 \
/bin/bash

# -t指定名字myapp .代表Dockerfile在当前目录
docker build -t myapp .
```

### docker compose

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

## 操作命令

### 上传 docker 镜像

起因是国内经常因为网络问题, 无法正常拉取镜像. 需要手动把常用的镜像备份过来 (即使配置了代理源, 因为会请求 dockerhub 的接口, 这里也会导致失败).

这里记录一下 [[笔记/point/docker|docker]] 的镜像上传.

1. 在网络通常的情况下先拉取镜像

   ```shell
   docker pull maven:3.6.1-jdk-8
   ```

2. 给镜像打 `tag`

   ```shell
   docker tag maven:3.6.1-jdk-8 你的镜像仓库地址/命名空间/maven:3.6.1-jdk-8
   # 这里拿阿里云的镜像仓库举例
   # 镜像仓库命名为msb-images,下面是镜像仓库地址
   # msb-images-registry-vpc.cn-zhangjiakou.cr.aliyuncs.com 私网
   # msb-images-registry.cn-zhangjiakou.cr.aliyuncs.com 公网
   # public 为命名空间
   docker tag maven:3.6.1-jdk-8 msb-images-registry-vpc.cn-zhangjiakou.cr.aliyuncs.com/public/maven:3.6.1-jdk-8
   ```

3. 登录,推送镜像

   ```shell
   # 登录
   docker login --username=用户名 -p 密码 msb-images-registry.cn-zhangjiakou.cr.aliyuncs.com
   # 推送
   docker push msb-images-registry-vpc.cn-zhangjiakou.cr.aliyuncs.com/public/maven:3.6.1-jdk-8
   ```

### 文件拷贝

#### 从镜像拷贝文件到本地

```shell
id = $(docker create 镜像名)
docker cp $id:path - > 本地文件名
docker rm -v $id
```

[[笔记/point/powershell|powershell]] 版本:

```shell
$id = docker create 镜像名
docker cp "${id}:镜像内源文件路径" - | Set-Content 目标文件名
docker rm -v $id
```

### 操作 docker-compose

虽然在生产环境 [[笔记/point/docker-compose|docker-compose]] 很少用到, 但是在开发, 测试, [[笔记/point/poc|poc]] 的时候经常会用到.

> [[笔记/point/docker-compose|docker-compose]] 现在集成到了 [[笔记/point/docker|docker]] 里, 所以 `docker-compose` 和 `docker compose` 等效

```shell
# 只拉取镜像
docker-compose -f xxxx.yml pull
# -d表示后台启动 --build表示构建镜像
docker-compose up -d --build

# 停止
docker-compose down --remove-orphans
```
