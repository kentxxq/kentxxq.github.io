---
title: wakeonlan
tags:
  - point
  - wakeonlan
date: 2023-10-09
lastmod: 2023-10-09
categories:
  - point
---

`wakeonlan` 是 A 机器发送特殊的包到 B 机器的网卡. 网卡触发开启命令.

使用:

```shell
# 安装
apt install wakeonlan -y
# B机器的网卡地址
wakeonlan D8:BB:C1:9D:6B:F1
```
