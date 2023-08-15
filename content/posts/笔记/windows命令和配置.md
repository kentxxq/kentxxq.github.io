---
title: windows命令和配置
tags:
  - blog
date: 2023-08-15
lastmod: 2023-08-15
categories:
  - blog
description: "记录一些 [[笔记/point/windows|windows]] 命令和配置"
---

## 简介

记录一些 [[笔记/point/windows|windows]] 命令和配置

## 命令

### 查看系统信息

```powershell
msinfo32
# 或者
winver
```

### 查找过滤

```shell
# 占用13800端口的进程
netstat -aon|findstr "13800"
# 
tasklist|findstr "12884" #
```

### 动态端口保留

```powershell
# 查看动态端口范围
netsh int ipv4 show dynamicport tcp

# 被系统或者我们自己保留的端口
netsh int ipv4 show excludedport tcp

# 设置动态端口范围
netsh int ipv4 set dynamicport tcp start=49152 num=16384

# 保留 6942~6951 这10个端口给应用程序使用
netsh int ipv4 add excludedportrange protocol=tcp startport=6942 numberofports=10

# 保留 9090 端口给应用程序使用
netsh int ipv4 add excludedportrange protocol=tcp startport=9090 numberofports=1

# 带星号的就是被管理员保留的端口，可以被应用程序使用  
# 如果要取消保留端口，可以：  
netsh int ipv4 delete excludedportrange protocol=tcp startport=9090 numberofports=1
```

### 计算 hash

```powershell
# MD5
Get-FileHash -Algorithm MD5 -Path C:\Path\To\File
# SHA256
Get-FileHash -Algorithm SHA256 -Path C:\Path\To\File
```

### 杀死进程

```powershell
# 杀死进程
TASKKILL /F /IM tomcat8186.exe 
```

### 删除文件

```powershell
del /f /s /q "E:\Apache\NginxCluster86\TomcatNode8186\logs\*"
```

### 间隔时间

```powershell
# 相当于间隔了20秒
ping 127.0.0.1 -n 20 
```

### 启动服务

```powershell
sc start 服务名
```

## 配置

### 多用户远程桌面

1. 打开 `gpedit.msc`
2. `计算机配置` => `管理模板` => `windows组件` => `远程桌面服务` => `远程桌面会话主机` => `连接`
3. 配合 `限制连接的数量`, `启用` 并配置 `个数`.

> 关闭某个会话
> 进入到 `任务管理器` => 打开 `用户面板` => `断开会话,关闭会话`

### 共享文件夹

1. 启用 smb
2. 文件夹右键共享
3. 添加 everyone，ay 匿名的所有控制权限
4. 启用所有网络发现，关闭密码

处理问题:

`win10` 无法访问, 而 `win7` 可以.

1. 打开 `gpedit.msc`
2. `计算机配置` => `管理模板` => `网络` => `Lanman 工作站`
3. 配置 `启用不安全的来宾登录` 为 `启用`
