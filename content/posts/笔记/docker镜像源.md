---
title: docker镜像源
tags:
  - blog
  - k8s
  - docker
date: 2023-08-18
lastmod: 2023-08-21
keywords:
  - k8s
  - docker
  - containerd
  - 容器
  - 镜像源
  - mirror
  - registery
  - 代理
categories:
  - blog
description: 
---

## 简介

为什么会有这篇文章, 是因为我总是会遇到 [[笔记/point/docker|docker]], [[笔记/point/Containerd|Containerd]], [[笔记/point/k8s|k8s]], [[笔记/point/minikube|minikube]] 等等网络问题.

统一在这里进行测试解决, 并且做成可用的方案. 工作和学习中无限使用!

## 内容

### 搭建 registry

```yml
registry-demo:
  restart: always
  image: registry:2
  ports:
    - 5000:5000
  volumes:
    - /data/registry:/var/lib/registry
```

#todo/笔记 !!!!!!

- 搭建多个站点的 registry
- Registery 全部走 [[笔记/point/clash|clash]] 代理! 因为域名确认, 所以这里的 url 是能够确认的!
- Nginx 域名代理
- Containerd, k 8 s, docker, minikube 统一都走 nginx 不同域名.

可以参考, 做个 k 3 d 的教程?! [k8s 代理问题一站式解决 - 知乎](https://zhuanlan.zhihu.com/p/545327043)

## 公共镜像源

| 提供者      | 地址                                       |
| ----------- | ------------------------------------------ |
| 网易云      | `https://hub-mirror.c.163.com`             |
| dockerproxy | `https://dockerproxy.com`                  |
| 百度云      | `https://mirror.baidubce.com`             |
| 上海交大    | `https://docker.mirrors.sjtug.sjtu.edu.cn` |
| 南京大学    | `https://docker.nju.edu.cn`                |

> 不要使用阿里云镜像源, 因为数据不同步!

参考链接: [国内的 Docker Hub 镜像加速器，由国内教育机构与各大云服务商提供的镜像加速服务 | Dockerized 实践 https://github.com/y0ngb1n/dockerized · GitHub](https://gist.github.com/y0ngb1n/7e8f16af3242c7815e7ca2f0833d3ea6)
