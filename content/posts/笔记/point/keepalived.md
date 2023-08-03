---
title: keepalived
tags:
  - point
  - keepalived
date: 2023-08-03
lastmod: 2023-08-03
categories:
  - point
---

`keepalived` 是 [[笔记/point/linux|linux]] 下的高可用解决方案. 通过共享 ip, 心跳检测的功能实现网络的高可用.

要点:

- 配置比较简单
- 比较轻量

## 安装

```shell
apt install keepalived -y

# 配置文件
vim /etc/keepalived/keepalived.conf
global_defs {
   router_id node1 # 唯一
}
vrrp_instance VI_1 {
    state MASTER   # 当前节点为高可用从角色,BACKUP为从节点
    interface enp0s3 #你的网卡名字
    virtual_router_id 51 # 必须一致
    priority 100   # 权重,可以为90
    advert_int 1   # 主备通讯时间间隔
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        # 没被使用的ip dev 网卡名字 标签 标签名字
        192.168.31.244 dev enp0s3 label enp0s3:1
    }
}

# 启动
systemctl enable keepalived --now
```

验证

```shell
root@node2:/etc/keepalived# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:7d:18:8a brd ff:ff:ff:ff:ff:ff
    inet 192.168.31.224/24 metric 100 brd 192.168.31.255 scope global dynamic enp0s3
       valid_lft 42367sec preferred_lft 42367sec
    inet 192.168.31.244/32 scope global enp0s3:1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe7d:188a/64 scope link 
       valid_lft forever preferred_lft forever
```
