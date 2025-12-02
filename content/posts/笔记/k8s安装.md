---
title: k8s安装
tags:
  - blog
  - k8s
date: 2023-08-16
lastmod: 2025-11-28
categories:
  - blog
description: "安装 [[笔记/point/k8s|k8s]] 的记录."
---

## 简介

安装 [[笔记/point/k8s|k8s]] 的记录

- 20230606 第一版 1.28
- 20251126 更新到 1.34

## 安装方式对比

![[附件/k8s的传统安装与Pod方式安装.png]]

| 安装方式 | 主要区别                                                            |
| -------- | ------------------------------------------------------------------- |
| 传统方式 | 支撑性软件都是以服务的样式来进行运行，其他的组件以 pod 的方式来运行 |
| Pod 方式 | 除了 kubelet 和容器环境基于服务的方式运行，其他的都以 pod 的方式来运行。<br>所有的 pod 都被 kubelet 以 manifest(配置清单) 的方式进行统一管理。<br>由于这种 pod 是基于节点指定目录下的配置文件统一管理的，所有我们将这些 pod 称为静态 pod                                                                   |

- 传统方式
    - 软件源
    - 二进制
    - ansible 自动化
- pod 方式
    - kubeadm
    - minikube

## 安装路线

目标

- 支持扩展成高可用
- 初期保持最小可用

机器

- master 最低 `4c16g/500g`，因为 `etcd` 等组件会在 master，内存大一点防止初期出现问题
- node 节点 `8c64g/500g`

方式

- 域名解析到 nginx，nginx 作为 etcd 和 api-server 的负载均衡，才能支持后期拓展
	- 负载均衡器后端的 upstream 服务器组中的节点上的请求，不能再经由此负载均衡器调度到后端 upstream 服务器自身（如阿里云就有此限定）
	- metalLB 主要是本地，云厂商不允许这么做。metalLB 是自己配置 ip 地址池，然后分配 vip 给 service
- 采用 pod 方式部署。加入 master 集群的时候自动完成 etcd 集群

## kubeadm 安装

### 基础环境

```shell
# 主机名和固定ip
hostnamectl set-hostname master1
reboot

# 防火墙
ufw disable

# 更新一下
apt update -y
apt upgrade -y

# 相关组件
apt install selinux-utils policycoreutils ntp ntpdate htop nethogs nload tree lrzsz iotop iptraf-ng zip unzip ca-certificates curl gnupg build-essential gperf ipset ipvsadm -y

# selinux
vim /etc/selinux/config
SELINUX=disabled

# 时间同步 https://help.aliyun.com/zh/ecs/user-guide/alibaba-cloud-ntp-server
crontab -e
0 */1 * * * /usr/sbin/ntpdate ntp.aliyun.com

# swap
vim /etc/fstab
# 注释掉swap
# 在命令行再手动关闭一次
swapoff -a

# 内核
vim /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0

# 模块加载
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
# 查看是否加载。出现了就是加载了
lsmod | grep br_netfilter
br_netfilter           22256  0
bridge                151336  1 br_netfilter
lsmod | grep overlay
overlay               151552  0

# 确认为1
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# ipvs相关
# apt install ipset ipvsadm -y
# 加入
vim /etc/modules-load.d/k8s.conf 
overlay
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack

# 重启机器，查看是否生效
lsmod | grep br_netfilter
```

### 容器相关

