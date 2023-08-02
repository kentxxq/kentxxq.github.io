---
title: Containerd教程
tags:
  - blog
  - containerd
date: 2023-08-02
lastmod: 2023-08-02
categories:
  - blog
description: "[[笔记/point/Containerd|Containerd]] 的操作配置."
---

## 简介

[[笔记/point/Containerd|Containerd]] 的操作配置.

## 内容

### 安装

#### Containerd

到 [官方仓库release](https://github.com/containerd/containerd/releases) 下载二进制包, 并解压.

- `containerd`: 包含 `containerd` 和 `ctr`.
  配合 `tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz` 使用, 解压到 `/usr/local` 内.
- `cri-containerd`: 上面的 + `runc`
  配合
- `cri-containerd-cni`: 上面的 + `cni` 的 `host-device,macvlan等等`
- `containerd-static` 应该是静态库链接用的.

```shell
# containerd使用
# 解压到/usr/local
tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz

# cri-containerd-cni
# 解压到/
tar Cxzvf / cri-containerd-1.6.2-linux-amd64.tar.gz
```

[[笔记/point/Systemd|Systemd]] 守护配置路径 `/etc/systemd/system/containerd.service`

```ini
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```

加载配置, 开机启动

```shell
systemctl daemon-reload
systemctl enable containerd --now
```
