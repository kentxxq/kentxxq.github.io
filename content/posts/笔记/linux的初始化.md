---
title: linux的初始化
tags:
  - blog
  - linux
date: 2023-07-08
lastmod: 2023-12-16
categories:
  - blog
description: 
---

## 简介

经常会购买/重装 [[笔记/point/linux|linux]] 服务器, 制作过很多次的镜像. 这里记录一下的初始化配置, 以后搞成一个 shell 脚本来用.

## 操作手册

#todo/笔记

- Alias
- Truncate 定时清空日志
- Limit 配置

## 虚拟机初始化

安装配置 [清华源](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/) `https://mirrors.tuna.tsinghua.edu.cn/ubuntu/`

允许 root 远程登录后，开始用 tabby 连接操作

```shell
vim /etc/ssh/sshd_config
PermitRootLogin yes

passwd root
systemctl restart ssh
```

开始运行

```shell
#!/bin/bash

ufw disable

apt install selinux-utils policycoreutils ntp ntpdate htop nethogs nload tree lrzsz iotop iptraf-ng zip unzip ca-certificates curl gnupg libpcre3 libpcre3-dev openssl libssl-dev build-essential -y -y

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







# 需要手动
apt update -y
apt upgrade -y

vim /etc/selinux/config
SELINUX=disabled

crontab -e
0 * * * * /usr/sbin/ntpdate ntp.aliyun.com

vim /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
systemctl daemon-reload
systemctl restart docker
```

## Home-server 初始化

- DDNS-go
- rclone
- filebrowser

```shell
alias rc-check='rclone check aliyunpan:/  /data/backup/alist-backup  --exclude "video/**" --exclude "iso/**" -P'
alias rc-copy='rclone copy aliyunpan:/  /data/backup/alist-backup  --exclude "video/**" --exclude "iso/**" --header "Referer:" -P'

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
