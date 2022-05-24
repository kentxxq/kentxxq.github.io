---
title:  kafka搭建
date:   2022-04-05 03:08:00+08:00
categories: ["笔记"]
tags: ["kafka"]
keywords: ["kafka"]
description: "简单记录一下部署docker-kafka的问题"
---

## 介绍

在写代码的时候用到了kafka，所以就用docker装了一个。发现连接一直报错。
```bash
Failed to resolve '9cdadb444cba:9092': 不知道这样的主机。  (after 2705ms in state CONNECT)
```
但是我看启动日志没有明显异常，端口㛑是可以`telnet`通的。

## 问题解决

原因是kafka的一些安全机制，，要做的也很简单。
```c#
// 我的连接地址是localhost:9092
var kafkaConfig = new ProducerConfig
        {
            BootstrapServers = "bwd.kentxxq.com:9092"
        };
```

1. 我们先找到kafka的docker名称
2. 于是我们在系统的hosts文件里写上`127.0.0.1 docker名称`

## 参考资料
[官方使用docker-kafka](https://developer.confluent.io/get-started/dotnet/#kafka-setup)