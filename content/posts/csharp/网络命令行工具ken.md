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

现支持的所有系统版本
- ken-linux-arm
- ken-linux-arm64
- ken-linux-arm
- ken-linux-arm64
- ken-linux-musl-x64
- ken-linux-x64
- ken-osx-arm64
- ken-osx-x64
- ken-win-arm.exe
- ken-win-arm64.exe
- ken-win-x64.exe
- ken-win-x86.exe

```bash
# 下载举例：linux-x64 下载到程序路径
curl -L -o /usr/local/bin/ken https://github.com/kentxxq/kentxxq.Cli/releases/latest/download/ken-linux-x64
# 如果是国内网络不行的话，可以使用七牛云cdn下载
curl -L -o /usr/local/bin/ken http://tools.kentxxq.com/ken-linux-x64
# 赋权
chmod +x /usr/local/bin/ken
```

## 如何使用

说明: 如果命令返回状态非0，则代表异常退出

### sp
`sp`代表socketping，之前一直都是用的`telnet`。但是只能一次性请求，而sp可以设置**连接超时时间、重试次数、连接成功后退出**。
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

### ws
`ws`代表连接websocket。之前一直用wscat，但是**wscat依赖nodejs**。每次使用的时候都觉得有点大材小用了。
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

### ss
`ss`代表socket status。主要原因是每次在windows上都容易忘记命令。后面会找时间去拓展成有用的功能。
```bash
❯ .\ken.exe ss
0.0.0.0:135
0.0.0.0:445
0.0.0.0:2179
0.0.0.0:5040
0.0.0.0:7680
0.0.0.0:7890
0.0.0.0:28653
0.0.0.0:49664
0.0.0.0:49665
0.0.0.0:49666
0.0.0.0:49667
0.0.0.0:49668
0.0.0.0:49669
0.0.0.0:49678
127.0.0.1:4012
127.0.0.1:4013
127.0.0.1:9100
127.0.0.1:9180
127.0.0.1:53087
127.0.0.1:53088
127.0.0.1:53117
127.0.0.1:53121
127.0.0.1:53430
127.0.0.1:57956
127.0.0.1:57961
127.0.0.1:61078
127.0.0.1:62078
169.254.171.114:139
172.18.87.230:139
172.18.87.230:5822
172.19.144.1:139
:::135
:::445
:::2179
:::7680
:::7890
:::49664
:::49665
:::49666
:::49667
:::49668
:::49669
:::49678
::1:49672
```

### tr
`tr`代表traceroute。是通过dotnet的ping实现。结果发现在linux有问题，所以后续再去拓展吧。
```bash
❯ .\ken.exe tr kentxxq.com
connect success
1 172.18.87.1 take 3ms XX-XX-内网IP-内网IP
2 10.10.18.5 take 2ms 未知的主机
3 175.6.6.233 take 2ms 中国-湖南-长沙-电信
4 172.16.250.1 take 30ms 未知的主机
5 无响应
6 124.232.148.125 take 2ms 中国-湖南-长沙-电信
7 61.137.4.129 take 6ms 中国-湖南-长沙-电信
8 202.97.77.1 take 22ms 中国-广东-广州-电信
9 无响应
10 无响应
11 129.250.66.61 take 122ms 日本-XX-XX-日本电信电话
12 129.250.3.23 take 87ms 美国-XX-XX-XX
13 无响应
14 无响应
15 185.199.110.153 美国-华盛顿-西雅图-XX
```

## TODO
1. ss命令增加更多的功能
2. tr命令等待ping库的完善，或者后续直接调用系统api来完成


## 更新日志

**20210830**: 开篇

**20210901**: 补全所有可以支持的linux版本

**20210905**: 使用七牛云免费套餐，加速国内的下载

**20211115**: net6发布了，所以更新了支持的平台。把2个还未完成的功能加入到了todo...反正我一直想有个自己的命令行工具，一定会持续完善的...