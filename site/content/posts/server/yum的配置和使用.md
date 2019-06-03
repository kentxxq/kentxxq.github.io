---
title:  yum的配置和使用
date:   1993-07-06 00:00:00 
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","yum","wget"]
description: "yum是用来安装、更新、卸载、管理软件包的工具。rpm安装包因为存在依赖其他rpm软件包的问题，yum用来更加方便的解决这些问题"
---


> yum是用来安装、更新、卸载、管理软件包的工具。rpm安装包因为存在依赖其他rpm软件包的问题，yum用来更加方便的解决这些问题。  

在/etc中存在有  

1. yum          版本以及插件信息
2. yum.conf     配置信息
3. yum.repos.d  配置从哪个源来对比进行操作


常用命令
---
```bash
# 安装
yum install software
# 卸载
yum remove software
# 查看所有源
yum repolist
# 查看所有可用的源
yum repolist enable
```

解决国外源,下载速度慢的问题,使用阿里云
---
```bash
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

# 163网易源 http://mirrors.163.com/.help/CentOS7-Base-163.repo
```

只需要更新指定的安全补丁
---
```bash
# 老版本安装yum插件即可、新版本centos7直接使用
yum install yum-security
# 使用:检查安全更新
yum --security check-update
# 只安装安全更新
yum update --security
# 列出更新的详细信息
yum info-security software_name
```
