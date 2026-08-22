---
title: iptables
tags:
  - point
  - iptables
date: 2023-08-14
lastmod: 2026-04-02
categories:
  - point
---

`iptables` 可以帮助进行 [[笔记/point/linux|linux]] 的端口限速, 路由转发.

举例:

```
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A OUTPUT -p tcp --sport 444 -m limit --limit 50/s -j ACCEPT
-A OUTPUT -p tcp --sport 444 -j DROP
COMMIT
```

概念

1. filter 最常用，控制是否放行
2. nat 做端口转发，snat，dnat

```shell
# 控制流量入口 -A INPUT
# 协议类型 -p tcp
# 目标端口 --dport 80
# 动作 -j ACCEPT
# 允许通过 tcp 访问本机的 80 端口
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

查询

```shell
# 查看所有链
iptables -L -n -v
# 只看 INPUT 链
iptables -L INPUT -n -v


# 关注 
Chain INPUT
Chain OUTPUT
Chain FORWARD

# 举例，有 10 次允许，600b 流量，允许 tcp 访问 22 端口
Chain INPUT (policy DROP)
 pkts bytes target     prot opt in out source destination
   10   600 ACCEPT     tcp  --  *  *   0.0.0.0/0  0.0.0.0/0  tcp dpt:22
```
