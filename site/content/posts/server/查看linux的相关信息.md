---
title:  查看linux的相关信息
date:   2020-01-04 23:27:00 +0800
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","linux","cpu","内存",""]
description: "自己记录一下常用的linux查询命令。免得每次导出找破头。主要是在centos上操作验证"
---


> 自己记录一下常用的linux查询命令。免得每次导出找破头。主要是在centos上操作验证。


系统相关
===

系统信息
---
```bash
$ lsb_release -a
LSB Version:	:core-4.1-amd64:core-4.1-noarch
Distributor ID:	CentOS
Description:	CentOS Linux release 8.0.1905 (Core) 
Release:	8.0.1905
Codename:	Core
```

服务器硬件
===

服务器型号
---
```bash
dmidecode | grep 'Product Name' 
```

查看主板的序列号
---

```bash
dmidecode | grep 'Serial Number' 
```

查看系统序列号
---

```bash
dmidecode -s system-serial-number
```

查看cpu信息
---

```bash
cat /proc/cpuinfo
```

现有内存数量和内存大小
---

```bash
dmidecode | grep -A16 "Memory Device" | grep "Size" |sed 's/^[ \t]*//'
```

查看内存信息
---

```bash
dmidecode -t memory
# 或
cat /proc/meminfo
```

查看OEM信息
---

```bash
dmidecode -t 11
```

最大支持内存容量
---

```bash
dmidecode | grep "Maximum Capacity" |sed  "s/^[ \t]*//"
```
