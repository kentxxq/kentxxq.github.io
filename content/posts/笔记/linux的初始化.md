---
title: linux的初始化
tags:
  - blog
  - linux
date: 2023-07-08
lastmod: 2023-10-16
categories:
  - blog
description: 
---

## 简介

经常会购买/重装 [[笔记/point/linux|linux]] 服务器, 制作过很多次的镜像. 这里记录一下的初始化配置, 以后搞成一个 shell 脚本来用.

## 操作手册

- 时间同步
- 防火墙关闭
- Selinux 关闭
- Supervisor 安装和默认配置
- Alias
- Htop, nethogs, lrzsz, tree, nload, iotop, vmstat, iptraf-ng, zip, unzip 等等命令
- Truncate 定时清空日志
- Docker 镜像?
- Limit 配置

因为已经有了 linux 命令和其他工具的文档, 这里只要记录一下必要的点, 然后写成一个 shell 脚本就好了. #todo/笔记

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
