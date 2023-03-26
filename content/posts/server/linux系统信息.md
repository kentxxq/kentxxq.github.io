---
title:  查看linux的相关信息
date:   2020-01-04 23:27:00+08:00
categories: ["笔记"]
tags: ["centos","linux"]
keywords: ["centos","linux","cpu","内存"]
description: "记录一下linux常用的系统监控命令"
---


> 记录一下linux常用的系统监控命令。


## 系统相关

### 系统信息

```bash
$ lsb_release -a
LSB Version:	:core-4.1-amd64:core-4.1-noarch
Distributor ID:	CentOS
Description:	CentOS Linux release 8.0.1905 (Core) 
Release:	8.0.1905
Codename:	Core
```

### 系统os错误代码查询

```bash
perror 24
OS error code  24:  Too many open files
```

## 服务器硬件

### 服务器型号

```bash
dmidecode | grep 'Product Name' 
```

### 查看主板的序列号

```bash
dmidecode | grep 'Serial Number' 
```

### 查看系统序列号

```bash
dmidecode -s system-serial-number
```

### 查看cpu信息

```bash
cat /proc/cpuinfo
```

### 现有内存数量和内存大小

```bash
dmidecode | grep -A16 "Memory Device" | grep "Size" |sed 's/^[ \t]*//'
```

### 查看内存信息

```bash
dmidecode -t memory
# 或
cat /proc/meminfo
```

### 查看OEM信息

```bash
dmidecode -t 11
```

### 最大支持内存容量

```bash
dmidecode | grep "Maximum Capacity" |sed  "s/^[ \t]*//"
```

### 查看磁盘信息

```bash
fdisk -l
```

## 监控

### 系统资源概况

```bash
top
# glances界面更现代化，但centos需要yum安装，且当下20200206无法直接安装使用
glances
```

### 硬盘监控

```bash
# io的top命令
iotop
```

### 网络流量监控

```bash
# 用来进行查看各个网卡的总流量
nload 
# 用来监控各个进程的流量使用情况
nethogs
# 图形化的工具，可以查看具体的端口情况
iptraf-ng
```

### 内存监控

```bash
# 查看内存使用状态
free -m
# 查看内存变化 vmstat 间隔 监控次数
vmstat 2 2
```


## 更新

**20200206**: 新增系统监控