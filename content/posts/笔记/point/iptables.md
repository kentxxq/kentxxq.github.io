---
title: iptables
tags:
  - point
  - iptables
date: 2023-08-14
lastmod: 2023-08-14
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
