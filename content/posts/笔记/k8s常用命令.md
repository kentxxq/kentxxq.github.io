---
title: k8s常用命令
tags:
  - blog
  - k8s
date: 2023-08-15
lastmod: 2023-08-15
categories:
  - blog
description: "记录 [[笔记/point/k8s|k8s]] 的常用命令"
---

## 简介

记录 [[笔记/point/k8s|k8s]] 的常用命令

## 内容

### 查询信息

```shell
# 获取实时deployment信息
kubectl get --watch deployments

# 查询具体权限
kubectl describe ClusterRole tzedu:developer
```

### 清理残存容器

强制删除 pod, 其他资源同参数也可以删除.

```shell
kubectl delete pod pod名称 -n 命名空间 --force --grace-period=0
```
