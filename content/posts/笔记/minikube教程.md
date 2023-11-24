---
title: minikube教程
tags:
  - blog
  - minikube
date: 2023-08-17
lastmod: 2023-11-24
categories:
  - blog
description: "这里记录 [[笔记/point/minikube|minikube]] 的一些配置和用法."
---

## 简介

这里记录 [[笔记/point/minikube|minikube]] 的一些配置和用法.

## 内容

### 前置条件

- 安装好 [[笔记/point/kubectl|kubectl]]
- 安装好 [[笔记/docker教程#安装/卸载 docker|docker]]
- 一个良好的网络. 例如提前部署一个 [[笔记/clash配置|clash代理]]
- 内存, cpu, 磁盘宽裕一点

### 命令配置

[官方文档在这](https://minikube.sigs.k8s.io/docs/start/)

```shell
# 下载下来
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# 类似mv安装,但保留了权限
install minikube-linux-amd64 /usr/local/bin/minikube
```

### 使用

#### 启动

```shell
# 外部机器访问 --apiserver-ips=minikube机器ip
# 监听接收 --listen-address=0.0.0.0
# 不限制cpu,默认是2 --cpus='max'
# 节点数量 --nodes 3
# 内存大小 --memory 4096  或者 max
# root启动需要使用--force
# --docker-env 使用代理
# --kubernetes-version v1.7.0
# apiserver添加额外参数 --extra-config=apiserver.feature-gates=RemoveSelfLink=false
minikube start --cpus='max' --memory max --force --listen-address=0.0.0.0 --apiserver-ips=minikube机器ip --docker-env HTTP_PROXY=${http_proxy} --docker-env HTTPS_PROXY=${https_proxy} --docker-env NO_PROXY=localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.test.example.com
```

#### 启用 ingress

推荐使用 [[笔记/安装k8s#Ingress|yml安装Ingress]]

**如果网络不佳，不推荐使用 addons**

```shell
minikube addons enable ingress
```

#### 使用中

```
# 查看所有集群
minikube profile list
# 节点操作
minikube node add|start|stop|delete|list
```

#### 使用后

```
# 删除minikube集群, --all 删除所有集群
minikube delete 
```

### 远程访问

> 启动过程中必须添加参数
> --apiserver-ips=minikube 机器 ip
> --listen-address=0.0.0.0

1. 复制配置文件 `~/.kube/config` 到本地.
2. 通过 `base64 -w 0 -i` 拿到对应的 data 值.

    ```shell
    echo ;
    echo certificate-authority-data ; base64 -w 0 -i /root/.minikube/ca.crt; echo -e "\n\n" \
    echo client-certificate-data ; base64 -w 0 -i /root/.minikube/profiles/minikube/client.crt; echo -e "\n\n" \
    echo client-key-data ; base64 -w 0 -i /root/.minikube/profiles/minikube/client.key; echo -e "\n\n"
    ```

3. 通过 `docker port minikube(集群主节点容器名称)` 拿到 8443 指向的端口. 例如 `8443/tcp -> 0.0.0.0:32769`,则端口填 32769.
4. 把 2 和 4 的值填入本地 config 文件中.

```yml
apiVersion: v1
clusters:
- cluster:
    # certificate-authority: /xxx
    # base64 -w 0 -i /xxx 得到 ooo==
    certificate-authority-data: ooo==
    extensions:
    - extension:
        last-update: Tue, 22 Aug 2023 11:04:25 CST
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: cluster_info
    server: https://minikube机器ip:端口
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Tue, 22 Aug 2023 11:04:25 CST
        provider: minikube.sigs.k8s.io
        version: v1.30.1
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate-data: # 取base64 client-certificate
    client-key-data: # 取base64 client-key
```
