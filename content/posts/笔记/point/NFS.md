---
title: NFS
tags:
  - point
  - 未命名
date: 2023-11-17
lastmod: 2023-11-20
categories:
  - point
---

快速搭建：

```shell
apt install nfs-kernel-server -y

mkdir -p /data/nfs
vim /etc/exports

/data/nfs  *(rw,sync,no_root_squash,no_subtree_check)
# *：允许所有的网段访问，也可以使用具体的IP
# rw：挂接此目录的客户端对该共享目录具有读写权限
# sync：资料同步写入内存和硬盘
# no_root_squash：root用户具有对根目录的完全管理访问权限
# no_subtree_check：不检查父目录的权限




# 修改完成后重新加载配置. 如果服务启动了,修改配置就用这个
# exportfs -r 

# 启动nfs服务
systemctl enable nfs-kernel-server --now

# 检查验证
showmount -e
Export list for om1:
/data/nfs *
```

挂载：

```shell
apt install nfs-common -y
# 挂载 服务器ip:/exports配置的路径 本地路径
mount 10.0.1.157:/data/nfs /data/nfs
# 卸载
umount /data/nfs
```