```shell
# 共享盘，可以忽略
mkdir /mnt/win 
mount -t cifs -o username="Everyone" //192.168.2.100/vm_share /mnt/win
cp /mnt/win/* .

# cri-containerd-cni版本会有问题  https://github.com/containerd/containerd/releases
tar Cxzvf /usr/local containerd-2.2.0-linux-amd64.tar.gz

# 试试systemctl daemon-reload
# 如果不行就找到它。放到/etc/systemd/system/下面重新daemon-reload
find / -name containerd.service
vim /etc/systemd/system/containerd.service

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target
[Service]
#uncomment to enable the experimental sbservice (sandboxed) version of containerd/cri integration
#Environment="ENABLE_CRI_SANDBOXES=sandboxed"
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999
[Install]
WantedBy=multi-user.target

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
vim /etc/containerd/config.toml
# https://github.com/containerd/containerd/issues/4203#issuecomment-651532765
SystemdGroup = true
sandbox = 'registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.10.1'

systemctl enable containerd --now


# 开始安装runc
# 安装c编译器和gperf
# apt install build-essential gperf -y
# 下载https://github.com/opencontainers/runc/releases libseccomp-2.5.6.tar.gz和runc.amd64
tar xf libseccomp-2.5.6.tar.gz
cd libseccomp-2.5.6/
./configure
make && make install
# 验证
find / -name "libseccomp.so"

chmod +x runc.amd64
把这个runc替换掉containerd的sbin里的runc
install -m 755 runc.amd64 /usr/local/sbin/runc

# 下载https://github.com/containernetworking/plugins/releases
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.8.0.tgz
```

### 安装 kubeadm

```shell
# 阿里源,版本 v1.34
curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.34/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.34/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

apt update -y
apt install -y kubelet kubeadm kubectl
# 查看当前支持的具体版本号
kubeadm version -o short

# 这里会发现启动有问题，没关系
systemctl enable kubelet --now
```

### kubeadm 初始化

