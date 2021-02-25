---
title:  PowerShell常用命令
date:   2019-03-12 14:57:00 +0800
categories: ["笔记"]
tags: ["PowerShell"]
keywords: ["PowerShell","跨平台脚本","bash","zsh","fish"]
description: "因为公司电脑都是windows系统，然后ss的windows版本客户端，没有直接生成命令行的按钮，那就自己来呗。结果。。。"
---

> 因为公司电脑都是win10系统，然后ss的win版本客户端，没有直接生成命令行的按钮，那就自己来呗。结果。。。


## 关于[PowerShell](https://github.com/PowerShell/PowerShell)

由于我平时很少使用win10下的命令行写脚本，但是PowerShell现在完全**开源跨平台**了。  
想想你写一个脚本，无论什么环境，都能跑。指不定以后能一统shell呢？！  
而且它还有一个简短的名字`pwsh`,几乎就是再和**zsh，fish，bash**靠拢啊！超级容易让初学者入坑。

## 使用习惯上的区别

1. powershell许多的操作不需要**等号**，比如设置变量值！
2. 如果开启了ss，就会系统级别的代理。你新开的会话窗口(powershell窗口)就已经被代理了。

## 常用命令(支持tab补齐)

```bash
# 查看配置文件，可以永久配置方法，别名
$profile


# 查询所有命令
Get-Command
# 查询名字包含Process的命令 
Get-Command -Name *Process


# 常用系统方法
# 获取服务
Get-Service
# 查看Get-Service服务的具体参数
Get-Service | Get-Member


# 查看所有变量
ls env:
# 查看指定变量
$env:windir
# 创建变量
$env:a="a"
# 删除变量
del $env:a


# 查看所有别名
Get-Alias
# 临时设置别名
Set-Alias list get-childitem
# 临时设置带参别名
# 先变成方法
function getlist {Get-ChildItem -Name}
# 再来设置别名
Set-Alias ls getlist

# 解除powershell下载限制
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 资源

[官方参考文档](https://docs.microsoft.com/en-us/powershell)

## 更新记录

**20200401**: 新增`解除powershell下载限制`