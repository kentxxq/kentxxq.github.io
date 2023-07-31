---
title: k8s的疑难杂症
tags:
  - blog
  - k8s
date: 2023-07-28
lastmod: 2023-07-30
categories:
  - blog
description: "这里记录处理 [[笔记/point/k8s|k8s]] 的常见问题."
---

## 简介

这里记录处理 [[笔记/point/k8s|k8s]] 的常见问题.

## 内容

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

强制删除 pod, 其他资源同参数也可以删除.

```shell
kubectl delete pod pod名称 -n 命名空间 --force --grace-period=0
```

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

而我们在安装网络插件的时候, 只不过是通过 `kubectl create/edit` 操作了一些资源, 所以我们重启等操作不会造成其他的影响. 在官方也有不少这样的骚操作, 比如 [这个](https://github.com/projectcalico/calico/issues/5712) 直接尝试重启....

操作流程

```shell
# 查找插件calico,flannal之类的
kubectl get all -A |grep cali

# 杀死重启
kubectl delete pod/calico-node-xxx -n 命名空间
kubectl delete pod/kube-multus-ds-xxx -n 命名空间
```
