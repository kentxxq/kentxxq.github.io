---
title: k8s的疑难杂症
tags:
  - blog
  - k8s
date: 2023-07-28
lastmod: 2025-01-09
categories:
  - blog
description: "这里记录处理 [[笔记/point/k8s|k8s]] 的常见问题."
---

## 简介

这里记录处理 [[笔记/point/k8s|k8s]] 的常见问题.

## 排错路线

![[附件/k8s排错路线.jpg]]

## 错误合集

### metrics-server

#### doesn't contain any IP SANs

在 metrics-server 启动的 yml 文件中, 添加启动参数

```yml
command:  
- /metrics-server  
- --kubelet-insecure-tls
```

#### kubectl top pod 报错 error: Metrics API not available

当你使用 `kubectl top pod` 来查看信息的时候, 需要安装 `Metrics-server`, [参考链接](https://github.com/kubernetes-sigs/metrics-server#installation)

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

![[笔记/k8s常用命令和配置#清理残存容器]]

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

#### Multus

网络插件的报错, 会出现如下的关键字:

`network: Multus` ... `KillPodSandbox`... `Unauthorized`... `networkPlugin cni failed`

我们在安装网络插件的时候, 只不过是通过 `kubectl create/edit` 操作了一些资源, 所以我们重启等操作不会造成其他的影响. 在官方也有不少这样的骚操作, 比如 [这个帖子的答案推荐直接尝试重启](https://github.com/projectcalico/calico/issues/5712) ....

操作流程

```shell
# 查找插件calico,flannal之类的
kubectl get all -A |grep cali

# 杀死重启
kubectl delete pod/calico-node-xxx -n 命名空间
kubectl delete pod/kube-multus-ds-xxx -n 命名空间
```

#### BGP

网络插件的报错类似于

```shell
calico/node is not ready:
BIRD is not ready:BGP not established with 192.168.200.129,192.168.200.130
Number of node(s)with BGP peering established =0
```

`calico` 通常会根据第一个网卡来配置信息. 而出现上面的报错, 就说明我们**没有找到正确的网卡, 没有配置正确的 ip 信息**.

解决:

1. `ip a` 查看我们需要用到的网卡名称. 例如 `eth0`, `ens33` 等等
2. 修改 `vim calico.yaml`

    ```yml
    # 增加内容
    - name: IP_AUTODETECTION_METHOD
      value: "interface=en*" # 也可以写死 "interface=eth0"
    # 下面是原文件内容
    - name: CLUSTER_TYPE
      value: "k8s,bgp"
    - name: IP
      value: "autodetect"
    - name: CALICO_IPV4POOL_IPIP
      value: "Always"
    ```

3. 重新部署 `kubectl apply -f calico.yaml`

### cri-dockerd

#### validate CRI v 1 runtime API for endpoint

情景：

`kubeadm init` 或 `crictl ps` 的时候报错：

`validate CRI v1 runtime API for endpoint "unix:///var/run/cri-dockerd.sock"`

解答：

- 网上很多的教程都有一定的滞后性。如果无法保证所有组件的版本，架构一致，可能会出现问题。包括但不限于：[[笔记/point/k8s|k8s]] 版本，cni 版本，docker 版本，containerd 版本，arm 架构， x 86 架构等等。
- cri-dockerd 是为了不停兼容 cri 标准。所以 cri-dockerd 和 [[笔记/point/k8s|k8s]] 的版本兼容性比较好。而 dockerd 的内部 api 可能会经常变动，比如下图 cri-dockerd 的 `v0.3.8` 开始兼容 [[笔记/point/docker|docker]] 的 `v24.0.7` 版本 ![[附件/cri-dockerd兼容docker版本.png]]

处理:

1. **建议下载最新**的 cri-dockerd 版本，配置 cri-dockerd：

    ```shell
    # 获取软件
    mkdir /data/softs && cd /data/softs
    wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.2.1/cri-dockerd-0.3.8.amd64.tgz
    # 解压软件
    tar xf cri-dockerd-0.3.8.amd64.tgz
    mv cri-dockerd/cri-dockerd /usr/local/bin/
    # 检查效果
    cri-dockerd --version
    
    # 守护进程
    vim /etc/systemd/system/cri-dockerd.service
    [Unit]
    Description=CRI Interface for Docker Application Container Engine
    Documentation=https://docs.mirantis.com
    After=network-online.target firewalld.service docker.service
    Wants=network-online.target
    [Service]
    Type=notify
    ExecStart=/usr/local/bin/cri-dockerd --network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin --container-runtime-endpoint=unix:///var/run/cri-dockerd.sock --image-pull-progress-deadline=30s --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.6 --cri-dockerd-root-directory=/var/lib/dockershim --docker-endpoint=unix:///var/run/docker.sock --cri-dockerd-root-directory=/var/lib/docker
    ExecReload=/bin/kill -s HUP $MAINPID
    TimeoutSec=0
    RestartSec=2
    Restart=always
    StartLimitBurst=3
    StartLimitInterval=60s
    LimitNOFILE=infinity
    LimitNPROC=infinity
    LimitCORE=infinity
    TasksMax=infinity
    Delegate=yes
    KillMode=process
    [Install]
    WantedBy=multi-user.target
    
    
    vim /usr/lib/systemd/system/cri-dockerd.socket
    [Unit]
    Description=CRI Docker Socket for the API
    PartOf=cri-docker.service
    [Socket]
    ListenStream=/var/run/cri-dockerd.sock
    SocketMode=0660
    SocketUser=root
    SocketGroup=docker
    [Install]
    WantedBy=sockets.target
    
    
    # 启动服务
    systemctl daemon-reload
    systemctl enable cri-dockerd.service
    systemctl restart cri-dockerd.service
    # 检测效果
    crictl --runtime-endpoint /var/run/cri-dockerd.sock ps
    ```

2. `vim /etc/containerd/config.toml` **去除** `disabled_plugins = ["cri"]`. 重启 [[笔记/point/Containerd|Containerd]] `systemctl restart containerd`
3. 测试是否可以通过 cri-dockerd 联通 docker

    ```shell
    # cat /etc/crictl.yaml
    runtime-endpoint: "unix:///var/run/cri-dockerd.sock"
    image-endpoint: "unix:///var/run/cri-dockerd.sock"
    timeout: 10
    debug: false
    pull-image-on-create: true
    disable-pull-on-run: false
    
    # 测试效果
    crictl ps
    ```

#### kubeadm 无法指定 --cri-socket

准备一个配置文件 `kube-init.yaml`

```yml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
nodeRegistration:
  criSocket: unix:///var/run/cri-dockerd.sock
```

引入配置文件即可：

`kubeadm init phase upload-certs --upload-certs --config kube-init.yml`

### CrashLoopBackOff 排错

- 看 stdout 日志 `kubectl logs pod-name`
- `kubectl debug -it pod名称 --image=镜像名称 -- /bin/bash`, 然后手动跑命令测试
