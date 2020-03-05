---
title:  centos的日常操作和问题记录
date:   2020-03-05 16:10:00 +0800
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","yum","bbr","mount"]
description: "现在操作centos时间是越来越多，遇到的问题也是越来越多。做一个记录贴吧"
---


> 现在操作centos时间是越来越多，遇到的问题也是越来越多。做一个记录贴吧，准备长时间更新。

## 日常操作

### 开启bbr

bbr是一种浪费网络资源，提升网络速度和稳定性的通讯手段。

centos8默认内核4.18，不用升级内核，即可启动。否则需要用升级内核。

```bash
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
# 生效
sysctl -p
# 验证
lsmod | grep bbr
```

### 使用yum镜像源

```bash
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```


## 问题记录

### 无法挂载远程目录

```bash
sudo mount -t nfs -o nolock,nfsvers=3,vers=3 -o proto=tcp 1.1.1.1:/mnt/package /package/
```

#### 报错

mount: 文件系统类型错误、选项错误、172.16.68.153:/mnt/package 上有坏超级块、缺少代码页或助手程序，或其他错误(对某些文件系统(如 nfs、cifs) 您可能需要一款 /sbin/mount.<类型> 助手程序)。有些情况下在 syslog 中可以找到一些有用信息- 请尝试dmesg | tail  这样的命令看看。

#### 修复

```bash
sudo yum -y install nfs-utils
```

## 更新记录

**20200305**: 开篇