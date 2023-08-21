---
title: ACME
tags:
  - blog
  - devops
  - ACME
date: 2023-08-16
lastmod: 2023-08-19
keywords:
  - acme
  - acme.sh
  - ssl
categories:
  - blog
description: "ACME 是一个自动签发 [[笔记/point/ssl|ssl]] 证书的协议. 而 [acme.sh](https://github.com/acmesh-official/acme.sh.git) 是实现了这个协议, 同时对接了多家证书提供商的项目."
---

## 简介

ACME 是一个自动签发 [[笔记/point/ssl|ssl]] 证书的协议.

而 [acme.sh](https://github.com/acmesh-official/acme.sh.git) 是实现了这个协议, 同时对接了多家证书提供商的项目.

## ACME.SH

### 安装使用

配置 [[笔记/point/阿里云|阿里云]] 的密钥对

```bash
export Ali_Key="ak"
export Ali_Secret="sk"
```

开始安装

```shell
# 安装
git clone https://github.com/acmesh-official/acme.sh.git
cd ./acme.sh
./acme.sh --install -m 805429509@qq.com

# 生成证书
acme.sh --issue --dns dns_ali -d "*.kentxxq.com" -d "kentxxq.com" --ecc

# 安装证书
acme.sh --installcert -d "*.kentxxq.com" -d "kentxxq.com" \
--key-file /usr/local/nginx/conf/ssl/kentxxq.key \
--fullchain-file /usr/local/nginx/conf/ssl/kentxxq.cer \
--reloadcmd "/usr/local/nginx/sbin/nginx -s reload"
```

### 强刷证书

```shell
acme.sh --renew -d "*.kentxxq.com" -d "kentxxq.com" --force --server letsencrypt
```

### 删除证书

```shell
acme.sh --remove -d "*.kentxxq.com" -d "kentxxq.com" --force
```

### 修改 CA 服务商

- [支持的CA服务商列表](https://github.com/acmesh-official/acme.sh/wiki/Server)
- [各个服务商的区别](https://github.com/acmesh-official/acme.sh/wiki/CA)

```shell
acme.sh --set-default-ca --server letsencrypt
```

### 定时更新

```shell
# 自动更新acme.sh
acme --upgrade --auto-upgrade
# 自动更新证书
acme.sh --install-cronjob
```

## 协议了解

获取目录 `get https://acme.zerossl.com/v2/DV90`

```json
{
    "newNonce": "https://acme.zerossl.com/v2/DV90/newNonce",
    "newAccount": "https://acme.zerossl.com/v2/DV90/newAccount",
    "newOrder": "https://acme.zerossl.com/v2/DV90/newOrder",
    "revokeCert": "https://acme.zerossl.com/v2/DV90/revokeCert",
    "keyChange": "https://acme.zerossl.com/v2/DV90/keyChange",
    "meta": {
        "termsOfService": "https://secure.trust-provider.com/repository/docs/Legacy/20221001_Certificate_Subscriber_Agreement_v_2_5_click.pdf",
        "website": "https://zerossl.com",
        "caaIdentities": [
            "sectigo.com",
            "trust-provider.com",
            "usertrust.com",
            "comodoca.com",
            "comodo.com"
        ],
        "externalAccountRequired": true
    }
}
```

获取一个随机数 `head https://acme.zerossl.com/v2/DV90/newNonce`

```json
# header
Replay-Nonce aEZTqdlvTqGqAiqPRdaRCXgBon1yJHFbflQ1CpTg_ZE
```
