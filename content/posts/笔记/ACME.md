---
title: ACME
tags:
  - blog
  - devops
  - ACME
date: 2023-08-16
lastmod: 2023-09-02
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
./acme.sh --install -m 我的邮箱@qq.com

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

## 错误处理

#### 多个域名,同 dns 服务商,不同 ak

创建多个 `account.conf` 文件, 然后编辑 `crontab`.

假设你有 `a.com`, `b.com`, `c.om`, 而**a.com 和 b.com 都是阿里云提供 dns 解析, 但是需要用到不同的 ak/sk**

操作如下:

- `/root/.acme.sh/account.conf` 存放着 `a.com`, `c.com` 的 ak/sk.
- `/root/.acme.sh/account_b.conf` 存放着 `b.com` 的 ak/sk.
- 第一条 `crontab记录` 刷新 `a.com`, `c.com` 证书成功, `b.com` 会失败.
- 第二条 `crontab记录` 会发现 `a.com`, `c.com` 证书已经不需要刷新了, 只会刷新 `b.com` 的证书.

```shell
38 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null
4 5 * * * "/root/.acme.sh"/acme.sh --cron --accountconf "/root/.acme.sh/account_b.conf" --home "/root/.acme.sh" > /dev/null
```

#### curl error code

出现 `Please refer to https://curl.haxx.se/libcurl/c/libcurl-errors.html for error code` 这样的错误.

通常是因为不认可 acme-server 的证书.

- 使用 `--insecure` 不检查服务器证书
- 使用 `--use-wget` ,排除是 curl 的问题

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
