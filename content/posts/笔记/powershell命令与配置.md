---
title: powershell命令与配置
tags:
  - blog
  - powershell
date: 2023-06-26
lastmod: 2023-07-01
categories:
  - blog
description: "这里记录 [[笔记/point/powershell|powershell]] 的常用命令."
---

## 简介

这里记录 [[笔记/point/powershell|powershell]] 的常用命令.

## 操作手册

### 日常操作

```powershell
# 示例是配置golang,启用cgo编译
# 本地变量
set CGO_ENABLED "1"
echo $CGO_ENABLED
rv CGO_ENABLED

# $env 用于访问用户变量和系统变量
echo $env:CGO_ENABLED
```

### 命令查询

```powershell
# 查询所有命令
Get-Command
# 查询名字包含Process的命令
Get-Command -Name *Process

# 查看alias
Get-Alias
Alias           set -> Set-Variable
Alias           echo -> Write-Output
Alias           rv -> Remove-Variable

Alias           ls -> Get-ChildItem
Alias           cat -> Get-Content
Alias           cd -> Set-Location
Alias           clear -> Clear-Host
Alias           copy -> Copy-Item
Alias           cp -> Copy-Item
Alias           mv -> Move-Item
```

### 常用配置

#todo/笔记 主题配置文件

```powershell
# 查看配置文件
code $profile # vscode打开
notepad $profile # 记事本打开

# 配置文件的内容
## 安装oh-my-posh
winget install JanDeDobbeleer.OhMyPosh -s winget

# 主题配置,主题列表 https://ohmyposh.dev/docs/themes
oh-my-posh init pwsh --config "D:\OneDrive\kentxxq\config\oh-my-posh\theme.json" | Invoke-Expression

# vpn命令
function vpn {
    $Env:http_proxy = "http://127.0.0.1:7890"; $Env:https_proxy = "http://127.0.0.1:7890";
}

function novpn {
    $Env:http_proxy = ""; $Env:https_proxy = "";
}

# 配合ssh-agent使用
$env:GIT_SSH="C:\Windows\System32\OpenSSH\ssh.exe"
```

### 问题处理

- [[笔记/point/wsl|wsl]] 的网络修复

  ```powershell
  # 需要管理员权限
  netsh winsock reset
  ```

- 接触 powershell 的下载限制

  ```powrshell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

## 相关资源

- [官方参考文档](https://docs.microsoft.com/en-us/powershell)
