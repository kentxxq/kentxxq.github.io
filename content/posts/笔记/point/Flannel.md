---
title: Flannel
tags:
  - point
  - Flannel
date: 2023-11-24
lastmod: 2023-11-24
categories:
  - point
---

## 5.3 Flannel

### 5.3.1 overlay network 介绍

Overlay 网络是指在不改变现有网络基础设施的前提下，通过某种约定通信协议，把二层报文封装在 IP 报文之上的新的数据格式。这样不但能够充分利用成熟的 IP 路由协议进程数据分发；而且在 Overlay 技术中采用扩展的隔离标识位数，能够突破 VLAN 的 4000 数量限制支持高达 16M 的用户，并在必要时可将广播流量转化为组播流量，避免广播数据泛滥。

因此，Overlay 网络实际上是目前最主流的容器跨节点数据传输和路由方案。

### 5.3.2 Flannel 介绍

Flannel 是 CoreOS 团队针对 Kubernetes 设计的一个覆盖网络（Overlay Network）工具，其目的在于帮助每一个使用 Kuberentes 的 CoreOS 主机拥有一个完整的子网。 Flannel 通过给每台宿主机分配一个子网的方式为容器提供虚拟网络，它基于 Linux TUN/TAP，使用 UDP 封装 IP 包来创建 overlay 网络，并借助 etcd 维护网络的分配情况。 Flannel is a simple and easy way to configure a layer 3 network fabric designed for Kubernetes.

### 5.3.3 Flannel 工作原理

Flannel 是 CoreOS 团队针对 Kubernetes 设计的一个网络规划服务，简单来说，它的功能是让集群中的不同节点主机创建的 Docker 容器都具有全集群唯一的虚拟 IP 地址。但在默认的 Docker 配置中，每个 Node 的 Docker 服务会分别负责所在节点容器的 IP 分配。Node 内部的容器之间可以相互访问,但是跨主机 (Node) 网络相互间是不能通信。Flannel 设计目的就是为集群中所有节点重新规划 IP 地址的使用规则，从而使得不同节点上的容器能够获得 " 同属一个内网 " 且 " 不重复的 "IP 地址，并让属于不同节点上的容器能够直接通过内网 IP 通信。 Flannel 使用 etcd 存储配置数据和子网分配信息。flannel 启动之后，后台进程首先检索配置和正在使用的子网列表，然后选择一个可用的子网，然后尝试去注册它。etcd 也存储这个每个主机对应的 ip。flannel 使用 etcd 的 watch 机制监视 `/coreos.com/network/subnets` 下面所有元素的变化信息，并且根据它来维护一个路由表。为了提高性能，flannel 优化了 Universal TAP/TUN 设备，对 TUN 和 UDP 之间的 ip 分片做了代理。 如下原理图：

![[附件/Flannel通信示意图.png]]

```text
1、数据从源容器中发出后，经由所在主机的docker0虚拟网卡转发到flannel0虚拟网卡，这是个P2P的虚拟网卡，flanneld服务监听在网卡的另外一端。
2、Flannel通过Etcd服务维护了一张节点间的路由表，该张表里保存了各个节点主机的子网网段信息。
3、源主机的flanneld服务将原本的数据内容UDP封装后根据自己的路由表投递给目的节点的flanneld服务，数据到达以后被解包，然后直接进入目的节点的flannel0虚拟网卡，然后被转发到目的主机的docker0虚拟网卡，最后就像本机容器通信一样的由docker0路由到达目标容器。
```

## 5.4 ETCD

etcd 是 CoreOS 团队于 2013 年 6 月发起的开源项目，它的目标是构建一个高可用的分布式键值 (key-value) 数据库。etcd 内部采用 `raft` 协议作为一致性算法，etcd 基于 Go 语言实现。

etcd 作为服务发现系统，特点：

- 简单：安装配置简单，而且提供了 HTTP API 进行交互，使用也很简单
- 安全：支持 SSL 证书验证
- 快速：根据官方提供的 benchmark 数据，单实例支持每秒 2k+ 读操作
- 可靠：采用 raft 算法，实现分布式系统数据的可用性和一致性

## 5.5 ETCD 部署

> 主机防火墙及 SELINUX 均关闭。

### 5.5.1 主机名称配置

```powershell
# hostnamectl set-hostname node1
```

```powershell
# hostnamectl set-hostname node2
```

### 5.5.2 主机 IP 地址配置

