---
title: PVE手册
tags:
  - blog
  - pve
date: 2025-11-25
lastmod: 2025-11-25
categories:
  - blog
description:
---

## 简介

公司老服务器需要重装，我以前都是用的 windows 玩虚拟机，这次把 esxi 和 pve 考虑了进来。

esxi 9 似乎停止了免费版本的发放，现在用这个怕被坑。windows 以前都是个人用，现在商用不太好。所以决定用 pve 来试试，而且早有耳闻 pve 很强，以后家庭服务器也用得上。

## 安装

1. 制作 ventoy 盘，放入 pve 镜像。如果只有 mac 设备， [[macos问题处理#制作启动盘|用命令制作启动盘]]
2. 图形化安装
	- 网络设置
		1. hostname(FQDN)   `pve239.kentxxq`
		2. ip 地址 `192.168.6.239/24`
		3. 网关 `192.168.6.1`
3. 登录 `192.168.6.239:8086`，确保正常
4. 更换源（默认有 vi 没有 vim ）
	1. `pve-no-subscription.list` [proxmox | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/help/proxmox/)
	2. `debian.sources`  [debian | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/help/debian/)
	3. 移除企业源 `mv /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d/pve-enterprise.sources.bak`
	4. 配置 ceph 源 `/etc/apt/sources.list.d/ceph.sources`
		- `Types: deb`
		- `URIs: https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian/ceph-squid`
		- `Suites: trixie`
		- `Components: no-subscription`
		- `Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg`
5. 使用社区脚本，关闭 ha，关闭订阅提醒 [community-scripts/ProxmoxVE: Proxmox VE Helper-Scripts (Community Edition)](https://github.com/community-scripts/ProxmoxVE/)
6. `apt update -y; apt upgrade -y;`

## 使用概念

### 网络

默认有一个 `localnetwork` ，是 bridge 桥接模型

### 磁盘

- 服务器硬件 raid 5 + 全局热备盘。可以通过 [[dell服务器手册#perccli]] 来操作管理服务器磁盘
- `local` 存放 iso 镜像
- `local-lvm`
	- `LVM_Thin`，支持 COW 快速快照
	- 存放虚机实例
