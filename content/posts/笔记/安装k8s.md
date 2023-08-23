---
title: 安装k8s
tags:
  - blog
  - k8s
date: 2023-08-16
lastmod: 2023-08-23
categories:
  - blog
description: "安装 [[笔记/point/k8s|k8s]] 的记录."
---

## 简介

安装 [[笔记/point/k8s|k8s]] 的记录 -20230606.

## 安装

### 基础环境

```shell
# 主机名和固定ip
hostnamectl set-hostname master1
reboot

# 防火墙
ufw disable

# selinux
vim /etc/selinux/config
SELINUX=disabled

# 时间同步
crontab -e
0 */1 * * * /usr/sbin/ntpdate time1.aliyun.com

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
apt install ipset ipvsadm -y
/etc/modules-load.d/k8s.conf 加入
overlay
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
```

### 容器相关

```shell

# 下载cri-containerd-cni？  https://github.com/containerd/containerd/releases
tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz

# 试试systemctl daemon-reload
# 如果不行就找到它。放到/etc/systemd/system/下面重新daemon-reload
find / -name containerd.service

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
systemdGroup = true
sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9"

systemctl enable containerd
systemctl start containerd


# 开始安装runc
# 安装c编译器和gperf
apt install build-essential gperf -y
# 下载https://github.com/opencontainers/runc/releases libseccomp-2.5.4.tar.gz和runc.amd64
tar xf libseccomp-2.5.4.tar.gz
cd libseccomp-2.5.4/
./configure
make && make install
# 验证
find / -name "libseccomp.so"

chmod +x runc.amd64
把这个runc替换掉containerd的sbin里的runc
install -m 755 runc.amd64 /usr/local/sbin/runc

# 下载https://github.com/containernetworking/plugins/releases
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
```

### 安装 kubeadm

```shell
#  阿里源
curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

apt update -y
apt install -y kubelet kubeadm kubectl -y

systemctl enable kubelet

# 初始化
kubeadm init --image-repository='registry.cn-hangzhou.aliyuncs.com/google_containers' --kubernetes-version=v1.27.2 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.31.221 --cri-socket unix:///var/run/containerd/containerd.sock
```

**可以跳过**, 或使用文件初始化

```yaml
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: abcdef.0123456789abcdef
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.31.221
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: master1
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: 1.27.0
networking:
  dnsDomain: cluster.local
  podSubnet: "10.244.0.0/16"
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
```

### 网络组件

```shell
# calico网络插件
10.244.0.0/16
# https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/tigera-operator.yaml
```

kubectl 下面这个 yml

```yaml
# This section includes base Calico installation configuration.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.Installation
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  # Configures Calico networking.
  calicoNetwork:
    # Note: The ipPools section cannot be modified post-install.
    ipPools:
    - blockSize: 26
      cidr: 10.244.0.0/16
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
---
# This section configures the Calico API server.
# For more information, see: https://projectcalico.docs.tigera.io/master/reference/installation/api#operator.tigera.io/v1.APIServer
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
  name: default
spec: {}
```

启用 ipvs:

```shell
kubectl edit configmap kube-proxy -n kube-system
mode: ipvs
kubectl delete po -n kube-system kube-proxy-xxx
kubectl logs kube-proxy-xxx -n kube-system | grep "Using ipvs Proxier"
```

### Ingress

```shell
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml
```

## 参考链接

- [YouTube安装k8s视频](https://www.youtube.com/watch?v=7k9Rdlx30OY&t=808s)
- [视频中的文档地址](https://www.itsgeekhead.com/tuts/kubernetes-126-ubuntu-2204.txt)
- [ingress官方文档地址](https://kubernetes.github.io/ingress-nginx/deploy/#quick-start)