```powershell
# vim /etc/sysconfig/network-scripts/ifcfg-ens33
# cat /etc/sysconfig/network-scripts/ifcfg-ens33
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
UUID="6c020cf7-4c6e-4276-9aa6-0661670da705"
DEVICE="ens33"
ONBOOT="yes"
IPADDR="192.168.255.154"
PREFIX="24"
GATEWAY="192.168.255.2"
DNS1="119.29.29.29"
```

```powershell
# vim /etc/sysconfig/network-scripts/ifcfg-ens33
# cat /etc/sysconfig/network-scripts/ifcfg-ens33
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="none"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33"
UUID="6c020cf7-4c6e-4276-9aa6-0661670da705"
DEVICE="ens33"
ONBOOT="yes"
IPADDR="192.168.255.155"
PREFIX="24"
GATEWAY="192.168.255.2"
DNS1="119.29.29.29"
```

### 5.5.3 主机名与 IP 地址解析

```powershell
# vim /etc/hosts
[root@node1 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.255.154 node1
192.168.255.155 node2
```

```powershell
# vim /etc/hosts
[root@node2 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.255.154 node1
192.168.255.155 node2
```

### 5.5.4 开启内核转发

> 所有 Docker Host

```powershell
# vim /etc/sysctl.conf
[root@node1 ~]# cat /etc/sysctl.conf
......
net.ipv4.ip_forward=1
```

```powershell
# sysctl -p
```

```powershell
# vim /etc/sysctl.conf
[root@node2 ~]# cat /etc/sysctl.conf
......
net.ipv4.ip_forward=1
```

```powershell
# sysctl -p
```

### 5.5.5 etcd 安装

> etcd 集群

```powershell
[root@node1 ~]# yum -y install etcd
```

```powershell
[root@node2 ~]# yum -y install etcd
```

### 5.5.6 etcd 配置

```powershell
# vim /etc/etcd/etcd.conf
[root@node1 ~]# cat /etc/etcd/etcd.conf
#[Member]
#ETCD_CORS=""
ETCD_DATA_DIR="/var/lib/etcd/node1.etcd"
#ETCD_WAL_DIR=""
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379,http://0.0.0.0:4001"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
ETCD_NAME="node1"
#ETCD_SNAPSHOT_COUNT="100000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
#ETCD_QUOTA_BACKEND_BYTES="0"
#ETCD_MAX_REQUEST_BYTES="1572864"
#ETCD_GRPC_KEEPALIVE_MIN_TIME="5s"
#ETCD_GRPC_KEEPALIVE_INTERVAL="2h0m0s"
#ETCD_GRPC_KEEPALIVE_TIMEOUT="20s"
#
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.255.154:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.255.154:2379,http://192.168.255.155:4001"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#ETCD_DISCOVERY_SRV=""
ETCD_INITIAL_CLUSTER="node1=http://192.168.255.154:2380,node2=http://192.168.255.155:2380"
#ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
#ETCD_INITIAL_CLUSTER_STATE="new"
#ETCD_STRICT_RECONFIG_CHECK="true"
#ETCD_ENABLE_V2="true"
#
#[Proxy]

```

```powershell
# vim /etc/etcd/etcd.conf
[root@node2 ~]# cat /etc/etcd/etcd.conf
#[Member]
#ETCD_CORS=""
ETCD_DATA_DIR="/var/lib/etcd/node2.etcd"
#ETCD_WAL_DIR=""
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379,http://0.0.0.0:4001"
#ETCD_MAX_SNAPSHOTS="5"
#ETCD_MAX_WALS="5"
ETCD_NAME="node2"
#ETCD_SNAPSHOT_COUNT="100000"
#ETCD_HEARTBEAT_INTERVAL="100"
#ETCD_ELECTION_TIMEOUT="1000"
#ETCD_QUOTA_BACKEND_BYTES="0"
#ETCD_MAX_REQUEST_BYTES="1572864"
#ETCD_GRPC_KEEPALIVE_MIN_TIME="5s"
#ETCD_GRPC_KEEPALIVE_INTERVAL="2h0m0s"
#ETCD_GRPC_KEEPALIVE_TIMEOUT="20s"
#
#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.255.155:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.255.155:2379,http://192.168.255.155:4001"
#ETCD_DISCOVERY=""
#ETCD_DISCOVERY_FALLBACK="proxy"
#ETCD_DISCOVERY_PROXY=""
#ETCD_DISCOVERY_SRV=""
ETCD_INITIAL_CLUSTER="node1=http://192.168.255.154:2380,node2=http://192.168.255.155:2380"
#ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
#ETCD_INITIAL_CLUSTER_STATE="new"
#ETCD_STRICT_RECONFIG_CHECK="true"
#ETCD_ENABLE_V2="true"
#
#[Proxy]

```

