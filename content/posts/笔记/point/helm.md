---
title: helm
tags:
  - point
  - helm
date: 2023-07-08
lastmod: 2025-11-26
categories:
  - point
---

`helm` 是 [[笔记/point/k8s|k8s]] 用来将应用所需资源打包为一个整体的工具。可类比为 yum/centos ,apt/ubuntu.

### 优势

- **整体部署**: 例如后台 api 服务需要 deployment 对 pod 进行管理、同时需要 service 对外提供服务
- **统一管理**: 整个应用的所有关联资源统一升级/回滚
- **版本化**: 一些中间件的部署可以通过版本化来进行迭代
- **维护成本**: 通过少数几个通用的 helm 模板来打包。不需要开发者对每个代码仓库进行改动

