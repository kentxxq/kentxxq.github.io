---
title: macos问题处理
tags:
  - blog
  - macos
date: 2023-07-01
lastmod: 2023-07-01
categories:
  - blog
description: "这里记录在使用 [[笔记/point/macos|macos]] 过程中遇到的问题."
---

## 简介

这里记录在使用 [[笔记/point/macos|macos]] 过程中遇到的问题.

## 问题列表

### 显示隐藏文件

```shell
# 显示
defaults write com.apple.finder AppleShowAllFiles -bool true
# 隐藏
defaults write com.apple.finder AppleShowAllFiles -bool false
```

### 启用 ftp

> mac 下一般用 smb 服务来进行远程文件访问，但要用 FTP 的话，高版本的 mac os 默认关掉了，可以用如下命令打开:

```shell
# 开启
sudo -s launchctl load -w /System/Library/LaunchDaemons/ftp.plist
# 关闭
sudo -s launchctl unload -w /System/Library/LaunchDaemons/ftp.plist
```

### Chrome 无法自动更新

```shell
# 这里是删除用户文件夹下面的google还有根目录下面的文件google文件夹，应该是会重新下载新的部分模块。同时也可以正常启用为所有用户更新chrome
sudo rm -rf /Library/Google && sudo rm -rf ~/Library/Google
```

### 修改主机名

```shell
sudo -scutil --set HostName 'kentxxq’s MacBook Pro'
```

### 启用 root

```shell
# 启用root用户并且创建密码
sudo -i
```

### 调试安卓或者 iphone 上的网页

> 开发的时候，电脑上 chrome 没问题，但是手机上访问有问题，那么就需要在手机上调试。

#### iphone 上调试 safari

1. 开启 `safari` 上的 web 检查器
2. 连接 mac，然后打开开发者选项
3. mac 上选中自己 iphone 即可开始调试

#### android 上调试 chrome

1. `brew cask install android-file-transfer` 可以帮助你检测到手机
2. 打开手机上的开发者选项，开启 usb 调试
3. `chrome://inspect/#devices` 就可以查看到设备，然后点开
4. 手机上访问页面，就可以通过 devtools 调试了
