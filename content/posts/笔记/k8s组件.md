---
title: k8s组件
tags:
  - blog
  - k8s
date: 2023-08-01
lastmod: 2023-08-01
categories:
  - blog
description: "[[笔记/point/k8s|k8s]] 的组件学习记录."
---

## 简介

[[笔记/point/k8s|k8s]] 的组件学习记录.

## 内容

### 网络组件

#### Flannel

[[笔记/point/docker|docker]] 容器无法跨主机通信, `Flannel` 分配子网网段, 然后记录在 `etcd` 中实现通信.

![[附件/Flannel通信示意图.png]]

>1. 数据从源容器中发出后，经由所在主机的 docker0 虚拟网卡转发到 flannel0 虚拟网卡，这是个 P2P 的虚拟网卡，flanneld 服务监听在网卡的另外一端。
> 2. Flannel 通过 Etcd 服务维护了一张节点间的路由表，该张表里保存了各个节点主机的子网网段信息。
> 3. 源主机的 flanneld 服务将原本的数据内容 UDP 封装后根据自己的路由表投递给目的节点的 flanneld 服务，数据到达以后被解包，然后直接进入目的节点的 flannel0 虚拟网卡，然后被转发到目的主机的 docker0 虚拟网卡，最后就像本机容器通信一样的由 docker0 路由到达目标容器。
