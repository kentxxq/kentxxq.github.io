---
title: CKA认证
tags:
  - blog
  - k8s
date: 2023-08-14
lastmod: 2023-08-31
categories:
  - blog
description: "CKA 是 [[笔记/point/k8s|k8s]] 的一个管理员认证, 我也弄了一个证书 [[附件/CKA证书.pdf|CKA证书]]"
---

## 简介

CKA 是 [[笔记/point/k8s|k8s]] 的一个管理员认证, 我也弄了一个证书 [[附件/CKA证书.pdf|CKA证书]].

## 考试题

### 扩容

将名为 my-nginx 的 deployment 的数量，扩展至 10 个 pods.

环境准备:

```shell
kubectl create deployment my-nginx --image=nginx
```

答题:

```shell
kubectl scale deployment my-nginx --replicas=10
```

### 多容器

创建一个多容器的 Pod 对象

- nginx 容器用 nginx 镜像
- redis 容器用 redis 镜像
- tomcat 容器用 tomcat 镜像
- mysql 容器用 mysql

答题:

```yml
apiVersion: v1
kind: Pod
metadata:
  name: multi
spec:
  containers:
    - name: nginx
      image: nginx
    - name: redis
      image: redis
    - name: tomcat
      image: tomcat
    - name: mysql
      image: mysql:5.7
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: "mima"
```

### 添加容器端口, 通过 service 暴露服务

```yml
# images下加上ports相关内容
containers:
 - image: nginx
   imagePullPolicy: Always
   name: nginx
   ports:
   - name: http
     protocol: TCP
     containerPort: 80
```

暴露端口 80

```shell
kubectl expose deployment front-end --name=front-end-svc --port=80 --target-port=80 --type=NodePort 
```

### pod 添加 sidecar

题目:

1. sidecar 使用 busybox，添加到 pod `legacy-app` 中
2. 新 sidecar 运行 `/bin/sh -c tail -n+1 -f /var/log/legacy-app.log`
3. 使用安装在/var/log 的卷，使日志 legacy-app.log 可用于 sidecar 的容器

答题:

1. 将 pod 导出成 yml 保存到文件中 `kubectl get pod legacy-app -o yaml > 1.yml`
2. 编辑文件 `vim 1.yml`  

	```yml
	apiVersion: v1
	kind: Pod
	metadata:
	  name: legacy-app
	spec:
	  containers:
	  - name: count
	    image: busybox
	    args:
	    - /bin/sh
	    - -c
	    - >
	      i=0;
	      while true;
	      do
	      echo "$i: $(date)" >> /var/log/legacy-app.log;
	      sleep 1;
	      done
	    volumeMounts:
	    - name: varlog
	      mountPath: /var/log
	  - name: sidecar
	    image: busybox
	    args: [/bin/sh, -c, 'tail -n+1 -f /var/log/legacy-app.log']
	    volumeMounts:
	    - name: varlog
	      mountPath: /var/log
	  volumes: # volumes 块在导出的 yaml 下面已经有了，在已有的添加下面两行即可
	    - name: varlog
	      emptyDir: {}
	```

3. `kubectl apply -f 1.yml` 应用改动. 如果失败则先 `kubectl delete pod legacy-app` 删除.

### 创建 PV

创建名为 app-data 的 pv，容量 2 Gi。ReadwriteOnce,hostPath，位于/srv/app-data

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: app-data
spec:
  capacity:
    storage: 2Gi
  accessModes:
    - ReadWriteOnce
  hostPath: "/srv/app-data"
```

### 操作 PVC

创建一个名为 app-pvc 的 PVC 资源对象

- 容量大小为 50 Mi
- 访问模式为 ReadWriteOnce
- 基于 storageclass 的 SC 资源对象创建

创建一个名为 app-pod 的 Pod 资源对象

- 依赖镜像为 Nginx
- 挂载路径为 /usr/share/nginx/html

调整 PVC 的资源对象为 100Mi

答题:

先查看有哪些 sc?

```shell
kubectl get sc
```

创建一个 `pvc` 和 `pod`

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-pvc
spec:
  storageClassName: standard # 把sc的名字填在这里
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
    - name: app-pod
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: app-data
  volumes:
    - name: app-data
      persistentVolumeClaim:
        claimName: app-pvc
```

