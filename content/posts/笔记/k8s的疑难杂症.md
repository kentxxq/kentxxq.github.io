---
title: k8s的疑难杂症
tags:
  - blog
  - k8s
date: 2023-07-28
lastmod: 2023-08-21
categories:
  - blog
description: "这里记录处理 [[笔记/point/k8s|k8s]] 的常见问题."
---

## 简介

这里记录处理 [[笔记/point/k8s|k8s]] 的常见问题.

## 内容

### `error: Metrics API not available` 和 `kubectl top pod`

需要安装 `Metrics-server`, [参考链接](https://github.com/kubernetes-sigs/metrics-server#installation)

1. 下载下来

    ```shell
    curl https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -o metrics-server.yaml
    ```

2. 因为多数都是自签名证书, 所以添加启动参数 `--kubelet-insecure-tls`

    ```yml
    ...
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      labels:
        k8s-app: metrics-server
      name: metrics-server
      namespace: kube-system
    spec:
      selector:
        matchLabels:
          k8s-app: metrics-server
      strategy:
        rollingUpdate:
          maxUnavailable: 0
      template:
        metadata:
          labels:
            k8s-app: metrics-server
        spec:
          containers:
          - args:
            - --cert-dir=/tmp
            - --secure-port=4443
            - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
            - --kubelet-use-node-status-port
            - --metric-resolution=15s
            - --kubelet-insecure-tls # 添加此行
    ...
    ```

### too many pods 容器启动失败

发现 [[笔记/point/kubesphere|kubesphere]] 的 cicd 容器无法启动, 于是排查容器 `kubectl describe pod/cicdrfbh9-pay-h5-35-gn0rf-pl1sr-g8tpr -n kubesphere-devops-worker` 提示 `too many pods`, 下面是操作方法.

完整顺序应该是

1. 先排水
2. 不可调度
3. 改配置, 重启
4. 重新调度

Kubelet 的启动配置通常是这样, 我们加上 `--max-pods=300` 然后重启 kubelet 服务即可.

```toml
Environment="KUBELET_EXTRA_ARGS=--node-ip=10.30.1.127 --hostname-override=node1 --max-pods=300"
ExecStart=/usr/local/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
```

### 清理残存的容器

![[笔记/k8s常用命令#清理残存容器]]

### 证书

```shell
# 查找证书
find / -name apiserver.crt
/etc/kubernetes/pki/apiserver.crt

# 查看证书过期时间
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -dates
notBefore=Apr 22 06:54:59 2022 GMT
notAfter=Apr  1 19:00:00 2024 GMT

# kuadm查看证书状态
kubeadm certs check-expiration
```

### 网络插件错误

网络插件的报错, 会出现如下的关键字:

`network: Multus` ... `KillPodSandbox`... `Unauthorized`... `networkPlugin cni failed`

而我们在安装网络插件的时候, 只不过是通过 `kubectl create/edit` 操作了一些资源, 所以我们重启等操作不会造成其他的影响. 在官方也有不少这样的骚操作, 比如 [这个帖子的答案推荐直接尝试重启](https://github.com/projectcalico/calico/issues/5712) ....

操作流程

```shell
# 查找插件calico,flannal之类的
kubectl get all -A |grep cali

# 杀死重启
kubectl delete pod/calico-node-xxx -n 命名空间
kubectl delete pod/kube-multus-ds-xxx -n 命名空间
```
