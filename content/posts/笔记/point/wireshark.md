---
title: wireshark
tags:
  - point
  - wireshark
date: 2023-07-17
lastmod: 2023-07-19
categories:
  - point
---

`wireshark` 是一个抓包的工具.

要点:

- 免费
- 用户量大
- 图形化

### 过滤查询

#### IP 和 MAC 地址

```shell
# 原始ip
ip.src == 1.1.1.1
# 目标ip
ip.dst == 1.1.1.1
# 查询往返
ip.addr == 1.1.1.1 || ip.dst == 1.1.1.1

# 源mac
eth.src == A0:00:00:04:C5:84
# 目标mac
eth.dst == A0:00:00:04:C5:84
```

#### 协议

```shell
# http协议
http || http2
# 非http
!http
```

#### 数据参数

```shell
# 显示包含TCP SYN标志的封包
tcp.flags.syn == 0x02

# http请求方法
http.request.method == "GET"
```

#### 组合

```shell
(ip.addr == 1.1.1.1 || ip.dst == 1.1.1.1) && http
```
