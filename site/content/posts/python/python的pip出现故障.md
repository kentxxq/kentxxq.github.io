---
title:  python的pip出现故障
date:   2017-09-05 00:00:00 
categories: ["笔记"]
tags: ["python"]
keywords: ["python","pip","故障"]
description: "今天在使用的过程中`macOS`，想要用命令更新一下python的所有包"
---


> 今天在使用的过程中`macOS`，想要用命令更新一下python的所有包。
使用命令如下：
```shell
# 把所有的过期包找出来，使用-U来更新
pip3 list --outdated | grep '^[a-z]* (' | cut -d " " -f 1 | xargs pip3 install -U
```


出现报错
---
```shell
ImportError: cannot import name 'IncompleteRead'
```

解决问题
---
```shell
# 1...在官网下载新的python安装包，然后进行安装。  并不会影响到你之前的python3环境！例如xlrd等工具包，并不会被覆盖丢失！
wget https://www.python.org/ftp/python/3.6.2/python-3.6.2-macosx10.6.pkg --no-check-certificate
# 2...wget下载这一个python文件--这个地址可以自动识别python版本 https://bootstrap.pypa.io/get-pip.py
wget https://bootstrap.pypa.io/3.2/get-pip.py --no-check-certificate
# 3...执行此文件
sudo python3 get-pip.py  
```

心得
---
> 操作起来特别容易的事情，而我不经常写笔记。为什么要记录下来呢？

1. 我是一个python新手，希望能帮到新手。
2. 我的macOS自带是油python2.7的，但是我自己学的是python3.6。两个版本都不能用了，有可能影响到系统！
3. 要抓紧学习了！！