### 5.5.7 启动 etcd 服务

```powershell
[root@node1 ~]# systemctl enable etcd

[root@node1 ~]# systemctl start etcd
```

```powershell
[root@node2 ~]# systemctl enable etcd

[root@node2 ~]# systemctl start etcd
```

### 5.5.8 检查端口状态

```powershell
# netstat -tnlp | grep -E  "4001|2380"
```

```powershell
输出结果：
tcp6       0      0 :::2380                 :::*                    LISTEN      65318/etcd
tcp6       0      0 :::4001                 :::*                    LISTEN      65318/etcd
```

### 5.5.9 检查 etcd 集群是否健康

```powershell
# etcdctl -C http://192.168.255.154:2379 cluster-health
```

```powershell
输出：
member 5be09658727c5574 is healthy: got healthy result from http://192.168.255.154:2379
member c48e6c7a65e5ca43 is healthy: got healthy result from http://192.168.255.155:2379
cluster is healthy
```

```powershell
# etcdctl member list
```

```powershell
输出：
5be09658727c5574: name=node1 peerURLs=http://192.168.255.154:2380 clientURLs=http://192.168.255.154:2379,http://192.168.255.155:4001 isLeader=true
c48e6c7a65e5ca43: name=node2 peerURLs=http://192.168.255.155:2380 clientURLs=http://192.168.255.155:2379,http://192.168.255.155:4001 isLeader=false
```

## 5.6 Flannel 部署

### 5.6.1 Flannel 安装

```powershell
[root@node1 ~]# yum -y install flannel
```

```powershell
[root@node2 ~]# yum -y install flannel
```

### 5.6.2 修改 Flannel 配置文件

```powershell
[root@node1 ~]# vim /etc/sysconfig/flanneld
[root@node1 ~]# cat /etc/sysconfig/flanneld
# Flanneld configuration options

# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="http://192.168.255.154:2379,http://192.168.255.155:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/atomic.io/network"

# Any additional options that you want to pass
#FLANNEL_OPTIONS=""
FLANNEL_OPTIONS="--logtostderr=false --log_dir=/var/log/ --etcd endpoints=http://192.168.255.154:2379,http://192.168.255.155:2379 --iface=ens33"
```

```powershell
[root@node2 ~]# vim /etc/sysconfig/flanneld
[root@node2 ~]# cat /etc/sysconfig/flanneld
# Flanneld configuration options

# etcd url location.  Point this to the server where etcd runs
FLANNEL_ETCD_ENDPOINTS="http://192.168.255.154:2379,http://192.168.255.155:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
FLANNEL_ETCD_PREFIX="/atomic.io/network"

# Any additional options that you want to pass
#FLANNEL_OPTIONS=""
FLANNEL_OPTIONS="--logtostderr=false --log_dir=/var/log/ --etcd-endpoints=http://192.168.255.154:2379,http://192.168.255.155:2379 --iface=ens33"
```

### 5.6.3 配置 etcd 中关于 flannel 的 key

Flannel 使用 Etcd 进行配置，来保证多个 Flannel 实例之间的配置一致性，所以需要在 etcd 上进行如下配置（**'/[http://atomic.io/network/config](https://link.zhihu.com/?target=http%3A//atomic.io/network/config)**' 这个 key 与上面的/etc/sysconfig/flannel 中的配置项 FLANNEL_ETCD_PREFIX 是相对应的，错误的话启动就会出错）

> 该 ip 网段可以任意设定，随便设定一个网段都可以。容器的 ip 就是根据这个网段进行自动分配的，ip 分配后，容器一般是可以对外联网的（网桥模式，只要 Docker Host 能上网即可。）

```powershell
[root@node1 ~]# etcdctl mk /atomic.io/network/config '{"Network":"172.21.0.0/16"}'
{"Network":"172.21.0.0/16"}
```

或

```powershell
[root@node1 ~]# etcdctl set /atomic.io/network/config '{"Network":"172.21.0.0/16"}'
{"Network":"172.21.0.0/16"}
```

```powershell
[root@node1 ~]# etcdctl get /atomic.io/network/config
{"Network":"172.21.0.0/16"}
```

### 5.6.4 启动 Flannel 服务

```powershell
[root@node1 ~]# systemctl enable flanneld;systemctl start flanneld
```

```powershell
[root@node2 ~]# systemctl enable flanneld;systemctl start flanneld
```

### 5.6.5 查看各 node 中 flannel 产生的配置信息

