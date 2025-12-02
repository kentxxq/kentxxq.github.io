---
title: Rinetd
tags:
  - point
  - Rinetd
date: 2023-12-05
lastmod: 2023-12-05
categories:
  - point
---

## 简介

`Rinetd` 可以帮助转发请求到 [[笔记/point/k8s|k8s]] 的 svc。

场景：很多时候我们用 svc 的 nodeport 或者 loadbalance，很多的组件都使用 clusterip+loadbalance

- 我们在云上之间自建 [[笔记/point/k8s|k8s]] 的时候无法使用 openelb 或者 metaelb，也就不好使用 loadbalance
- 改成 nodeport 又会消耗很多精力和时间

`Rinetd` 做的就是在一个节点上起一个进程 + 端口，把请求转发到 svc 的 clusterip 上面。**方便调试，一条命令映射或关闭相关端口**

## 使用

先下载 [Releases · samhocevar/rinetd](https://github.com/samhocevar/rinetd/releases)，然后 [[笔记/linux命令与配置#c/c++ 项目依赖|装好依赖]] 开始编译

```shell
tar xf rinetd-0.73.tar.gz -C /data/server/
cd /data/server/rinetd-0.73

# 编译安装
./bootstrap 
./configure 
make && make install

whereis rinetd 
# rinetd: /usr/local/sbin/rinetd /usr/local/etc/rinetd.conf
rinetd -v 
# rinetd 0.73

vim /usr/local/etc/rinetd.conf
# bindadress bindport connectaddress connectport options 
# 允许所有外部通过20001访问svc-clusterip的20001端口
0.0.0.0 20001 10.101.87.124 20001

# 启动
rinetd -c /usr/local/etc/rinetd.conf
```

## 守护进程

[[笔记/point/Systemd|Systemd]] 守护进程文件 `/etc/systemd/system/rinetd.service`

```toml 
[Unit]
Description=rinetd
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/sbin/rinetd -c /usr/local/etc/rinetd.conf
ExecReload=/bin/kill -SIGHUP $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID

[Install]
WantedBy=multi-user.target
```