[kubeadm-init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#init-workflow) 具体做了什么？

- master 节点启动：
    - 当前环境检查，确保当前主机可以部署 kubernetes
        - 检查容器引擎，镜像拉取情况
    - 生成 kubernetes 对外提供服务所需要的各种私钥以及数字证书
        - 证书存放在 `/etc/kubernetes/pki` 的 `*.key *.cer`
    - 生成 kubernetes 控制组件的 kubeconfig 文件
        - 存放在 `/etc/kubernetes` 的 `*.conf`
    - 生成 kubernetes 控制组件的 pod 对象需要的 manifest 文件
        - `/etc/kubernetes/manifests` 下
        - `etcd.yaml`
        - `kube-apiserver.yaml`
        - `kube-controller-manager.yaml`
        - `kube-scheduler.yaml`
    - 为集群控制节点添加相关的标识，不让主节点参与 node 角色工作
        - 输入命令 `kubectl describe nodes master1` 看到 `Taints: node-role.kubernetes.io/master:NoSchedule`
        - 如果没有在 yaml 配置，这可以手动配置 `kubectl taint nodes master1 node-role.kubernetes.io/master:NoSchedule`
    - 生成集群的统一认证的 token 信息，方便其他节点加入到当前的集群
        - `kube-public` 有一个 `configmap` 叫 `cluster-info`，里面存放着 token 等连接信息
    - 进行基于 TLS 的安全引导相关的配置、角色策略、签名请求、自动配置策略
        - kubelet 会使用这个 `/etc/kubernetes/kubelet.conf` 配置文件
    - 为集群安装 DNS 和 kube-porxy 插件
        - `kube-system` 空间下面
        - 如果 cni 网络插件没有弄好，coredns 等几个容器会运行失败
- node 节点加入
    - 当前环境检查，读取相关集群配置信息
        - 容器引擎是否安装，通过 `kubectl -n kube-system get cm kubeadm-config -o yaml` 获取配置
  - 获取集群相关数据后启动 kubelet 服务
      - 证书信息 `/var/lib/kubelet/config.yaml`
      - 启动参数信息 `/var/lib/kubelet/kubeadm-flags.env`
      - 启动
  - 获取认证信息后，基于证书方式进行通信


> [!info]
> 如果网络有问题, 参考 [[笔记/docker镜像源|docker镜像源]] 从国内先拉取镜像再打上 `tag`.
> -  `kubeadm config images list` 查看需要用到的镜像
> -  `kubeadm config images pull` 可以实现拉取镜像



**官方推荐用配置文件来设置 ipvs**

1. 文件初始化 `kubeadm config print init-defaults > config.yml`
2. 修改配置文件
3. `kubeadm init --config config.yml`

```yaml
apiVersion: kubeadm.k8s.io/v1beta4 # 不同版本的api版本不一样
# 节点加入时，认证token授权相关的基本信息。一般在内网比较安全，无需改动
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
# 第一个master节点配置的入口
localAPIEndpoint:
  advertiseAddress: 192.168.6.181 # 第一个master的ip
  bindPort: 6443
# node节点注册到master集群的通信方式
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: master1 # 第一个master的名字
  taints: null
  # taints: 
  #   - effect: NoSchedule
  #     key: node-role.kubernets.io/master
---
# 基本的集群属性信息
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
# 默认没有controlPlaneEndpoint，多个master的时候，这里填keepalived的vip地址
controlPlaneEndpoint: 192.168.6.180:6443
controllerManager: {}
dns: {}
# kubernetes的数据管理方式
etcd:
  local:
    dataDir: /var/lib/etcd
# 镜像仓库的配置
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
kind: ClusterConfiguration
# kubernetes版本的定制
kubernetesVersion: 1.34.0
# kubernetes的网络基本信息
networking:
  dnsDomain: cluster.local
  serviceSubnet: "10.96.0.0/12"
  podSubnet: "10.244.0.0/16"
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
```

**建议用上面的配置文件初始化**。下面的命令行初始化当做参考:

```shell
# 初始化
kubeadm init --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers' \
--kubernetes-version=v1.34.2 \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16 \
--apiserver-advertise-address=192.168.2.180 \
--cri-socket unix:///var/run/containerd/containerd.sock
```

设置 config

```shell
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 这里 NotReady 是正常的
kubectl get nodes
NAME      STATUS     ROLES           AGE     VERSION
master1   NotReady   control-plane   2m31s   v1.34.2
```

### 网络组件 calico

步骤都来自于 [calico 官方文档](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)

 安装 operator

```shell
# 可以下载下来，修改里面的 image   quay.dockerproxy.net
# https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
kubectl create -f https://gh-proxy.org/https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/tigera-operator.yaml
```

安装 custom resources。下载 [yaml](https://raw.githubusercontent.com/projectcalico/calico/v3.31.2/manifests/custom-resources.yaml) 只需要修改 cidr 为 `10.244.0.0/16`

```shell
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    ipPools:
      - name: default-ipv4-ippool
        blockSize: 26
        # calico网络插件网段
        # 这里应该和kubeadm init --pod-network-cidr=10.244.0.0/16 一致!!!
        # 修改 cidr 为 10.244.0.0/16
        cidr: 10.244.0.0/16
        encapsulation: VXLANCrossSubnet
        natOutgoing: Enabled
        nodeSelector: all()

---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}

---
apiVersion: operator.tigera.io/v1
kind: Goldmane
metadata:
  name: default

---
apiVersion: operator.tigera.io/v1
kind: Whisker
metadata:
  name: default
```

验证安装情况

```shell
# available/progressiing 都要是 true
# 通常是镜像问题，弄到私有镜像仓库即可
kubectl get tigerastatus
```

启用 ipvs:

```shell
kubectl edit configmap kube-proxy -n kube-system
mode: ipvs

kubectl rollout restart daemonset kube-proxy -n kube-system
# 或者一个一个来 kubectl delete po -n kube-system kube-proxy-xxx

# 验证使用了ipvs
kubectl logs kube-proxy-xxx -n kube-system | grep "Using ipvs Proxier"
# 新建service应该会有日志出现
kubectl logs -f -n kube-system -l k8s-app=kube-proxy

# ipvsadm可以帮助我们查看规则
apt install ipvsadm -y
# 查看所有规则
ipvsadm -Ln
# 出来的记录指向多个ip，正好就是service的endpoint里面的ip
ipvsadm -Ln | egrep -A2 'service的cluster-ip'
```

验证安装情况:

```shell
# 每个节点都会有一个 pod/calico-node 处于 running 状态
kubectl get all -A -o wide |grep calico
```

### Ingress

[参考官方文档](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start)

1. 下载 yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.0/deploy/static/provider/cloud/deploy.yaml
2. 修改里面的 image 地址
3. apply 部署。默认单节点 master 有污点，所以不会正常启动

## kubeadm 管理操作

### 节点重置/扩缩容

1. 冻结节点
2. 驱离现有资源
3. 删除节点
4. 清理环境
5. 清理遗留信息
6. 重启主机

```shell
# 冻结
kubectl cordon xxxx-node

# 驱离
# 会先让apiserver删除pod，然后被replicateSet发现后，写入新信息到etcd。然后etcd
kubectl drain xxx-node --force=true --ignore-daemonsets=true --delete-emptydir-data=true

# 删除节点
kubectl delete nodes xxx-node

# 在被移除节点上操作
kubeadm reset

# 清理资源
rm -rf /etc/cni/net.d/*
# master节点要删除 ~/.kube

# 可以跳过，直接到重启部分
tree /etc/kubernetes # 如果有文件就清理
# 重启一下
systemctl restart kubelet docker
# 如果有网络组件，应该清理掉
ifconfig
# 手动关闭网卡，如果是calico也使用一样的方法清理掉
ifconfig flannel.1 down
# 清理ip route
ip route list
ip route del 192.168.1.0/24
# 刷新缓存
ip route flush cache

# 重启一下
reboot

# 重新加入
kubeadm join ...
```

### 生成加入集群的命令

```shell
# 这是node节点的加入命令
kubeadm token create --print-join-command
```

### 加入新的 master 节点

第一台 master 的 kubeadm 初始化后：

1. `kubeadm init phase upload-certs --upload-certs` 得到 key
2. `kubeadm join ... --control-plane --certificate-key {上面的key}`

### 升级集群

1. 确定 [[笔记/point/k8s|k8s]] 的版本一致
    - kubeadm version
    - kubectl version
    - kubectl get nodes
2. 升级 kubeadm 的版本
3. 升级
    - kubeadm upgrade plan
    - kubeadm upgrade apply v 1.28.4
4. 升级 kubectl，kubelet 版本
    - systemctl daemon-reload
    - systemctl restart kubelet
5. 升级 worker 节点
    - kubectl drain worker-node --ignore-daemonsets
    - 升级 kubelet 版本
    - systemctl daemon-reload
    - systemctl restart kubelet
    - kubectl uncordon  worker-node
6. 重复第一步来验证升级

> 升级完成 kubeadm 后，可以 `kubeadm config images pull` 来提前拉取镜像

## 可选组件

先安装 [[helm手册#安装]]

### csi-driver-nfs

[[linux命令与配置#nfs|先搭建一个 nfs]], 然后 [csi-driver-nfs文档](https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/charts/README.md) 操作

1. 添加 repo `helm repo add csi-driver-nfs https://gh-proxy.com/https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts`
2. 查看支持的版本 `helm search repo -l csi-driver-nfs`
3. 生成 values 文件 `helm show values csi-driver-nfs/csi-driver-nfs --namespace kube-system --version 4.12.1 > nfs-values.yaml`
4. 修改 values 镜像
5. 部署 `helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version 4.12.1 -f nfs-values.yaml`
6. 检查 DaemonSet `csi-nfs-node` 和 Deployment `csi-nfs-controller` 是否启动成功

配置使用

1. 查看 `provisioner` 的名称 `kubectl get csidrivers`
2. 配置 StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs184
provisioner: nfs.csi.k8s.io
parameters:
  server: 192.168.6.184
  share: /data/nfs  # 必须和nfs的exports路径保持一致
  reclaimPolicy: Delete  # pvc 删除后哦，pv 自动删除
  volumeBindingMode: Immediate  # 创建 pvc 后立即创建 pv
```

### cert-manager

### dashboard

1. 关掉内置的 ingress 和 charts
2. 安装部署
3. 配置 ingress 转发

## kubekey 安装（不再使用）

- 对于学习而言。要么用 kubeadm 学习全套，要么 [[k3d教程|k3d]]，[[minikube教程|minikube]] 极简
- 社区版需要提交信息申请授权，授权还有时限。哪天收费了你咋弄？
- `less is more` 做减法，做选型，少折腾各种路线

### 基础准备

```bash
# 关闭防火墙
systemctl disable firewalld

# 关闭swap
swapon --show
# 在 /etc/sysctl.conf 中添加 vm.swappiness=0
echo "vm.swappiness=0" >> /etc/sysctl.conf
# 如果有内容，那么去 /etc/fstab 注释掉下面的东西
#/swap.img	none	swap	sw	0	0
# 重启电脑验证
swapon --show

# 关闭selinux
apt install selinux-utils
# 查看输出
getenforce

# 安装依赖
apt install socat conntrack ebtables ipset -y
```

### 安装

```shell
# 安装kubekey工具  
export KKZONE=cn  
curl -sfL https://get-kk.kubesphere.io | VERSION=v1.2.1 sh -  
chmod +x kk  
  
# 创建配置  
./kk create config  
# 编辑配置文件  
vim config-sample.yaml  
  
# 开始安装  
./kk create cluster -f config-sample.yaml --with-kubesphere  
# 确定没问题就yes 
  
# 如果上面没有--with-kubesphere，手动安装的话  
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.2.1/kubesphere-installer.yaml  
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.2.1/cluster-configuration.yaml  
# 检查安装日志  
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f  
# 验证所有pod都起来了  
kubectl get pod --all-namespaces  
# 检查控制台端口，默认30880  
kubectl get svc/ks-console -n kubesphere-system  
# 访问nodeport   
ip:30880 admin/P@88w0rd
```

### 集群管理

```shell
# 从集群创建配置文件
./kk create config --from-cluster
# 或
./kk create config -f kubeconfig配置文件

# 添加节点
# 编辑配置
./kk add nodes -f sample.yaml

# 删除节点
# 界面停止调度
# 编辑配置
./kk delete node <nodeName> -f config-sample.yaml
```

### 配置文件 demo

```yml
apiVersion: kubekey.kubesphere.io/v1alpha1
kind: Cluster
metadata:
  name: sample
spec:
  hosts:
  - {name: master, address: 192.168.10.71, internalAddress: 192.168.10.71, user: root, password: 密码}
  - {name: node1, address: 192.168.10.72, internalAddress: 192.168.10.72, user: root, password: 密码}
  - {name: node2, address: 192.168.10.73, internalAddress: 192.168.10.73, user: root, password: 密码}
  roleGroups:
    etcd:
    - master
    master:
    - master
    worker:
    - node1
    - node2
  controlPlaneEndpoint:
    ##Internal loadbalancer for apiservers
    #internalLoadbalancer: haproxy

    domain: lb.kubesphere.local
    address: ""
    port: 6443
  kubernetes:
    version: v1.21.5
    clusterName: cluster.local
  network:
    plugin: calico
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
  registry:
    registryMirrors: ["https://u7hlore1.mirror.aliyuncs.com"]
    insecureRegistries: []
    privateRegistry: ""
  addons: []
```

## 参考链接

- 去操作集群吧 [[k8s常用命令和配置]]
- [kubeadm-YouTube安装k8s视频](https://www.youtube.com/watch?v=7k9Rdlx30OY&t=808s)，[kubeadm-视频中的文档地址](https://www.itsgeekhead.com/tuts/kubernetes-126-ubuntu-2204.txt)
- [kubekey-多节点安装 (kubesphere.io)](https://www.kubesphere.io/zh/docs/v3.3/installing-on-linux/introduction/multioverview/)
- [ingress官方文档地址](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start)
