---
title: 上传docker镜像
tags:
  - blog
  - docker
date: 2023-06-27
lastmod: 2023-06-30
categories:
  - blog
description: "起因是国内经常因为网络问题, 无法正常拉取镜像. 需要手动把常用的镜像备份过来 (即使配置了代理源, 因为会请求 dockerhub 的接口, 这里也会导致失败).这里记录一下 [[笔记/point/docker|docker]] 的镜像上传."
---

## 简介

起因是国内经常因为网络问题, 无法正常拉取镜像. 需要手动把常用的镜像备份过来 (即使配置了代理源, 因为会请求 dockerhub 的接口, 这里也会导致失败).

这里记录一下 [[笔记/point/docker|docker]] 的镜像上传.

## 操作手册

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
