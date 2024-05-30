---
title: linux的初始化
tags:
  - blog
  - linux
date: 2023-07-08
lastmod: 2024-05-29
categories:
  - blog
description: 
---

## 简介

经常会购买/重装 [[笔记/point/linux|linux]] 服务器, 制作过很多次的镜像. 这里记录一下的初始化配置, 以后搞成一个 shell 脚本来用.

## 待添加

#todo/笔记

- Alias
- Truncate 定时清空日志
- Limit 配置

## server 初始化

### 登录

1. [[笔记/linux命令与配置#允许 root 远程登录|允许 root 远程登录]]
2. 允许 root 远程登录后，开始用 tabby 连接操作
3. [[笔记/linux命令与配置#禁用密码登录/密钥登录|禁用密码登录/密钥登录]]

### 执行 shell

开始运行

```shell
#!/bin/bash

ufw disable

apt install selinux-utils policycoreutils ntp ntpdate htop nethogs nload tree lrzsz iotop iptraf-ng zip unzip ca-certificates curl gnupg libpcre3 libpcre3-dev openssl libssl-dev build-essential rsync sshpass -y

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


ntpdate ntp.aliyun.com
hwclock -w
timedatectl set-timezone Asia/Shanghai

apt update -y
apt upgrade -y
```

### 手动配置

[[笔记/linux命令与配置#关闭 selinux|关闭 selinux]]

```shell
vim /etc/selinux/config
SELINUX=disabled
```

时间配置 [[笔记/linux命令与配置#ntp - 原始/容器|ntp - 原始/容器]]

docker 配置 [[笔记/docker镜像源#公共镜像源|docker公共镜像源]]

```shell
vim /etc/docker/daemon.json
# 放入公共镜像源

systemctl daemon-reload
systemctl restart docker
```

配置 nginx [[笔记/nginx编译和升级|nginx编译和升级]] , [[笔记/nginx配置|nginx配置]]

配置 [[笔记/ACME|ACME]]

配置 [[笔记/point/alist|alist]]

配置 [[笔记/自建bitwarden|自建bitwarden]]

部署 testserver, pusher

## homeserver 初始化

[[笔记/树莓派初始化|树莓派初始化]] 也是这里的. 属于小主机.

这里很多的选择, 可以参考 - 思想本的的选择

- originpi zero3 1gb 99 元其实蛮不错的 . 它 orange 的 4 gb 版本 229. 好像是最便宜的了.
- 可以对比一下树莓派. 毕竟树莓派的兼容性是最好的, 而且一直没坏过

- 支持普通电脑的内存长度的小主机?!!

国内硬件扩展最推荐三个个牌子 geekworm 同伴科技，以及 mcuzone 野芯科技，还有 waveshare 微雪电子

- originpi zero3 1gb 99 元其实蛮不错的 . 它 orange 的 4 gb 版本 229. 好像是最便宜的了.
- 可以对比一下树莓派. 毕竟树莓派的兼容性是最好的, 而且一直没坏过
- 支持普通电脑的内存长度的小主机?!!

国内硬件扩展最推荐三个个牌子 geekworm 同伴科技，以及 mcuzone 野芯科技，还有 waveshare 微雪电子

- 群晖 nas 也很稳定. [【群晖DS423+】群晖（Synology）DS423+ 四核心 4盘位 NAS网络存储 文件存储共享 照片自动备份 私有云（无内置硬盘 ）【行情 报价 价格 评测】-京东](https://item.jd.com/100047343428.html) 关注一下内存可以升级到多大. nas 可能又要考虑 ups 的问题, 不然停电对硬盘损害很大. ups 大概 400+, 不是特别贵. 可以监控停电使用 ups 的时候, 手动备份. 关机即可.
- 自建 nas 也是可以的. 倍控有. all-in-boom

路由器透传 nginx 失败?

- DDNS-go
- rclone
- filebrowser

```shell
alias rc-check='rclone check aliyunpan:/  /data/backup/alist-backup  --exclude "video/**" --exclude "iso/**" --exclude "xiaoya/**" --exclude "yuwei/**" -P'
alias rc-copy='rclone copy aliyunpan:/  /data/backup/alist-backup  --exclude "video/**" --exclude "iso/**" --exclude "xiaoya/**" --exclude "yuwei/**" --header "Referer:" -P'

export PATH="/root/rclone/rclone-v1.62.2-linux-arm64:$PATH"
```

RCLONE 同步到本地

```shell
# 挂载到本地
mount -t ntfs-3g /dev/sda1 /data/backup

# 永久挂载 /etc/fstab
/dev/sda1 /data/backup ntfs-3g defaults 0 0

# 下载rclone https://rclone.org/docs/ 解压
# 配置rclone
./rclone config 

# 查看效果config后的效果
./rclone config show
[aliyunpan]
- type: webdav
- url: https://alist.kentxxq.com/dav/
- vendor: other
- user: admin
- pass: *** ENCRYPTED ***

# 检查异同 --max-depth 1 深度
./rclone check aliyunpan:/  /data/backup/alist-backup  --exclude "video/**" --exclude "iso/**"


# copy到本地  -P可以查看进度，适合ui使用
./rclone copy aliyunpan:/  /data/backup/alist-backup  --exclude "video/**" --exclude "iso/**" --header "Referer:" 

# 每晚1点定时
0  1    * * *   root    /root/rclone/rclone-v1.62.2-linux-arm64/rclone copy aliyunpan:/  /data/backup/alist-backup  --exclude "video/**" --exclude "iso/**" --header "Referer:"
```
