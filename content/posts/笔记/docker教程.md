---
title: docker教程
tags:
  - blog
  - docker
date: 2023-06-27
lastmod: 2023-07-26
categories:
  - blog
description: "这里记录 [[笔记/point/docker|docker]] 的所有操作"
---

## 简介

这里记录 [[笔记/point/docker|docker]] 的所有操作

## 配置参数

 `/etc/docker/daemon.json`

```json
{
  "registry-mirrors": ["https://bwx6yb0u.mirror.aliyuncs.com"],
  "proxies": {
    "default": {
      "httpProxy": "http://proxy.example.com:3128",
      "httpsProxy": "https://proxy.example.com:3129",
      "noProxy": "NO_PROXY: localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.test.example.com"
    }
  }
}
```

## 上传 docker 镜像

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

## 文件拷贝

### 从镜像拷贝文件到本地

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

## 操作 docker-compose

虽然在生产环境 [[笔记/point/docker-compose|docker-compose]] 很少用到, 但是在开发, 测试, [[笔记/point/poc|poc]] 的时候经常会用到.

> [[笔记/point/docker-compose|docker-compose]] 现在集成到了 [[笔记/point/docker|docker]] 里, 所以 `docker-compose` 和 `docker compose` 等效

```shell
# 只拉取镜像
docker-compose pull
# -d表示后台启动 --build表示构建镜像
docker-compose up -d --build

# 停止
docker-compose down
```
