---
title:  linux问题记录
date:   2020-06-09 23:53:00+08:00
categories: ["笔记"]
tags: ["linux"]
keywords: ["linux","selinux","nfs-utils","报错","问题"]
description: "现在操作linux的时间是越来越多，遇到的问题也是越来越多。做一个记录贴吧"
---


> 现在操作linux的时间是越来越多，遇到的问题也是越来越多。做一个记录贴吧。

## 问题记录

### 服务无权限

#### 报错
在启动mysql、nginx等服务，提示没有权限。查看日志，我发现目录已经都设置成了chmod 777。

90%是selinux的问题！

#### 修复
```bash
setenforce 0
```

永久生效

修改/etc/selinux/config中`SELINUX=disabled`

#### 拓展知识

apparmor

修改/etc/apparmor.d/usr.sbin.mysqld中的对应服务配置

重启apparmor服务

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