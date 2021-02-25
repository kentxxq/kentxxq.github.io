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

### 开启bbr

bbr是一种浪费网络资源，提升网络速度和稳定性的通讯手段。

centos8默认内核4.18，不用升级内核，即可启动。否则需要用升级内核。

```bash
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
# 生效
sysctl -p
# 验证
lsmod | grep bbr
```

### 使用yum镜像源

```bash
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```

### 终端中文显示

#### 查看已有的字符编码集
```bash
locale -a
```

#### 如果没有zh_CN.UTF-8
```bash
sudo yum install -y langpacks-zh_CN
```

#### 使用中文

```bash
vim /etc/locale.conf
LANG=zh_CN.UTF-8
```

或`localectl  set-locale LANG=zh_CN.UTF8`

### 删除7天前的文件

```bash
find /data/weblog/ -name '*.log.*' -type f -mtime +7 -exec rm -f {} \;
```

### 查看进程的启动时间

```bash
ps -eo pid,lstart,etime | grep 1310
1310 Sat Aug 10 10:21:25 2019 242-07:26:58
# 前面是启动时间，后面是启动了242天
```

### 端口连接情况
```bash
# 查看监听的端口
netstat -ltnp
# 统计外部ip，端口连接数量
netstat -ant |awk '{print $5}' | awk -F ':' '{count[$1]++;} END {for(i in count) {print i "\t" count[i]}}'
```

## 更新

**20200609**: 初版
**20200717**：新增`端口连接情况`