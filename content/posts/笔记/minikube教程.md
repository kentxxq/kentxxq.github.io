---
title: minikube教程
tags:
  - blog
  - minikube
date: 2023-08-17
lastmod: 2023-08-17
categories:
  - blog
description: "这里记录 [[笔记/point/minikube|minikube]] 的一些配置和用法."
---

## 简介

这里记录 [[笔记/point/minikube|minikube]] 的一些配置和用法.

## 内容

### 前置条件

- 安装好 [[笔记/point/kubectl|kubectl]]
- 安装好 [[笔记/docker教程#安装/卸载 docker|docker]]
- 一个良好的网络. 例如提前部署一个 [[笔记/clash配置|clash代理]]
- 内存, cpu, 磁盘宽裕一点

### 安装

[官方文档在这](https://minikube.sigs.k8s.io/docs/start/)

```shell
# 下载下来
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# 类似mv安装,但保留了权限
install minikube-linux-amd64 /usr/local/bin/minikube
```

`ingress-nginx` 安装

```shell
minikube addons enable ingress
```

### 使用

#### 启动

```shell
# 不限制cpu,默认是2 --cpus='max'
# 节点数量 --nodes 3
# 内存大小 --memory 4096
# root启动需要使用--force
# --docker-env 使用代理
minikube start --cpus='max' --nodes 3 --memory 4096 --force --docker-env HTTP_PROXY=${http_proxy} --docker-env HTTPS_PROXY=${https_proxy} --docker-env NO_PROXY=localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.test.example.com
```

#### 使用中

```
# 查看所有集群
minikube profile list
# 节点操作
minikube node add|start|stop|delete|list
```

#### 使用后

```
# 删除minikube集群, --all 删除所有集群
minikube delete 
```
