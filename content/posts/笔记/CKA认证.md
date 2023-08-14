---
title: CKA认证
tags:
  - blog
  - k8s
date: 2023-08-14
lastmod: 2023-08-14
categories:
  - blog
description: "CKA 是 [[笔记/point/k8s|k8s]] 的一个管理员认证, 我也弄了一个证书 [[附件/CKA证书.pdf|CKA证书]]"
---

## 简介

CKA 是 [[笔记/point/k8s|k8s]] 的一个管理员认证, 我也弄了一个证书 [[附件/CKA证书.pdf|CKA证书]].

## 内容

### 考试题

#### 扩容

将名为 my-nginx 的 deployment 的数量，扩展至 10 个 pods

```shell
kubectl scale deployment my-nginx --replicas=10
```

#### 多容器

创建一个 mul-container 的 Pod 对象

- nginx 容器用 nginx 镜像
- redis 容器用 redis 镜像
- tomcat 容器用 tomcat 镜像
- mysql 容器用 mysql 镜像

```yml
apiVersion: v1
kind: Pod
metadata:
  name: kucc4
spec:
  containers:
    - name: nginx
      image: nginx
    - name: redis
      image: redis
    - name: tomcat
      image: tomcat
    - name: mysql
      image: mysql
```

## 相关链接

### 查看已有的证书

1. [登录The Linux Foundation](https://sso.linuxfoundation.org/login)
2. [进入My Portal](https://trainingportal.linuxfoundation.org/learn/dashboard/)
3. 查看对应证书的分数, 下载证书
