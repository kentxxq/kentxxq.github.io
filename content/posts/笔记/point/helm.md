---
title: helm
tags:
  - point
  - helm
date: 2023-07-08
lastmod: 2023-12-01
categories:
  - point
---

`helm` 是 [[笔记/point/k8s|k8s]] 用来将应用所需资源打包为一个整体的工具。可类比为 yum/centos ,apt/ubuntu.

### 优势

- **整体部署**: 例如后台 api 服务需要 deployment 对 pod 进行管理、同时需要 service 对外提供服务
- **统一管理**: 整个应用的所有关联资源统一升级/回滚
- **版本化**: 一些中间件的部署可以通过版本化来进行迭代
- **维护成本**: 通过少数几个通用的 helm 模板来打包。不需要开发者对每个代码仓库进行改动

### 基础概念

- repo 是一个仓库，有一些别人写好的。你自己的代码打包以后也可以上传到私有仓库
- charts 是一个应用所需资源的概括
- release 是一个 charts 发布到 k8s 后的实例

### 安装

1. [Releases · helm/helm](https://github.com/helm/helm/releases)
2. `tar xf xxx.tar.gz`
3. `mv helm /usr/local/sbin/helm`

### 基础操作

| 说明                     | 操作                                                         |
| ------------------------ | ------------------------------------------------------------ |
| 添加 repo 仓库           | helm repo add `bitnami` `https://charts.bitnami.com/bitnami` |
| 更新仓库                 | helm repo update                                             |
| 搜索 charts 包           | helm search repo `redis`                                     |
| 拉取 charts 包到当前目录 | helm pull `apisix/apisix`                                    |
| 安装 charts 包           | helm install `name` bitnami/mysql                            |
| 查看当前部署             | helm ls                                                      |
| 查看应用详情             | helm status `name`                                           |
| 卸载指定的 release       | helm uninstall `name`                                        |

- install 命令可以通过 - `--set image.tag=latest` 或 `--values my-values.yaml` 修改默认值

编写 helm 脚本:

|  说明   | 操作  |
|  ---  | ---  |
| 创建一个 helm 模板  | helm create `name` |
| 打包一个 helm 模板  | helm package `name` |
