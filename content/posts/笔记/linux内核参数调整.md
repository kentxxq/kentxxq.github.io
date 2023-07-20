---
title: linux内核参数调整
tags:
  - blog
  - linux
date: 2023-07-01
lastmod: 2023-07-19
categories:
  - blog
description: "这里记录我调整过的 [[linux]] 内核参数."
---

## 简介

这里记录我调整过的 [[笔记/point/linux|linux]] 内核参数.

## 内核参数调整

内核参数的相关配置:

- `/etc/sysctl.conf` : 需要调整的配置文件
- `sysctl -p`: 改了配置后立即生效
- `sysctl -a`: 查看内核参数

复制使用

```shell
# 系统所有的进程能打开的最大文件数 (文件描述符)
# fs.file-max = 9223372036854775807
# 单个进程可以打开的最大文件数
# fs.nr_open = 1048576

# 禁用内存交换
vm.swappiness = 0
# 无法操作的情况下, 进行重启/刷新磁盘
kernel.sysrq = 1
# 一定时间内没收到 arp 广播, 就删除 mac 和 ip 的匹配信息
net.ipv4.neigh.default.gc_stale_time = 120

# 阿里云负载均衡用到 https://help.aliyun.com/knowledge_detail/39428.html
# 关闭源地址验证,防止ip欺骗
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.eth0.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
# 发送arp请求的时候,使用目标ip作为源ip
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2

# see details in https://help.aliyun.com/knowledge_detail/41334.html
# 服务端主动关闭连接后,会处于TIME_WAIT状态,设置可以保留5000等待.默认太大了,会占资源.太小影响复用.
net.ipv4.tcp_max_tw_buckets = 5000
# 安全,导致恶意攻击者无法响应或误判
net.ipv4.tcp_syncookies = 1
# 3次握手等待最后一次响应的时候,这个等待队列的大小
net.ipv4.tcp_max_syn_backlog = 1024
# SYN_RECV状态时重传SYN+ACK包的次数
net.ipv4.tcp_synack_retries = 2
# TCP空闲一段时间后,会较小窗口发送数据,然后再放大窗口. 0代表立即最大窗口发送数据
net.ipv4.tcp_slow_start_after_idle = 0

# 复用TIME-WAIT状态的TCP连接
net.ipv4.tcp_tw_reuse = 1
# 关闭连接以后,内核60秒后释放相关资源
net.ipv4.tcp_fin_timeout = 60
# nat环境下多个机器同一个出口ip,可能会导致tcp连接被丢弃.这里表示响应所有的tcp请求.
net.ipv4.tcp_timestamps = 0
# 3次握手时,会将信息保存到服务器队列里.每个端口的队列有60000个位置
net.core.somaxconn=60000
```
