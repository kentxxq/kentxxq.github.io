---
title:  mac显示隐藏文件
date:   2017-07-19 00:00:00 +0800
categories: ["笔记"]
tags: ["mac"]
---


在终端下运行
---
```bash
# 显示
defaults write com.apple.finder AppleShowAllFiles -bool true
# 隐藏
defaults write com.apple.finder AppleShowAllFiles -bool false
```
