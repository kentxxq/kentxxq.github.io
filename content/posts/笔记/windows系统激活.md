---
title: windows系统激活
tags:
  - blog
  - windows
date: 2023-07-01
lastmod: 2024-12-20
categories:
  - blog
keywords:
  - windows
  - 激活
  - kms
description: "推荐使用正版, 但用来学技术也是不错的."
---

## 简介

推荐使用正版, 但用来学技术也是不错的.

[[笔记/point/windows|windows]] 的系统激活方式有以下几种:

1. MSDN 密钥。属于内部的使用，封不封看微软态度。
2. Retail 零售版密钥。就是你找微软买的，缺点就是要钱呗。
3. OEM 密钥。电脑厂家出厂预装的系统，然后绑定了你的硬件信息，无法跨机器使用。
4. VOL 密钥。一般是企业或者学校购买了批量授权。**应该**分 `mak` 和 `kms` 两种，前者永久，后者 180 天需激活一次。

## 操作步骤

[微软官网](https://learn.microsoft.com/zh-cn/windows-server/get-started/kms-client-activation-keys?tabs=server2025%2Cwindows1110ltsc%2Cversion1803%2Cwindows81) 写着对应产品的产品密钥, 其中 `win10` 和 `win11` 对应 `W269N-WFGWX-YVC9B-4J6C9-T83GX`

```powershell
# 执行,弹出(已成功卸载了产品密钥)
slmgr.vbs /upk

# 执行,弹出(成功的安装了产品密钥)
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX

# 执行,弹出(密钥管理服务计算机名成功的设置(kms.luody.info)
slmgr /skms kms-default.cangshui.net

# 执行,弹出(成功的激活了产品)
slmgr /ato

# 查看激活详情
slmgr.vbs -dlv
```

## 自己搭建

```shell
docker run -d -p 1688:1688 --name kms --restart=always teddysun/kms

# 验证
# 查看服务的版本信息
vlmcs.exe -v kms-default.cangshui.net
# 查看支持的服务类型
vlmcs.exe -x kms-default.cangshui.net
```

- [[附件/vlmcs.exe]]
- Dockerfile 在这里: [across/docker/kms/Dockerfile at master · teddysun/across · GitHub](https://github.com/teddysun/across/blob/master/docker/kms/Dockerfile)
- 实现在这里: [GitHub - Wind4/vlmcsd: KMS Emulator in C (currently runs on Linux including Android, FreeBSD, Solaris, Minix, Mac OS, iOS, Windows with or without Cygwin)](https://github.com/Wind4/vlmcsd)

## 可能遇到的问题

### 弹出内部版本 xx 过期

我用的是 win10 预览版，一直没有激活。激活了以后，一直弹出内部版本过期。

进入系统更新，升级到最新的版本，之后重启解决
