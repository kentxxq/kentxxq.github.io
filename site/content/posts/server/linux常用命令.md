---
title:  linux常用命令
date:   2020-06-09 23:47:00 +0800
categories: ["笔记"]
tags: ["linux"]
keywords: ["linux","tar","ntpdate","truncate"]
description: "记录一下常用的linux常用命令"
---

> 记录一下常用的linux常用命令。

## 常用命令

### tar压缩、解压

```bash
# z是使用gzip 
# v是查看细节
# f是指定文件
# --strip-components=1 去掉一层解压目录

# 打包
tar -czvf dist.tgz dist/

# 解压
tar -xzvf dist.tgz

# 打包隐藏文件
# 通过 . 可以打包到隐藏文件 
tar -czvf dist.tgz /dad/path/.
# 通过上级目录来打包
tar -czvf dist.tgz /data/path
# 如果是在当前目录，可以手动指定
tar -czvf dist.tgz tar -zcvf dist.tgz .[!.]* * 
```

### 时间同步
```bash
sudo yum install ntp -y

ntpdate pool.ntp.org
```

### 清空文件
```bash
# 本来可以如此简单 
>file.txt
# 但是不属于你的文件呢？
sudo bash -c ">file.txt"
# 于是就用新的命令,加sudo也很方便
# 这里的s是大小的意思
truncate -s 0 file.txt
```

## 更新

**20200609**: 初版