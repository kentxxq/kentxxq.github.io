---
title: k8s组件剖析
tags:
  - blog
  - k8s
date: 2023-08-01
lastmod: 2023-09-02
categories:
  - blog
description: "[[笔记/point/k8s|k8s]] 的组件学习记录."
---

## 简介

[[笔记/point/k8s|k8s]] 的组件学习记录

主要组件如下:

- [[笔记/k8s组件剖析#容器|容器技术]]
- Api-server: 提供 api 接口作为主要入口
- Etcd: 存储配置和状态信息
- Controller Manager: 控制器, 管理 Replication,Deployment 等等
- Scheduler: 调度分发应用程序
- kubelet: 管理容器的启动和停止, 健康状态
- kube-proxy: 每个节点上的代理,转发的实现
- CoreDNS: 内部的 dns 解析
- [[笔记/k8s组件剖析#网络组件|网络组件]]: 联通节点, 容器网络
- Ingress Controller: 提供对外的入口. 承接 Http, https 流量

## 容器

- [[笔记/point/k8s|k8s]] 通过 [[笔记/point/CRI|CRI]] 规范来进行实际的编排操作.
- [[笔记/point/docker|docker]] 操作 [[笔记/point/Containerd|Containerd]]
- [[笔记/point/Containerd|Containerd]] 操作符合 [[笔记/point/OCI|OCI]] 标准的容器运行时. 采用 [[笔记/point/runc|runc]] 为默认容器运行时.

![[附件/容器生态图.png]]

> 题外话
> [[笔记/point/docker|docker]] 其实从 1.12 版本开始, 已经可以通过 [组件方式](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker) 支持 [[笔记/point/CRI|CRI]] 标准. 但是 [[笔记/point/Containerd|Containerd]] 直接集成 [[笔记/point/CRI|CRI]] 到了自己内部, 这样就少了 [[笔记/point/docker|docker]] 和 [[笔记/point/CRI|CRI]] 组件两个环节. 同时 [[笔记/point/Containerd|Containerd]] 不像 [[笔记/point/docker|docker]] 属于公司, 所以 [[笔记/point/k8s|k8s]] 从 1.24 版本开始切换到了 [[笔记/point/Containerd|Containerd]].

## master 节点

- [[笔记/k8s组件剖析#api-server 传递流程|api-server]]：处理 api 操作，所有组件都通过 api-server
- controller：对集群状态处理。自动容器修复，水平扩展
- [[笔记/k8s组件剖析#scheduler 调度|scheduler]]：完成调度操作。根据用户提交的的数据，调度到指定节点
- etcd：分布式存储。所有元信息存储

## node 节点

- [[笔记/k8s组件剖析#kubelet|kubelet]]：通过 api-server 拿到状态，调用 containner-runtime 启动容器
- storage-plugin 和 network-plugin 完成对应操作
- [[笔记/k8s组件剖析#kube-proxy|kube-proxy]] 服务于 service。通过 iptables 实现功能

## api-server 传递流程

1. user 提交到 api-server
2. api-server 写入到 etcd
3. scheduler 通过 watch 到的信息，进行调度决策
4. scheduler 调用 api-server，说应该怎么调度
5. api-server 写入到 etcd
6. kubelet 通过 watch 到的信息，调用 container-runtime 进行部署

## kubelet

- 定期从所监听的数据源获取期望状态，调整自身到期望状态
- 容器的健康检查与健康检查策略
- 容器监控。向 master 提供报告信息

## kube-proxy (iptables/IPVS)

kube-proxy 监听的对象如下：

- service
- endpoint/endpointslices
- node

kube-proxy 会监听 api-Server 的资源变化，配置 nodePort 和本地的 iptables/IPVS。pod 与 pod、外部请求与 pod 之间的通信，都会经过 iptables/IPVS。于是完成了流量转发和负载均衡。

外部 SLB 负载均衡，其实也是把请求转发给 nodePort。只不过每个 worker 节点上通过虚拟网卡，绑定了很多的 ip。这些 ip 对应着一个个 pod 实例。

因此负载均衡直接请求 worker 节点的特定网卡 ip 地址，即可请求到对应 pod。同时云商做了优化，性能比传统方式好。

在创建一个 service 后，通常会创建一个 endpoint 对象。

client 访问 service 的时候有 2 种方式。

1. 通过域名。也就是 coreDNS 解析出来地址
2. 通过 ip 地址访问。这是一个虚拟的 ip 地址，请求在转发到 kube-proxy 后，通过本地的 iptables 规则转发到对应的 pod

**服务拓扑**就需要监听 node 信息，实现一个服务可以指定流量是被优先路由到一个和客户端在同一个 Node 或者在同一可用区域的端点。

## scheduler 调度

### 调度过程

1. 提交到 api-server
2. controller 验证以后，api-server 中变成 pending、同时 nodeName 为空
3. scheduler 发现这个空 nodeName 的 pod 后，开始调度算法、打分。写入 nodeName
4. kubelet 在 watch 到以后，开始制定调度细节
5. 最后状态为 running

### QoS 调度打分

#### 默认优先级

- Guaranteed- 高保障：cpu 和 memory 的 request=limit，其他资源可不等
- Burstable- 中，弹性：cpu 和 memory 的 request!=limit
- BestEffort- 低，尽力而为：所有资源必须都不填

调度表现:

1. 一定先满足 request 请求
2. 如果 --cpu-manager-policy=static，且高保障 Guaranteed。会绑核, 避免 cpu 一会儿给 a 服务使用, 一会儿切换到 b 服务.
3. memory 会根据 QoS 级别进行打分，低优先级 BestEffort 被调走

#### 影响调度

- `ResourceQuota` 限制命名空间的 cpu, 内存, pods 总数
- `pod亲和,pod与node亲和,pod容忍污点` 会影响调度
- `PriorityClass` 可以配置在 pod 上, 默认没有启用

## pv 和 pvc

1. 提交创建 pvc 对象
2. csi-provisioner 给 watch 到，根据 pvc 中的 storage-class 和其他信息，调用 csi-plugin1。于是在云存储中创建真正的存储，于是有了 pv 对象
3. pv 对象被 pv-controller 观察到，于是把 pv 和 pvc 对象绑定
4. 提交的 pod 被调度到 node，kubelet 使用通过 csi-plugin2 挂载对应的 pv 到容器，再启动容器

## 网络组件

#### Flannel

[[笔记/point/docker|docker]] 容器无法跨主机通信, `Flannel` 分配子网网段, 然后记录在 `etcd` 中实现通信.

![[附件/Flannel通信示意图.png]]

>1. 数据从源容器中发出后，经由所在主机的 docker0 虚拟网卡转发到 flannel0 虚拟网卡，这是个 P2P 的虚拟网卡，flanneld 服务监听在网卡的另外一端。
> 2. Flannel 通过 Etcd 服务维护了一张节点间的路由表，该张表里保存了各个节点主机的子网网段信息。
> 3. 源主机的 flanneld 服务将原本的数据内容 UDP 封装后根据自己的路由表投递给目的节点的 flanneld 服务，数据到达以后被解包，然后直接进入目的节点的 flannel0 虚拟网卡，然后被转发到目的主机的 docker0 虚拟网卡，最后就像本机容器通信一样的由 docker0 路由到达目标容器。

#todo/笔记 自己搭建一个测试?

## 设计模式 sidecar

作用:

- **可以收集日志**。docker 应用写入到 volume，然后通过 initContainer 来收集日志。
- 访问外部集群的时候，通过它可以进行一个反向代理。这样就不需要修改容器代码。访问一个地址即可实现。**例如 zk，我们是一个集群。通过一个统一的 proxy 代理，即可让所有 docker 复用这一配置**。
- **适配器**。可以做到类似 nginx 的 rewrite 域名转发。访问/a 的时候请求转到应用 docker 的/b 路径。

![[附件/sidecar示意图.png]]

## deployment 控制器

1. 判断是否是新的版本，选择更新 replicaset 或者整个 deployment 资源
2. 更新会保存到到 etcd
3. 由 scheduler 进行调度分配
4. [[笔记/k8s组件剖析#kubelet|kubelet]] 进行 watch，执行具体的调整动作

如果调整整个 deployment 资源，那么会新建一个 replicas 来替换。回滚也是一样

## k8s 配置管理

![[附件/k8s配置管理.png]]
