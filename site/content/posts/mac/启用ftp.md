---
title:  mac启用ftp
date:   2017-07-17 00:00:00 +0800
categories: ["笔记"]
tags: ["mac"]
keywords: ["mac","ftp"]
description: "mac下一般用smb服务来进行远程文件访问，但要用FTP的话，高版本的mac os默认关掉了，可以用如下命令打开"
---


> mac下一般用smb服务来进行远程文件访问，但要用FTP的话，高版本的mac os默认关掉了，可以用如下命令打开:


```bash
# 开启
sudo -s launchctl load -w /System/Library/LaunchDaemons/ftp.plist
# 关闭
sudo -s launchctl unload -w /System/Library/LaunchDaemons/ftp.plist
```
