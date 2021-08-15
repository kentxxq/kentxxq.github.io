---
title:  CICD之helm
date:   2021-07-07 17:41:00 +0800
categories: ["笔记"]
tags: ["CICD","helm"]
keywords: ["CICD","helm"]
description: "最近一直在忙k8s和cicd相关的内容。要学习和关注的内容有点多。做一个笔记来记录一下"
draft: true
---


## helm是什么

helm是用来将应用所需资源打包为一个整体。可类比为 yum/centos ,apt/ubuntu.

优点：
1. **整体部署**:例如后台api服务需要deployment对pod进行管理、同时需要service对外提供服务。可以统一部署、升级、回滚。
2. **版本化管理**:例如redis可以多次部署，且完全隔离而又一致。

## 使用入门

### 基础概念

1. repo是一个仓库，有一些别人写好的。你自己的代码打包以后也可以上传到私有仓库
2. charts是一个应用所需资源的概括
3. release是一个charts发布到k8s后的实例

### 基础操作

|  说明   | 操作  |
|  ---  | ---  |
| 添加repo仓库  | helm repo add `bitnami` `https://charts.bitnami.com/bitnami` |
| 更新仓库  | helm repo update |
| 搜索charts包  | helm search repo `redis` |
| 安装charts包  | helm install `name` bitnami/mysql |
| 查看当前部署  | helm ls |
| 查看应用详情  | helm status `name` |
| 卸载指定的release | helm uninstall `name` |



### 编写helm脚本

|  说明   | 操作  |
|  ---  | ---  |
| 创建一个helm模板  | helm create `name` |
| 打包一个helm模板  | helm package `name` |