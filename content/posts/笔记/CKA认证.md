---
title: CKA认证
tags:
  - blog
  - k8s
date: 2023-08-14
lastmod: 2023-08-18
categories:
  - blog
description: "CKA 是 [[笔记/point/k8s|k8s]] 的一个管理员认证, 我也弄了一个证书 [[附件/CKA证书.pdf|CKA证书]]"
---

## 简介

CKA 是 [[笔记/point/k8s|k8s]] 的一个管理员认证, 我也弄了一个证书 [[附件/CKA证书.pdf|CKA证书]].

## 内容

### 考试题

#### 扩容

将名为 my-nginx 的 deployment 的数量，扩展至 10 个 pods.

环境准备:

```shell
kubectl create deployment my-nginx --image=nginx
```

答题:

```shell
kubectl scale deployment my-nginx --replicas=10
```

#### 多容器

创建一个多容器的 Pod 对象

- nginx 容器用 nginx 镜像
- redis 容器用 redis 镜像
- tomcat 容器用 tomcat 镜像
- mysql 容器用 mysql

答题:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: multi
spec:
  containers:
    - name: nginx
      image: nginx
    - name: redis
      image: redis
    - name: tomcat
      image: tomcat
    - name: mysql
      image: mysql:5.7
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: "mima"
```

#### Ingress 转发

创建一个名为 my-ingress 的 ingress:

- 该 ingress 位于 app-team 的命名空间中
- 名称为 django 的 svc，提供 8000 端口服务
- ingress 提供一个 /django 的 url 入口，用于访问 django 的 svc

环境准备:

```shell
# 创建命名空间
kubectl create ns app-team
# 创建一个应用,方便svc对接
kubectl create deployment django-deployment --image=nginx -n app-team
```

答题:

```yml
apiVersion: v1
kind: Service
metadata:
  name: django
  namespace: app-team
spec:
  selector:
    app: django-deployment
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: django-ingress
  namespace: app-team
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: "django-ingress.kentxxq.com"
    http:
      paths:
      - path: /django
        pathType: Prefix
        backend:
          service:
            name: django
            port:
              number: 8000
```

## 相关链接

### 查看已有的证书

1. [登录The Linux Foundation](https://sso.linuxfoundation.org/login)
2. [进入My Portal](https://trainingportal.linuxfoundation.org/learn/dashboard/)
3. 查看对应证书的分数, 下载证书
