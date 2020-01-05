---
title:  我的k8s之路
date:   2019-07-04 11:08:00 +0800
categories: ["笔记"]
tags: ["k8s","Azure"]
keywords: ["k8s","Azure","微软","kubectl","kubernetes"]
description: "我现在服务器上的微信，博客笔记，redis等等服务都是用的docker部署。在之前写过[部署web服务（可拓展）](https://kentxxq.com/contents/%E9%83%A8%E7%BD%B2web%E6%9C%8D%E5%8A%A1%E5%8F%AF%E6%8B%93%E5%B1%95/)，从现在的观点来看，还是比较落伍的，几乎没有自动化。代码部署/系统维护等等的问题没有考虑进去。而docker就解决了这些问题。而k8s则是docker在企业实践中的事实标准。我就用大白话来说说自己的理解和使用吧。"
---


> 我现在服务器上的微信，博客笔记，redis等等服务都是用的docker部署。在之前写过[部署web服务（可拓展）](https://kentxxq.com/contents/%E9%83%A8%E7%BD%B2web%E6%9C%8D%E5%8A%A1%E5%8F%AF%E6%8B%93%E5%B1%95/)，从现在的观点来看，还是比较落伍的，几乎没有自动化。代码部署/系统维护等等的问题没有考虑进去。而docker就解决了这些问题。
>
> 而k8s则是docker在企业实践中的事实标准。
>
> 我就用大白话来说说自己的理解和使用吧。


## 关于k8s

每当出现一个问题，就会出现对应的解决方法。下面是我个人的理解的简化版。

`openstack`是把一堆硬件资源，整合到一起变成一台超级计算机。在此基础上，虚拟出各种资源。**对硬件资源进行了整合。同时方便扩容。**

`docker`**解决的是app应用的环境问题。**

`k8s`**解决了docker编排，负载均衡，自动拓展等等问题。**

openstack是为了让vm无忧无虑的健康运行。k8s则是为你的docker提供完美的环境。


## 概念

这里我仅列出来我暂时用到的概念。总不能一上来，把文档从头看到尾吧～

### Pod


`Pod`是k8s的**最小计算单元**。最常用的情况就是一个docker容器（同时也是推荐用法）。

如果像是redis集群这样的应用，每个pod之间可以使用卷功能来进行共享数据。

通常在大型应用的场景下，docker的部署很多都是一台机器运行一个docker容器。

而如果你只有3个节点的k8s集群，你也可以运行3个以上的pod。虽然不推荐这样子，但是k8s首要目的是为了让你的部署方案能成功。

pod中的Controller通过Template来创建pod。

### Service

`Service`是pod的逻辑集合。**对内进行pod的负载均衡。对外提供访问地址。**

### Volume

`Volume`为pod提供**共享数据卷**。

### Lable

`Lable`用来**区分service/pod等资源**。LableSelector用来service/pod之间的对应。

### Deployment

`Deployment`它**管理ReplicaSets和Pod**，并提供声明式更新等功能。

一个pod挂了，应用就挂了。而通过Deployment设置用几个pod来提供服务，确保应用正常运作。

- web应用
- win10的激活可以自己搭建kms服务器。而并不需要数据库来存储任何信息。

### StatefulSet

`StatefulSet`用于**持久性的应用程序**，有唯一的网络标识符（IP），持久存储，有序的部署、扩展、删除和滚动更新。

- redis集群
- 部署应用后一键回滚，且不影响运行中的应用

### Job

`Job`用来**执行一次性的任务**。可定时。

- 比如开启100个pod来执行一个cpu密集型的应用。完了存到数据库以后，直接销毁。


### 示例

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: redis
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: microsoft/azure-vote-front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```

## 操作上手

其实这不是我第一次使用云厂商的k8s服务。第一次用的是华为云。而这一次用Azure来试试。体验一下不同点和共同点。日后也方便自己选择平台。

Azure有专门的命令行工具。可以帮助你快速操作Azure，包括管理你的k8s集群。

### 创建k8s集群

aks是azure k8s service的简写。

这部分参考[官方文档](https://docs.microsoft.com/zh-cn/azure/aks/)比较好。且非常简单。

### kubectl操作

`kubectl`是一个让你连接到k8s集群的工具。

下面是一些常用的命令。你可以通过`kubectl help`或者[参考kubectl官方文档](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)

---

`kubectl get`获取简要信息。

获取k8s的运行中pods

```bash
kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
azure-vote-back-7fb47b8f6d-ls68j    1/1     Running   0          22h
azure-vote-front-7dbf9f5dfb-zv4wz   1/1     Running   0          22h
```

获取k8s的nodes节点

```bash
kubectl get nodes
NAME                       STATUS   ROLES   AGE   VERSION
aks-agentpool-42416830-0   Ready    agent   24h   v1.12.8
aks-agentpool-42416830-1   Ready    agent   24h   v1.12.8
aks-agentpool-42416830-2   Ready    agent   24h   v1.12.8
aks-agentpool-42416830-3   Ready    agent   24h   v1.12.8
```

---

`kubectl describe`根据上面获得的name信息，可以通过查看deployment/pod/service/node等等详情。例如：

`kubectl describe deployment azure-vote-back`:查看指定的deployment当前状态

---

`kubectl create -f xxx.yml`通过yml文件内的内容进行集群的创建。

---

`kubectl rolling-update`进行滚动更新。用来确保应用不中断运行。云厂商提供的滚动更新和灰度更新等等都基于此。

---

`kubectl autoscale`自动负载均衡。

---

`kubectl exec`进入pods，类似docker exec。

---

`kubectl cp`用来交互pod中的数据。

---

`kubectl cordon, drain, uncordon`把运行在某个node上的pods挪走，你便可以对node进行配置修改或者排错。

cordon先将node节点标记为不可再调度。drain挪走node节点上的pods等服务。uncordon恢复node为可调度状态。

---

**就到这了。我也就不做官网的搬运工了。。**


### 还有后续。。。等完全理解完继续写。。



## 总结

不得不说的是，微软的文档是我见过最棒的。之前我见过别人说为什么java有那么多的开源库和方案，而c#很少？因为C#官方文档好，且都是官方自己做轮子，集成到了标准库。不需要了呀。

比如说json，java有fastjson/gson/jackson等等。。真的是头大。