---
title: keepalived
tags:
  - point
  - keepalived
date: 2023-08-03
lastmod: 2023-08-08
categories:
  - point
---

`keepalived` 是 [[笔记/point/linux|linux]] 下的高可用解决方案. 通过共享 ip, 心跳检测的功能实现网络的高可用.

要点:

- 虚拟 ip 自动在节点间流转
- 配置比较简单
- 比较轻量

## 安装

### 主节点配置

```shell
apt install keepalived -y

# 配置文件
vim /etc/keepalived/keepalived.conf
global_defs {
   router_id ha1 # ha集群内唯一
   enable_script_security # 允许执行脚本
   script_user root # 指定执行脚本的用户
}

vrrp_script check_health {
    script "/usr/bin/systemctl is-active nginx" # 检测nginx状态
    interval 2 # 间隔时间
    weight -100 # 失败后降低权重,成功的话会恢复
}

vrrp_instance VI_1 {
    state MASTER   # 主节点
    interface enp0s3 #你的网卡名字
    virtual_router_id 51 # ha集群内必须一致
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

    track_script {
        check_health
    }
}

# 启动
systemctl enable keepalived --now
```

### 备份节点配置

```shell
vim /etc/keepalived/keepalived.conf
global_defs {
   router_id ha2 # ha集群内唯一
   enable_script_security # 允许执行脚本
   script_user root # 指定执行脚本的用户
}

vrrp_script check_health {
    script "/usr/bin/systemctl is-active nginx" # 检测nginx状态
    interval 2 # 间隔时间
    weight -100 # 失败后降低权重,成功的话会恢复
}

vrrp_instance VI_1 {
    state BACKUP   # 当前节点为高可用从角色,BACKUP为从节点
    interface enp0s3 #你的网卡名字
    virtual_router_id 51 # ha集群内必须一致
    priority 90   # 权重,可以为90
    advert_int 1   # 主备通讯时间间隔
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        # 没被使用的ip dev 网卡名字 标签 标签名字
        192.168.31.244 dev enp0s3 label enp0s3:1
    }
    
    track_script {
        check_health
    }
}
```

### 验证

在 `node1` 查询会发现 `192.168.31.244/32 scope global enp0s3:1`

```shell
root@node1:/etc/keepalived# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:7d:18:8a brd ff:ff:ff:ff:ff:ff
    inet 192.168.31.210/24 metric 100 brd 192.168.31.255 scope global dynamic enp0s3
       valid_lft 42367sec preferred_lft 42367sec
    inet 192.168.31.244/32 scope global enp0s3:1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe7d:188a/64 scope link 
       valid_lft forever preferred_lft forever
```

关闭 `node1` 的 `keepalived` 服务 `systemctl stop keepalived`. `node2` 同样会出现 `192.168.31.244/32 scope global enp0s3:1`.

在第三方机器上先 `ping` 一下 3 个主机拿到 `mac` 地址, 然后使用 `arp -a` 命令查询.

```powershell
# 一旦我们关闭node1的keepalived服务,192.168.31.244将会指向node2的mac地址
arp -a
node1  192.168.31.210        08-00-27-4d-3b-7e     动态
node2  192.168.31.211        08-00-27-7d-18-8a     动态
vip    192.168.31.244        08-00-27-4d-3b-7e     动态
```

## 阿里云配置

参考 [阿里云支持HaVip](https://help.aliyun.com/zh/vpc/user-guide/overview-9) 和 [如何使用HaVip和keepalived搭建主备双机实现业务高可用](https://help.aliyun.com/zh/vpc/user-guide/implement-high-availability-by-using-havips-and-keepalived?spm=a2c4g.11186623.0.0.46563d30hSci7l)

- 不支持广播和组播. 需要配置单播通信.

配置如下:

```shell
global_defs {
   router_id node1 # ha集群内唯一
   enable_script_security # 允许执行脚本
   script_user root # 指定执行脚本的用户
}

vrrp_script check_health {
    script "/usr/bin/systemctl is-active nginx" # 检测nginx状态
    interval 2 # 间隔时间
    weight -100 # 失败后降低权重,成功的话会恢复
}

vrrp_instance VI_1 {
    state MASTER   # 主节点
    interface eth0 # 你的网卡名字
    virtual_router_id 51 # 必须一致
    priority 100   # 权重,可以为90
    advert_int 1   # 主备通讯时间间隔
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        # 没被使用的ip dev 网卡名字 标签 标签名字
        192.168.31.244 dev eth0 label eth0:1
    }

    unicast_src_ip 192.168.31.210   # 设置本机ECS实例的私网IP地址
    unicast_peer {
        192.168.31.211  # 对端ECS实例的私网IP地址
    }
    track_interface {
        eth0  # 设置ECS实例网卡名
    }
    track_script {
        check_health
    }
}
```