```powershell
[root@node1 ~]# ls /run/flannel/
docker  subnet.env
[root@node1 ~]# cat /run/flannel/subnet.env
FLANNEL_NETWORK=172.21.0.0/16
FLANNEL_SUBNET=172.21.31.1/24
FLANNEL_MTU=1472
FLANNEL_IPMASQ=false
```

```powershell
[root@node1 ~]# ip a s
......
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:63:d1:9e:0b brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
6: flannel0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1472 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet 172.21.31.0/16 scope global flannel0
       valid_lft forever preferred_lft forever
    inet6 fe80::edfa:d8b0:3351:4126/64 scope link flags 800
       valid_lft forever preferred_lft forever
```

```powershell
[root@node2 ~]# ls /run/flannel/
docker  subnet.env
[root@node2 ~]# cat /run/flannel/subnet.env
FLANNEL_NETWORK=172.21.0.0/16
FLANNEL_SUBNET=172.21.55.1/24
FLANNEL_MTU=1472
FLANNEL_IPMASQ=false
```

```powershell
[root@node2 ~]# ip a s
......
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:e1:16:68:de brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
6: flannel0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1472 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet 172.21.55.0/16 scope global flannel0
       valid_lft forever preferred_lft forever
    inet6 fe80::f895:9b5a:92b1:78aa/64 scope link flags 800
       valid_lft forever preferred_lft forever
```

## 5.7 Docker 网络配置

> --bip=172.21.31.1/24 --ip-masq=true --mtu=1472 放置于启动程序后

```powershell
[root@node1 ~]# vim /usr/lib/systemd/system/docker.service
[root@node1 ~]# cat /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --bip=172.21.31.1/24 --ip-masq=true --mtu=1472
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

```powershell
[root@node2 ~]# vim /usr/lib/systemd/system/docker.service
[root@node2 ~]# cat /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --bip=172.21.55.1/24 --ip-masq=true --mtu=1472
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

```powershell
[root@node1 ~]# systemctl daemon-reload
[root@node1 ~]# systemctl restart docker
```

```powershell
[root@node1 ~]# ip a s
......
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:63:d1:9e:0b brd ff:ff:ff:ff:ff:ff
    inet 172.21.31.1/24 brd 172.21.31.255 scope global docker0
       valid_lft forever preferred_lft forever
6: flannel0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1472 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet 172.21.31.0/16 scope global flannel0
       valid_lft forever preferred_lft forever
    inet6 fe80::edfa:d8b0:3351:4126/64 scope link flags 800
       valid_lft forever preferred_lft forever
```

```powershell
[root@node2 ~]# systemctl daemon-reload
[root@node2 ~]# systemctl restart docker
```

```powershell
[root@node2 ~]# ip a s
......
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default
    link/ether 02:42:e1:16:68:de brd ff:ff:ff:ff:ff:ff
    inet 172.21.55.1/24 brd 172.21.55.255 scope global docker0
       valid_lft forever preferred_lft forever
6: flannel0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1472 qdisc pfifo_fast state UNKNOWN group default qlen 500
    link/none
    inet 172.21.55.0/16 scope global flannel0
       valid_lft forever preferred_lft forever
    inet6 fe80::f895:9b5a:92b1:78aa/64 scope link flags 800
       valid_lft forever preferred_lft forever
```

## 5.8 跨 Docker Host 容器间通信验证

```powershell
[root@node1 ~]# docker run -it --rm busybox:latest

/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:15:1F:02
          inet addr:172.21.31.2  Bcast:172.21.31.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1472  Metric:1
          RX packets:21 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2424 (2.3 KiB)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


/ # ping 172.21.55.2
PING 172.21.55.2 (172.21.55.2): 56 data bytes
64 bytes from 172.21.55.2: seq=0 ttl=60 time=2.141 ms
64 bytes from 172.21.55.2: seq=1 ttl=60 time=1.219 ms
64 bytes from 172.21.55.2: seq=2 ttl=60 time=0.730 ms
^C
--- 172.21.55.2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.730/1.363/2.141 ms
```

```powershell
[root@node2 ~]# docker run -it --rm busybox:latest

/ # ifconfig
eth0      Link encap:Ethernet  HWaddr 02:42:AC:15:37:02
          inet addr:172.21.55.2  Bcast:172.21.55.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1472  Metric:1
          RX packets:19 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:2246 (2.1 KiB)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)


/ # ping 172.21.31.2
PING 172.21.31.2 (172.21.31.2): 56 data bytes
64 bytes from 172.21.31.2: seq=0 ttl=60 time=1.286 ms
64 bytes from 172.21.31.2: seq=1 ttl=60 time=0.552 ms
^C
--- 172.21.31.2 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.552/0.919/1.286 ms

```
