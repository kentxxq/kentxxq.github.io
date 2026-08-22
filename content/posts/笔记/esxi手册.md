---
title: esxi手册
tags:
  - blog
  - esxi
date: 2025-09-03
lastmod: 2025-11-25
categories:
  - blog
description: 
---

## 简介

这里是操作学习 esxi 虚拟机的记录。

## 手册

### 启用 ssh/esxi shell

 1. 使用 windows 上的 VMware sphere client 连接服务器
 2. 选择主机=》配置=》安全配置文件=》属性=》选择属性启用

### ssh 连接报错

- 算法问题 `Unable to negotiate with 192.168.6.249 port 22: no matching host key type found. Their offer: ssh-rsa,ssh-dss`
    - `ssh -oHostKeyAlgorithms=+ssh-rsa root@192.168.6.249` 临时启用
