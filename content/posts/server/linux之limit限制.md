---
title:  linux之limit限制
date:   2020-06-20 16:05:00+08:00
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","file-max","nr_open","nofile","nproc"]
description: "记录一下linux常用的系统监控命令"
---


## 介绍相关参数


`file-max`:系统所有的进程所能打开的最大文件数(文件描述符)
```bash
# 查看
cat /proc/sys/fs/file-max
# 可在 /etc/sysctl.conf 中修改
# 可通过重启或sysctl -p生效
fs.file-max = 6553560
```

`nr_open`:单个进程可以打开的最大文件数
```bash
# 查看
cat /proc/sys/fs/nr_open
# 可在 /etc/sysctl.conf 中修改
# 可通过重启或sysctl -p生效
fs.nr_open = 65535
```

`nproc`:用户能创建最大的进程数

`nofile`:用户能打开最大的文件数
```bash
# 查看用户限制
# 系统默认配置，但会被 limits.d/ 下的内容覆盖
cat /etc/security/limits.conf
# 实际生效的设置
cat /etc/security/limits.d/20-nproc.conf

# 查看单个进程限制
cat /proc/进程id/limits
```

#### 示例
用户或组 | 限制级别 | 限制类型 | 值
---|---|---|---
root | soft | nofile | 65535
root | hard | nproc  | 65535

1. `soft`超过会有警告
2. `hard`严格限制，不会超过此数值


## 问题现象

### 指定用户无法登陆，服务异常

```bash
# 可能出现的报错
su: cannot set user id resource temporarily unavailable
Operation not permitted
-bash: ulimit: open files: 无法修改 limit 值: 不允许的操作
```

因为test环境后台服务都部署在同一台机器，所以默认的4096是不够用的。导致无法继续接收新的请求且无法连接。

ps：新的请求会用一个新的socket来处理。linux系统一切皆文件。所以新请求需要打开新的socket文件描述符。

操作如下：
1. 在`/etc/supervisord.conf`配置文件中`minfds`和`minprocs`分别限制了子进程的最大文件打开数和子进程数。需要修改后重启生效。
2. 启动服务的时候，使用的是指定用户。supervisor会调用setrlimit来解除这个进程的系统限制。但是当用户有登录等需求的时候，就会被系统限制到。最好设置为一个更大的值。


### 注意事项

1. 数值设置不是越大越好。有可能是因为程序没有释放连接造成的。一旦突破了系统设置的极限会影响到机器上的其他服务。
2. 65535是nginx的默认值。也是很多linux的用户限制值。同时端口最大值也是65535。超过65535的值，通常需要明确知道自己在做什么。


## 更新

**20200620**: 开篇