修改 pvc 的大小. `kubectl edit pvc/app-pvc --save-config` 编辑后退出即可. **如果报错**, 提示你尝试 `kubectl replace -f /tmp/kubectl-edit-1602427990.yaml` 说明没有成功修改. 你尝试此命令后, 如果依然报错.

**删掉已创建的容器, 编辑 yml 文件内容, 重新创建 pvc 和 pod.**

参考文档:[配置 Pod 以使用 PersistentVolume 作为存储 | Kubernetes](https://kubernetes.io/zh/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

### 授权 rbac

创一个 clusterrole 将 deployment-clusterrole，允许创建 deployment、statefulset、daemonset。绑定到 app-team1 中 cicd-token 的 serviceaccount

```shell
# 创建一个clusterrole
kubectl create clusterrole "default-clusterrole" --verb=create --resource=deployment,statefulset,daemonset
# 创建命名空间
kubectl create namespace app-team1
# 创建serviceaccount 且指定命名空间
kubectl create serviceaccount cicd-token -n app-team1
# 权限绑定到一起就授权了
kubectl create clusterrolebinding rb --clusterrole=default-clusterrole --serviceaccount=app-team1:cicd-token -n app-team1
```

### 网络 networkpolicy

创建 allow-port-from-namespace 的策略，允许 my-app 连接 big-corp 的 8080

1. 不允许访问没有监听 8080 端口的服务
2. 仅允许 my-app 中的 pod 访问

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-port-from-namespace
  namespace: big-corp
spec:
  podSelector:
    matchLabels:
      namespace: db
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              project: my-app
      ports:
        - protocol: TCP
          port: 8080
```

### Ingress 转发

创建一个名为 my-ingress 的 ingress:

- 该 ingress 位于 app-team 的命名空间中
- 名称为 django 的 svc，提供 8000 端口服务
- ingress 提供一个 /django 的 url 入口，用于访问 django 的 svc

环境准备:

```shell
# 创建命名空间
kubectl create ns app-team
# 创建一个应用,方便svc对接
kubectl create deployment django-deployment --image=nginx -n app-team
```

答题:

```yml
apiVersion: v1
kind: Service
metadata:
  name: django
  namespace: app-team
spec:
  selector:
    app: django-deployment
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8000
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: django-ingress
  namespace: app-team
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: "django-ingress.kentxxq.com"
    http:
      paths:
      - path: /django
        pathType: Prefix
        backend:
          service:
            name: django
            port:
              number: 8000
```

### ETCD

#### 题目

将当前 kubernetes 集群的 etcd 数据进行备份

- etcd 的 endpoint 位置为 https://127.0.0.1:2379
- 保存到 `/data/backup/` 目录下，文件名为 `snapshot-etcd.db`。
- 将之前存储的 `/data/backup/snapshot-etcd-previous.db` 数据进行还原

#### 文件目录

切换到题目对应的 `context`, 然后 `ssh` 连接到 `master` 节点. 考虑 `sudo -i` 切换到 root 用户.

1. `systemctl cat etcd` 查看是否部署了 etcd. 然后通过启动命令拿到证书, 数据位置
2. 如果是容器部署的, 那么需要我们来查找

```shell
# 找到etcd
kubectl get pods -n kube-system
...
etcd 1/1     Running   0          8m51s
...

# 拿到路径
kubectl describe pod/etcd -n kube-system
...
command:
  etcd
  --data-dir=路径
  --key-file=路径
  --cert-file=路径
  --trusted-ca-file=路径
...
```

#### 数据备份

答题:

```shell
etcdctl snapshot save /data/backup/etcd-snapshot.db
--endpoints=https://127.0.0.1:2379
--cacert=/xxx/ca.crt
--cert=/xxx/etcd-client.crt
--key=/xxx/etcd-client.key
```

#### 数据恢复

`etcd` 以服务的方式运行 (独立于 `k8s` ):

```shell
# 关闭服务,减少影响.
systemctl stop api-server etcd
# 把data-dir备份起来
mv /var/lib/etcd /var/lib/etcd.bak

# 恢复数据
ETCDCTL_API=3 etcdctl snapshot restore /data/backup/snapshot-etcd-previous.db --data-dir=/var/lib/etcd ...endpoint...ca...cert...key...
# 如果是生产环境,可能会有多个etcd节点,那么应该加上下面这些参数
# 当前节点的名称
# --name etcd-0 \
# 所有的节点
# --initial-cluster etcd-0=http://host1:2380,etcd-1=http://host2:2380,etcd-2=http://host3:2380  \ 
# 初始化互相通信用到的token
# --initial-cluster-token etcd-cluster \ 
# 宣告自己是谁
# --initial-advertise-peer-urls https://host1:2380

# 调整权限
chown -R etcd:etcd /var/lib/etcd
# 启动etcd
systemctl start etcd
# 确认健康状态
ETCDCTL_API=3 etcdctl --cacert=/opt/kubernetes/ssl/ca.pem --cert=/opt/kubernetes/ssl/server.pem --key=/opt/kubernetes/ssl/server-key.pem --endpoints=https://host1:2379,https://host2:2379,https://host3:2379 endpoint health
# 启动apiserver,确认etcd状态正常再启动api-server
systemctl start api-server
```

`etcd` 以 pod 的方式运行 (在 `k8s` 的内部):

```shell
# 通常kubeadm安装的k8s,manifest在/etc/kubernetes/manifests,而下面就有etcd.yaml文件
# 参考https://kubernetes.io/zh-cn/docs/reference/setup-tools/kubeadm/implementation-details/
mv /etc/kubernetes/manifests /etc/kubernetes/manifests-bak
# etcd容器将会消失
crictl ps
# 备份etcd
mv /var/lib/etcd /var/lib/etcd-bak
# 恢复数据
ETCDCTL_API=3 etcdctl snapshot restore /data/backup/snapshot-etcd-previous.db --data-dir=/var/lib/etcd ...endpoint...ca...cert...key...
# 恢复容器
mv /etc/kubernetes/manifests-bak /etc/kubernetes/manifests
```

### 调整 nodeSelector

```shell
kubectl edit pod nginx-kusc00401
```

添加/修改 `nodeSelector` 字段

```yml
apiVersion: v1
kind: Pod
metadata:
 name: nginx-kusc00401
spec:
 containers:
 - name: nginx
   image: nginx
 nodeSelector:
   disk: ssd
```

### 获取 pod 错误日志

找到 pod bar 的 file-not-found 日志，然后记录到文件

```shell
kubectl logs pod bar |grep "file-not-found" > 1.txt
```

### 节点设置为不可调度

```shell
kubectl drain node1 --ignore-daemonsets
# 可强制 --delete-local-data --force

# 恢复
kubectl uncordon node1
```

### 升级 k8s 集群（1.20.0=>1.20.1）

```bash
# 排空节点
kubectl drain node1 --ignore-daemonsets

# 安装指定的kubeadm
sudo -i
apt install kubeadm=1.20.1-00 –y

kubeadm upgrade plan
kubeadm upgrade apply v1.20.1 --etcd-upgrade=false

# 升级kubelet和kubectl
apt install kubelet=1.20.1-00 kubectl=1.20.1-00 -y
# 重启kubelet
systemctl restart kubelet
# 恢复节点
kubectl uncordon node1
# 验证升级情况
kubectl get nodes
```

### 统计 cpu 最高的 pod

```shell
kubectl top pod -l name=cpu-utilizer --sort-by="cpu" –A
```

### 查看所有 worker 节点，排除不能调度的节点

```bash
kubectl get nodes |grep worker|grep Ready|wc -l
```

## 相关链接

### 查看已有的证书

1. [登录The Linux Foundation](https://sso.linuxfoundation.org/login)
2. [进入My Portal](https://trainingportal.linuxfoundation.org/learn/dashboard/)
3. 查看对应证书的分数, 下载证书
