---
title: etcd手册
tags:
  - blog
date: 2025-04-27
lastmod: 2025-05-08
categories:
  - blog
description: 
---

## 简介

[etcd](https://etcd.io/) 我个人理解是一个类似于 [[笔记/point/redis|redis]] 的产品, 特点如下

- 键值对存储
- 分布式, 搭建集群比较简单
- [[笔记/point/golang|golang]] 写的, 内至于 [[笔记/point/k8s|k8s]]

## 安装

[etcd官方cluster安装文档](https://etcd.io/docs/v3.5/op-guide/clustering/) 流程如下, 全程在 `/root` 目录 `root` 用户执行

- 文件准备
    - [Releases下载二进制文件](https://github.com/etcd-io/etcd/releases/)
    - 拷贝到服务器解压

```shell
tar xf etcd-v3.5.18-linux-amd64.tar.gz
cd etcd-v3.5.18-linux-amd64/
mv etcd /usr/local/bin/etcd
chmod +x /usr/local/bin/etcd
# 验证
etcd --version
```

- 初始化命令说明
    - 下面的命令做少量修改后, 在每个机器都要执行
    - 这里节点为 `etcd3`, 代表 etcd 集群的 3 号节点, ip 是 `172.16.0.78`
    - 所有地方都必须填 ip ! 不支持 hosts 文件名称
    - `initial-cluster-token` 是集群 token, 每个节点这个值都是一致的
    - `initial-cluster` 填上每个节点的 ip
    - `initial-cluster-state` 为 `new` 代表新建集群, 后续添加新节点这里不一样

```shell
etcd --name etcd3 \
--initial-advertise-peer-urls http://172.16.0.78:2380   \
--listen-peer-urls http://172.16.0.78:2380   \
--listen-client-urls http://172.16.0.78:2379,http://127.0.0.1:2379   \
--advertise-client-urls http://172.16.0.78:2379   \
--initial-cluster-token etcd-cluster-1   \
--initial-cluster etcd1=http://172.16.0.79:2380,etcd2=http://172.16.1.8:2380,etcd3=http://172.16.0.78:2380   \
--initial-cluster-state new
```

守护进程 `vim /etc/systemd/system/etcd.service`.

>  这里 `--auto-compaction-retention 24h` 是一个大坑, 如果不配置默认不会清理历史版本, 很容易会到达默认的 `2GB` 限制导致集群故障. 参考 [文章](https://pigsty.cc/blog/db/bad-etcd/) 和 [影视飓风达芬奇千万级数据库演化及实践 - 墨天轮](https://www.modb.pro/db/1919578191405002752)

```toml
[Unit]
Description=测试服务
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
# 环境变量 $MY_ENV1
# Environment=MY_ENV1=value1
# Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
# EnvironmentFile=/path/to/environment/file1

WorkingDirectory=/root/etcd-v3.5.18-linux-amd64
ExecStart=/usr/local/bin/etcd --name etcd3 --initial-advertise-peer-urls http://172.16.0.78:2380 \
  --auto-compaction-retention 24h \
  --listen-peer-urls http://172.16.0.78:2380 \
  --listen-client-urls http://172.16.0.78:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://172.16.0.78:2379 
# 总是间隔30s重启,配合StartLimitIntervalSec实现无限重启
RestartSec=30s
Restart=always
# 相关资源都发送term后,后发送kill
KillMode=mixed
# 最大文件打开数不限制
LimitNOFILE=infinity
# 子线程数量不限制
TasksMax=infinity

[Install]
WantedBy=multi-user.target
```

## 添加新节点

除了 ip 信息, 只有 `--initial-cluster-state existing` 和新建集群的时候不同

```shell
/usr/local/bin/etcd --name etcd4 --initial-advertise-peer-urls http://172.16.1.9:2380   --listen-peer-urls http://172.16.1.9:2380   --listen-client-urls http://172.16.1.9:2379,http://127.0.0.1:2379   --advertise-client-urls http://172.16.1.9:2379   --initial-cluster-token etcd-cluster-1   --initial-cluster etcd1=http://172.16.0.79:2380,etcd2=http://172.16.1.8:2380,etcd3=http://172.16.0.78:2380,etcd4=http://172.16.1.9:2380 --initial-cluster-state existing
```

## 备份/恢复

备份

```shell
etcdctl --endpoints=http://172.16.0.79:2379 snapshot save /tmp/etcd-backup.db
```

恢复

- 恢复顺序: 先停止 etcd 集群, 然后恢复, scp 覆盖掉其他节点的数据目录, 启动集群
- 每个机器的数据目录根据节点名称变化, `etcd3` 节点数据目录是 `/root/etcd-v3.5.18-linux-amd64/etcd3.etcd`
- `initial-cluster` 填写所有节点的信息

```shell
systemctl stop etcd

etcdctl --endpoints=http://172.16.0.78:2379 snapshot restore /tmp/etcd-backup.db \
--data-dir=/root/etcd-v3.5.18-linux-amd64/etcd3.etcd
--name=etcd3
--initial-cluster etcd1=http://172.16.0.79:2380,etcd2=http://172.16.1.8:2380,etcd3=http://172.16.0.78:2380 \
--initial-advertise-peer-urls http://172.16.0.78:2380 \
--initial-cluster-token etcd-cluster-1
```
