---
title:  k8s的疑难杂症
date:   2021-05-16 11:38:00 +0800
categories: ["笔记"]
tags: ["k8s"]
keywords: ["k8s"]
description: "k8s的疑难杂症，把日常遇到的k8s报错都总结一下"
---

## 介绍

主要是遇到的很多问题即使是英文文档，也很少有答案可以拿来用。所以把日常遇到的k8s报错都总结一下。

## 疑难杂症

### endpoints default-http-backend not found
```yaml
❯ kubectl.exe describe ingress
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
Name:             my-ingress-for-nginx
Namespace:        default
Address:          localhost
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host          Path  Backends
  ----          ----  --------
  a.kentxxq.cn
                /   nginx-service:80 (10.1.1.16:80,10.1.1.17:80)
```

原因: 主要是我们看的博客、视频、文档都比较老。如果看的是最新的官方文档，其实不会有这个问题。主要是因为k8s的版本变化，检测yml文件中的字段有了变化。

解决: 
```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: my-ingress-for-nginx  # Ingress 的名字，仅用于标识
spec:
  # begin 设置一个的默认backend即可
  backend:  
    serviceName: nginx-service
    servicePort: 80
  # end
  rules:                      
  - host: a.kentxxq.cn   
    http:
      paths:                 
      - path: /
        backend:
          serviceName: nginx-service  
          servicePort: 80
```

### websocket长连接的问题

原因：部分原因，前端和后端之间的连接采用的是长连接。而在容器销毁和扩容的过程中就会断开连接，造成无法保持长连接的问题。

解决: 后端每次容器销毁前，让Header部分返回`Connection:close`,通知客户端处理完当前的请求后关闭连接，新的请求需要重新建立TCP连接。[腾讯云容器团队的参考链接](https://tencentcloudcontainerteam.github.io/2019/06/06/scale-keepalive-service/)

## 更新记录

**20210516**: 开篇