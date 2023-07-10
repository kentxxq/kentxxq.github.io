---
title: dns列表
tags:
  - blog
  - dns
date: 2023-07-01
lastmod: 2023-07-01
categories:
  - blog
description: "经常要去网上查, 对比一些 dns 的信息. 记录一下, 以后直接用就行了."
---

## 简介

经常要去网上查, 对比一些 dns 的信息. 记录一下, 以后直接用就行了.

## dns 的配置收集

```shell
## 阿里云 https://www.alidns.com/
223.5.5.5、223.6.6.6、2400:3200::1、2400:3200:baba::1
开手动模板
https://dns.alidns.com/dns-query
DoH/DoT地址: dns.alidns.com


## 谷歌 https://developers.google.com/speed/public-dns/docs/doh
8.8.8.8 / 8.8.4.4
2001:4860:4860::8888
2001:4860:4860::8844
2001:4860:4860:0:0:0:0:8888
2001:4860:4860:0:0:0:0:8844
开自动模板
https://dns.google/dns-query

## 腾讯 https://www.dnspod.cn/Products/publicdns 很全
119.29.29.29
开手动模板
https://doh.pub/dns-query
支持dot，地址是dot.pub

## cloudflare
1.1.1.1
1.0.0.1
2606:4700:4700::1111
2606:4700:4700::1001
https://cloudflare-dns.com/dns-query

## 欧盟的dns
193.110.81.0
185.253.5.0
严格过滤
193.110.81.9
185.253.5.9
儿童版
193.110.81.1
185.253.5.1
```
