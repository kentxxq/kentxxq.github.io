---
title: dns列表
tags:
  - blog
  - dns
date: 2023-07-01
lastmod: 2024-07-26
categories:
  - blog
description: "经常要去网上查, 对比一些 dns 的信息. 记录一下, 以后直接用就行了."
---

## 简介

经常要去网上查, 对比一些 dns 的信息. 记录一下, 以后直接用就行了.

## dns 的配置收集

公司使用默认 dns 即可

个人建议采用阿里 doh + google doh

- 国内解析速度有保证, 也不会超过限速
- 有 dns 兜底

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
更符合中国宝宝
https://8.8.8.8/dns-query

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


## quad9 是一个老牌,非盈利的dns解析
## www.quad9.net
IPv4
9.9.9.9
149.112.112.112
IPv6
2620:fe::fe
2620:fe::9

HTTPS
https://dns.quad9.net/dns-query
TLS
tls://dns.quad9.net
```
