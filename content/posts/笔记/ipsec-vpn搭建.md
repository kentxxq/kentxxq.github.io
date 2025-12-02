---
title: ipsec-vpn搭建
tags:
  - blog
  - tools
date: 2024-01-26
lastmod: 2024-07-05
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

如果想要链接 vpn, 相关配置文件如下

```shell
# 容器内的 /etc/ipsec.d 目录用于存放配置文件
docker exec -it ipsec-vpn-server ls -l /etc/ipsec.d

# 示例：将一个客户端配置文件从容器复制到 Docker 主机当前目录
docker cp ipsec-vpn-server:/etc/ipsec.d/vpnclient.p12 ./

# 下面是3个有用的文件
docker cp ipsec-vpn-server:/etc/ipsec.d/vpnclient.mobileconfig ~/vpn/vpnclient.mobileconfig
docker cp ipsec-vpn-server:/etc/ipsec.d/vpnclient.p12 ~/vpn/vpnclient.p12
docker cp ipsec-vpn-server:/etc/ipsec.d/vpnclient.sswan ~/vpn/vpnclient.sswan
```

安装后的提示信息, 用于连接

```shell
server 服务器地址: 14.103.40.xxx
IPsec PSK 预共享密钥: KZUrswNxxxxxxxxx
Username 用户名: vpnuser
Password 密码: y7Thxxxxxxxx
```

## 配置使用

官方配置文档

- [ipsec](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients-zh.md)
    - `windows` 注意事项
        - 管理员 cmd 命令行 `REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f`
        - 第一次配置的话, 重启一下
    - `macos`
        - 选项 tab 菜单中勾选 `通过VPN连接发送所有流量`
        - `机器认证` 选择 `共享密钥`
- [ikev2](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/ikev2-howto-zh.md#android)
    - `ios`
        - 需要用到 `vpnclient.mobileconfig`
    - `android`
        - 需要 `vpnclient.sswan` 以及客户端 **[Google Play](https://play.google.com/store/apps/details?id=org.strongswan.android)**，**[F-Droid](https://f-droid.org/en/packages/org.strongswan.android/)** 或 **[strongSwan 下载网站](https://download.strongswan.org/Android/)**
