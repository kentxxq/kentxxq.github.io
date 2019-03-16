---
title:  chrome无法自动更新
date:   1993-07-06 00:00:00 +0800
categories: ["笔记"]
tags: ["mac"]
keywords: ["chrome","自动更新"]
description: "chrome无法自动更新，并且没有为所有用户设置自动更新的问题"
---


chrome无法自动更新，并且没有为所有用户设置自动更新的问题
---
```bash
# 这里是删除用户文件夹下面的google还有根目录下面的文件google文件夹，应该是会重新下载新的部分模块。同时也可以正常启用为所有用户更新chrome
sudo rm -rf /Library/Google && sudo rm -rf ~/Library/Google
```
