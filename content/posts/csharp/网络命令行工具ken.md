---
hiddenFromHomePage: false
title:  网络命令行工具-ken
date:   2021-08-30 17:42:00+08:00
categories: ["笔记"]
tags: ["csharp","tools"]
keywords: ["C#","tools","csharp","ken"]
description: "在日常的使用场景中，总是不得不接触各种各样的命令行工具。而在使用的过程中，多多少少有一些不好用的地方。马上就要发布到NET6，终于做到了在mac和windows系统上进行单个文件的发布。同时单个文件的大小又几乎缩小了一倍。所以就有了想法自己写一个"
---


> 在日常的使用场景中，总是不得不接触各种各样的命令行工具。而在使用的过程中，多多少少有一些不好用的地方。马上就要发布到NET6，终于做到了在mac和windows系统上进行单个文件的发布。同时单个文件的大小又几乎缩小了一倍。所以就有了想法自己写一个。

## 简介

`ken`的由来: 我一直以来用的都是名字kentxxq。而在日常生活中需要一个简短好用的名字，于是就用了ken。同时也因为命令行需要足够简短，所以也就用了这个名字。  
[代码都是开源](https://github.com/kentxxq/kentxxq.Cli)的，采用c#编写。使用了微软自己的`System.Commandline`。


**因为现在net6还没有发布，所以暂时只发布linux的版本，后续会加上其他的版本。**


```bash
# 现支持的所有linux版本: linux-x64/linux-arm64/linux-arm/linux-musl-x64
# linux-x64 下载到程序路径
curl -L -o /usr/local/bin/ken https://github.com/kentxxq/kentxxq.Cli/releases/latest/download/ken-linux-x64
# 如果是国内网络不行的话，可以使用七牛云cdn下载
curl -L -o /usr/local/bin/ken http://tools.kentxxq.com/ken-linux-x64
# 赋权
chmod +x /usr/local/bin/ken
```

## 如何使用

1. 两个子命令`sp`和`ws`。如果命令返回状态非0，则代表异常退出。
2. `sp`代表socketping，之前一直都是用的`telnet`。但是只能一次性请求，而sp可以设置**连接超时时间、重试次数、连接成功后退出**。
```bash
Usage:
  ken [options] sp <url>

Arguments:
  <url>  url: kentxxq.com:443

Options:
  -n, --retryTimes <retryTimes>  default:0,retry forever [default: 0]
  -t, --timeout <timeout>        default:2 seconds [default: 2]
  -q, --quit                     Quit after connection succeeded [default: False]
  -?, -h, --help                 Show help and usage information

# 请求2次
ken sp kentxxq.com:443 -n 2
request successed. waited 137 ms
request successed. waited 1117 ms
# 请求2次，一旦成功就退出
ken sp kentxxq.com:443 -n 2 -q
request successed. waited 96 ms
# 请求失败的情况，同时设置超时时间
ken sp kentxxq.com:444 -t 3 -n 2 -q
request failed. waited 3016 ms
request failed. waited 3013 ms
# 解析失败的情况
ken sp kentxxq:443 -t 3 -n 2 -q
parse error:不知道这样的主机。
```
3. `ws`代表连接websocket。之前一直用wscat，但是**wscat依赖nodejs**。每次使用的时候都觉得有点大材小用了。
```bash
Usage:
  ken [options] ws <wsUrl>

Arguments:
  <wsUrl>  wsUrl: wss://ws.kentxxq.com/ws

# 连接websocket
ken ws wss://ws.kentxxq.com/ws
>> ls
<< ls
>> pwd
<< pwd
>> 你好
<< 你好
```

## 更新日志

**20210830**: 开篇

**20210901**: 补全所有可以支持的linux版本

**20210905**: 使用七牛云免费套餐，加速国内的下载