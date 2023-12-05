---
title: lstio
tags:
  - blog
  - lstio
date: 2023-12-04
lastmod: 2023-12-05
categories:
  - blog
description: 
---

## 简介

`lstio` 应该是现在的服务网格事实标准.

## 概念速览

### 功能介绍

[Istio / 概念](https://istio.io/latest/zh/docs/concepts/)

- 流量管理：负载均衡，动态旅游，灰度发布
- 可观察性：调用链，访问日志，监控
- 策略执行：限流，ACL
- 安全：认证和鉴权

### 基础架构

随着版本变化，组件能力的加强，降低复杂性，基础架构慢慢简化。

- 数据层面：envoy
- 控制层面：Istiod
    - Pilot：转换规则，下发规则到 proxy。主要是服务发现的规则，以及流量的管理。提供了 a/b 测试，金丝雀发布。弹性（超时，重试，熔断）
    - Mixer：接管流量。每次 proxy 之间的请求，都会上传和报告。所以可以控制访问，以及收集遥测数据。主要是因为 envoy 功能的增强，很多功能整合到了 envoy，所以 mixer 功能变少。
    - Citadel：服务间的安全认证。例如双向 tls 的安全
    - Galley：Istio 配置的管理组件，解耦 istio 与 [[笔记/point/k8s|k8s]] ，避免强绑定。验证、处理和分发配置信息到各个 Istio 组件。

## istioctl

### 安装

1. 下载 [Releases · istio/istio](https://github.com/istio/istio/releases)
2. `tar xf istio-1.20.0-linux-amd64.tar.gz`
3. `vim ~/.bashrc` 添加 bin 目录到 PATH 变量 `export PATH=/root/istio-1.20.0/bin:$PATH`

### istioctl 概念和命令

`istioctl` 由核心 `core` 与插件 `addons` 组成。不同的应用场景，就是不同插件的组合。

常见组件：

- `istio core` CRD 之类的
- `istiod` 控制平面
- `ingress/egress gateway` 出入网关

初始命令：

- `istioctl profile list` 查看所有组合。每个组合对应 `manifests/profiles` 下面的一个 yml 文件。
    - `demo` 比较完整。有采集指标，适合**演示**
    - `default` 默认适合**生产环境**
    - `minimal` 仅部署控制平面
    - `preview` 更高级别 demo，**新功能尝鲜**
- `istioctl profile diff demo empty` 查看 2 个配置的区别
- `istioctl manifest generate --set profile=demo` 生成 yml 文件
- `istioctl install`
    - `--set profile=demo` 选择配置
    - `--set xxx.xxx.xxx=true` 修改某个 profile 的值
    - `-f xxx.yml` 自定义指定 yml
操作命令：
- `istioctl analyze -n default` 检测 xxx 空间是否正常注入
- `istioctl experimental precheck` 检测更新，部署，调整后控制平面是否正常
- `istioctl uninstall -f demo.yml` 或 `istioctl uninstall --purge` 卸载

## 相关操作

### 初始验证

```shell
# 加上标签，开始自动注入
# 删除 istio-injection-
# 覆盖 --overwrite
kubectl label namespace default istio-injection=enabled --overwrite
# 确认打上了标签
kubectl get namespaces default --show-labels
# 创建容器
kubectl create deployment my-nginx --image=nginx:latest

# 验证
# 发现多个pod和很多内容
kubectl get po
kubectl describe pod my-nginx-86d74cfc8f-5wvjn
```
