---
title:  git的常用命令
date:   2019-01-04 00:00:00 +0800
categories: ["笔记"]
tags: ["git"]
---



去除所有的历史
---
```bash
#初始化连接到远程库
git init
git remote add origin git@github.com:user/repo
#添加所要添加的文件
git add .
git commit -am ‘first commit’
#强制推送到远程库
git push -f origin master
#强制拉取，覆盖本地
git reset -—hard origin/master
```