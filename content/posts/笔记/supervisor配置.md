---
title: supervisor配置
tags:
  - blog
  - devops
date: 2023-07-03
lastmod: 2023-07-11
categories:
  - blog
description: "这里记录一下 supervisor 在 [[笔记/point/linux|linux]] 下的常用配置, 方便复用."
---

## 简介

这里记录一下 supervisor 在 [[笔记/point/linux|linux]] 下的常用配置, 方便复用.

## 操作手册

安装和基础配置

```shell
# 安装
apt install supervisor -y

# 加入2个参数,minfds最大文件数,minprocs最大进程数
vim /etc/supervisor/conf.d/supervisord.conf
[supervisord]
minfds=81920
minprocs=81920

systemctl enable supervisor
systemctl start supervisor
```

编辑配置文件 `vim /etc/supervisor/conf.d/demo.conf`

```toml
[program:demo]

environment=VAR1="value1",VAR2="value2"
directory = /root/app_dir
command = /xxx/java -jar app.jar

# 启动进程数目默认为1
numprocs = 1
# 如果supervisord是root启动的 设置此用户可以管理该program
user = root
# 程序运行的优先级 默认999
priority = 996

# 随着supervisord 自启动
autostart = true
# 子进程挂掉后无条件自动重启
autorestart = true
# 子进程启动多少秒之后 状态为running 表示运行成功
startsecs = 20
# 进程启动失败 最大尝试次数 超过将把状态置为FAIL
startretries = 3

# 标准输出的文件路径
stdout_logfile = /tmp/demo-supervisor.log
# 日志文件最大大小
stdout_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stdout_logfile_backups = 3

# 错误输出的文件路径
stderr_logfile = /tmp/demo-supervisor.log
# 日志文件最大大小
stderr_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stderr_logfile_backups = 3
```
