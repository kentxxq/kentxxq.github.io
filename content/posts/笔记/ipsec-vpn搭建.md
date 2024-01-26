---
title: ipsec-vpn搭建
tags:
  - blog
  - tools
date: 2024-01-26
lastmod: 2024-01-26
categories:
  - blog
description: 
---

## 简介

公司有一个敏感站点，限制了特定的 ip 访问。

可是过年在家，牛马还是要干活的。于是就需要一个可以可以鉴权的服务，进行请求的转发。

常见的就是使用 vpn 连接到某个公网服务器，然后服务器接管流量，转发到特定站点。

## 安装

这里使用 [hwdsl2/setup-ipsec-vpn](https://github.com/hwdsl2/setup-ipsec-vpn) 来快速安装，[docker安装文档在这里](https://github.com/hwdsl2/docker-ipsec-vpn-server/blob/master/README-zh.md)

```shell
# 搞一个配置文件
vim vpn.env
# 预共享密钥
VPN_IPSEC_PSK=secret1111111111111
# vpn用户名
VPN_USER=username
# vpn用户密码
VPN_PASSWORD=password

# 运行
# 注意这里是 udp
docker run \
    --name ipsec-vpn-server \
    --env-file ./vpn.env \
    --restart=always \
    -v ikev2-vpn-data:/etc/ipsec.d \
    -v /lib/modules:/lib/modules:ro \
    -p 500:500/udp \
    -p 4500:4500/udp \
    -d --privileged \
    hwdsl2/ipsec-vpn-server
```

接下来 [配置各客户端](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-zh.md)。如果是安卓 12 以上，又不想下载第三方 App， [必须要配置标识符，所以只能使用IKEv2的方式连接](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto-zh.md#%E4%BD%BF%E7%94%A8%E7%B3%BB%E7%BB%9F%E8%87%AA%E5%B8%A6%E7%9A%84-ikev2-%E5%AE%A2%E6%88%B7%E7%AB%AF)，`IKEv2` 的证书获取方式如下

```shell
# 查看容器内的 /etc/ipsec.d 目录的文件
docker exec -it ipsec-vpn-server ls -l /etc/ipsec.d
# 示例：将一个客户端配置文件从容器复制到 Docker 主机当前目录
docker cp ipsec-vpn-server:/etc/ipsec.d/vpnclient.p12 ./
```
