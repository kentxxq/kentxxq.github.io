---
title:  调试安卓或者iphone上的网页
date:   2018-12-21 00:00:00 +0800
categories: ["笔记"]
tags: ["mac"]
keywords: ["安卓","mac","iphone","调试"]
description: "开发的时候，电脑上chrome没问题，但是手机上访问有问题，那么就需要在手机上调试"
---


> 开发的时候，电脑上chrome没问题，但是手机上访问有问题，那么就需要在手机上调试。

iphone上调试safari
===
1. 开启`safari`上的web检查器
2. 连接mac，然后打开开发者选项
3. mac上选中自己iphone即可开始调试

android上调试chrome
===
1. `brew cask install android-file-transfer`可以帮助你检测到手机
2. 打开手机上的开发者选项，开启usb调试
3. `chrome://inspect/#devices`就可以查看到设备，然后点开
4. 手机上访问页面，就可以通过devtools调试了