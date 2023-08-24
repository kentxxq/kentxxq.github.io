---
title: k8s常用命令和配置
tags:
  - blog
  - k8s
date: 2023-08-15
lastmod: 2023-08-23
categories:
  - blog
description: "记录 [[笔记/point/k8s|k8s]] 的常用命令和配置"
---

## 简介

记录 [[笔记/point/k8s|k8s]] 的常用命令

## 命令

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

## 配置

### 应用示例

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```
