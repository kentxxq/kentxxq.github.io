---
title: k3d教程
tags:
  - blog
date: 2023-08-22
lastmod: 2023-11-24
categories:
  - blog
description: 
---

## 简介

这里记录 `k3d` 是使用和配置

## 内容

### 安装

到 [Releases · k3d-io/k3d](https://github.com/k3d-io/k3d/releases) 下载对应的版本即可.

```shell
curl -L https://github.com/k3d-io/k3d/releases/download/v5.6.0/k3d-linux-amd64 -o k3d
chmod +x k3d
mv k3d /usr/local/sbin/k3d
```

### 创建 registry

为什么创建集群之前需要先创建 registry? 因为国内的网络问题.

创建 registry , 将请求代理到国内可以访问的地址.

```shell
# k3d节点内可以通过 k3d-节点名 例如 k3d-docker.io.localhost:5000 连接
# -p 5000说明宿主机也是5000端口访问

k3d registry create docker.io.localhost -p 5000 --proxy-remote-url https://hub-mirror.c.163.com

k3d registry create registry.k8s.io.localhost -p 5001 --proxy-remote-url https://k8s.dockerproxy.com

k3d registry create ghcr.io.localhost -p 5002 --proxy-remote-url https://ghcr.dockerproxy.com

k3d registry list
```

### 使用集群

#### 创建集群

创建配置文件 `vim k3d-default.yaml`

```yml
---
apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: k3s-default
servers: 1
agents: 1
image: docker.io/rancher/k3s:v1.27.4-k3s1
kubeAPI:
  host: "127.0.0.1" # kubeconfig的server名字
  hostIP: "0.0.0.0" # 接受所有的请求
  hostPort: "6445" # api-server在宿主机的6445端口
ports:
  # same as `--port '80:80@loadbalancer'`
  # 通过loadbalancer映射80端口到宿主机
  - port: 80:80
    nodeFilters:
      - loadbalancer
registries:
  # 这里的配置,让内部可以通过域名方式请求到registry
  use:
    - k3d-docker.io.localhost:5000
    - k3d-registry.k8s.io.localhost:5001
  # 这里配置你想要代理的源
  config: |
    mirrors:
      docker.io:
        endpoint:
          - "http://k3d-docker.io.localhost:5000"
      registry.k8s.io:
        endpoint:
          - "http://k3d-registry.k8s.io.localhost:5001"
options:
  k3s:
    extraArgs: # --k3s-arg的额外参数
      # 证书里添加公网ip,这样就可以远程连接
      - arg: "--tls-san=1.2.3.4"
        nodeFilters:
          - server:*
      # 禁用traefik,自己安装ingress-nginx
      - arg: "--disable=traefik"
        nodeFilters:
          - server:*
```

创建集群

```shell
k3d cluster create -c k3d-default.yaml
```

#### 添加节点

```shell
# 添加节点到指定集群
k3d node create 节点名称 -c k3s-default
```

#### 移除集群

```shell
k3d cluster delete
```

## 相关参考

![[笔记/安装k8s#Ingress|安装Ingress]]

`k3d` 相关链接:

- [完整配置示例](https://k3d.io/v5.6.0/usage/configfile/)
- [k3d的Registries使用文档](https://k3d.io/v5.6.0/usage/registries/)
