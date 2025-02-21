---
title: ACME
tags:
  - blog
  - devops
  - ACME
date: 2023-08-16
lastmod: 2024-06-05
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
apt install socat -y
git clone https://github.com/acmesh-official/acme.sh.git
cd ./acme.sh
./acme.sh --install -m 我的邮箱

source ~/.bashrc

# 生成证书
# -k, --keylength 通过长度指定算法 Specifies the domain key length: 2048, 3072, 4096, 8192 or ec-256, ec-384, ec-521.
acme.sh --issue --dns dns_ali -d "*.kentxxq.com" -d "kentxxq.com"

# 安装证书
acme.sh --install-cert \
-d "*.kentxxq.com" -d "kentxxq.com" \
--key-file /usr/local/nginx/conf/ssl/kentxxq.key \
--fullchain-file /usr/local/nginx/conf/ssl/kentxxq.cer \
--reloadcmd "/usr/local/nginx/sbin/nginx -s reload"
```

### 强刷证书

```shell
acme.sh --renew -d "*.kentxxq.com" -d "kentxxq.com" --force --server letsencrypt

acme.sh --renew-all --force
```

### 删除证书

```shell
acme.sh --remove -d "*.kentxxq.com" -d "kentxxq.com" --force
```

### 修改 CA 服务商

- [支持的 CA 服务商列表](https://github.com/acmesh-official/acme.sh/wiki/Server)
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

### 卸载

```shell
acme.sh --uninstall
rm -rf  ~/.acme.sh
```

## `ACME.SH` 问题处理

#### 多个域名,同 dns 服务商,不同 ak

创建多个 `account.conf` 文件, 然后编辑 `crontab`.

假设你有 `a.com`, `b.com`, 而**a.com 和 b.com 都是阿里云提供 dns 解析, 但是需要用到不同的 ak/sk**

操作如下:

1. acme 正常获取 `a.com` 的证书
2. 备份一下 `cp /root/.acme.sh/account.conf /root/.acme.sh/account.conf.bak`
3. acme 正常获取 `b.com` 的证书. 此时 `/root/.acme.sh/account.conf` 的内容变成了 `b.com` 的配置

开始配置:

- `mv /root/.acme.sh/account.conf /root/.acme.sh/account_b.conf` 重命名配置文件，这是 `b.com` 的 ak/sk.
- `mv /root/.acme.sh/account.conf.bak /root/.acme.sh/account.conf` 恢复原来的配置文件，这是 `a.com` 的 ak/sk.
- 开始配置 crontab 定时任务
- 第一条 `crontab记录` 刷新 `a.com` 证书成功, `b.com` 会失败.
- 第二条 `crontab记录` 会发现 `a.com` 证书已经不需要刷新了, 只会刷新 `b.com` 的证书.

```shell
38 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null
4 5 * * * "/root/.acme.sh"/acme.sh --cron --accountconf "/root/.acme.sh/account_b.conf" --home "/root/.acme.sh" > /dev/null
```

#### curl error code

出现 `Please refer to https://curl.haxx.se/libcurl/c/libcurl-errors.html for error code` 这样的错误.

通常是因为不认可 acme-server 的证书.

- 使用 `--insecure` 不检查服务器证书
- 使用 `--use-wget` ,排除是 curl 的问题

#### 修改 reload-cmd

重新运行 `--install-cert` 命令即可覆盖。`sync_nginx.sh` 的内容 [[笔记/shell教程#同步 nginx 配置|在这里]]

```shell
acme.sh --install-cert \
-d "*.kentxxq.com" -d "kentxxq.com" \
--key-file /usr/local/nginx/conf/ssl/kentxxq.key \
--fullchain-file /usr/local/nginx/conf/ssl/kentxxq.cer \
--reloadcmd "/bin/bash /usr/local/bin/sync_nginx.sh"
```

## cert-manager / 不可用

亲测阿里云弄不好... 浪费生命...

```shell
# 安装
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
# 确认启动完成
kubectl get pods --namespace cert-manager
```

部署 [cert-manager-alidns-webhook](https://github.com/DEVmachine-fr/cert-manager-alidns-webhook)

```shell
helm repo add cert-manager-alidns-webhook https://devmachine-fr.github.io/cert-manager-alidns-webhook
helm repo update
helm install alidns-webhook cert-manager-alidns-webhook/alidns-webhook -n cert-manager


kubectl create secret generic alidns-secrets -n cert-manager --from-literal="access-token=yourtoken" --from-literal="secret-key=yoursecretkey"
```

创建资源

```yml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
  namespace: cert-manager
spec:
  acme:
    # Change to your letsencrypt email
    email: kentxxq@qq.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-staging-account-key
    solvers:
      - dns01:
          webhook:
            groupName: acme.yourcompany.com
            solverName: alidns
            config:
              region: ""
              accessKeySecretRef:
                name: alidns-secret
                key: access-key
              secretKeySecretRef:
                name: alidns-secret
                key: secret-key

---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-tls
  namespace: cert-manager
spec:
  secretName: kentxxq-com-tls
  commonName: kentxxq.com
  dnsNames:
    - kentxxxq.com
    - "*.kentxxq.com"
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
```

创建签发工具. `ClusterIssuer` 和 `Issuer` 的区别只有 `ClusterIssuer` 能签发所有命名空间的证书.

相关链接

- 官网安装文档 [kubectl apply - cert-manager Documentation](https://cert-manager.io/docs/installation/kubectl/)
- 腾讯云文档 [容器服务 使用 cert-manager 签发免费证书-最佳实践-文档中心-腾讯云](https://cloud.tencent.com/document/product/457/49368#.E9.85.8D.E7.BD.AE-dns)

## 协议学习

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
