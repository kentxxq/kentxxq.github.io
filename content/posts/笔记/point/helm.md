---
title: helm
tags:
  - point
  - helm
date: 2023-07-08
lastmod: 2023-07-08
categories:
  - point
---

`helm` 是 [[笔记/point/k8s|k8s]] 用来将应用所需资源打包为一个整体的工具。可类比为 yum/centos ,apt/ubuntu.

基础概念:

1. repo 是一个仓库，有一些别人写好的。你自己的代码打包以后也可以上传到私有仓库
2. charts 是一个应用所需资源的概括
3. release 是一个 charts 发布到 k8s 后的实例

基础操作:

|  说明   | 操作  |
|  ---  | ---  |
| 添加 repo 仓库  | helm repo add `bitnami` `https://charts.bitnami.com/bitnami` |
| 更新仓库  | helm repo update |
| 搜索 charts 包  | helm search repo `redis` |
| 安装 charts 包  | helm install `name` bitnami/mysql |
| 查看当前部署  | helm ls |
| 查看应用详情  | helm status `name` |
| 卸载指定的 release | helm uninstall `name` |

编写 helm 脚本:

|  说明   | 操作  |
|  ---  | ---  |
| 创建一个 helm 模板  | helm create `name` |
| 打包一个 helm 模板  | helm package `name` |
