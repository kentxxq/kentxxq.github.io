---
title: 网络命令行工具-ken
tags:
  - blog
  - csharp
date: 2021-08-30
lastmod: 2023-07-11
hiddenFromHomePage: false
categories:
  - blog
keywords:
  - "C#"
  - "tools"
  - "csharp"
  - "ken"
description: "在日常的使用场景中，总是不得不接触各种各样的命令行工具。而在使用的过程中，多多少少有一些不好用的地方。马上就要发布到NET6，终于做到了在mac和windows系统上进行单个文件的发布。同时单个文件的大小又几乎缩小了一倍。所以就有了想法自己写一个"
---

在日常的使用场景中，总是不得不接触各种各样的命令行工具。而在使用的过程中，多多少少有一些不好用的地方。马上就要发布到 NET6，终于做到了在 mac 和 windows 系统上进行单个文件的发布。同时单个文件的大小又几乎缩小了一倍。所以就有了想法自己写一个。

## 简介

在日常的使用场景中，总是不得不接触各种各样的命令行工具。而在使用的过程中，多多少少有一些不好用的地方。马上就要发布到 NET6，终于做到了在 mac 和 windows 系统上进行单个文件的发布。同时单个文件的大小又几乎缩小了一倍。所以就有了想法自己写一个。

因为我希望命令尽量简短, 所以使用我的名字 [[笔记/point/kentxxq|ken]] 来命名.

[代码都是开源](https://github.com/kentxxq/kentxxq.Cli) 的，采用 [[笔记/point/csharp|csharp]] 编写。使用了微软自己的 `System.Commandline`。

现支持的所有系统版本

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
curl -L -o /usr/local/bin/ken https://github.com/kentxxq/kentxxq.Cli/releases/download/1.2.7/ken-linux-x64
# 如果是国内网络不行的话，可以使用代理下载
curl -L -o /usr/local/bin/ken https://github.abskoop.workers.dev/https://github.com/kentxxq/kentxxq.Cli/releases/download/1.2.7/ken-linux-x64
# 或 curl -L -o /usr/local/bin/ken https://ghproxy.com/https://github.com/kentxxq/kentxxq.Cli/releases/download/1.2.7/ken-linux-x64
# 赋权
chmod +x /usr/local/bin/ken
```

## 如何使用

说明: 如果命令返回状态非 0，则代表异常退出

### 端口检测 sp

`sp` 代表 socketping，之前一直都是用的 `telnet`。但是只能一次性请求，而 sp 可以设置**连接超时时间、重试次数、连接成功后退出**。

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

### 长连接 ws

`ws` 代表连接 websocket。之前一直用 wscat，但是**wscat 依赖 nodejs**。每次使用的时候都觉得有点小题大做了。

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

### 查看端口监听 ss

`ss` 代表 socket status。主要原因是每次在 windows 上都容易忘记命令。后面会找时间去拓展成有用的功能。

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

### 路由追踪 tr

`tr` 代表 traceroute。是通过 dotnet 的 ping 实现。结果发现在 linux 有问题，所以后续再去拓展吧。

```bash
❯ ken.exe tr kentxxq.com
try connecting to kentxxq.com ...success
1 request timeout
2 118.250.180.1 take 0ms 中国-湖南-长沙-电信
3 61.187.29.245 take 3ms 中国-湖南-长沙-电信
4 61.137.3.129 take 0ms 中国-湖南-长沙-电信
5 request timeout
6 202.97.94.122 take 19ms 中国-北京-北京-电信
7 202.97.94.94 take 58ms 中国-北京-北京-电信
8 202.97.60.214 take 0ms 日本-XX-XX-电信
9 129.250.3.23 take 79ms 美国-XX-XX-XX
10 129.250.6.127 take 0ms 美国-XX-XX-XX
11 61.200.82.50 take 102ms 日本-XX-XX-XX
12 185.199.110.153 美国-华盛顿-西雅图-XX
```

### 操作 redis

`redis` 因为经常删除特定的 key，而 `redis-cli` 没有没有很好的支持这点，所以就自己写了一个最常用的。。

```bash
# 错误命令就会输出usage
# usage:
# a*: search all keys start with a in db
# del a2*: delete all keys start with a2 in db
# select 1: checkout db 1
# exit(): just exit

> ken redis bwd.kentxxq.com -p 123456
connect success,take 27.4024 ms
db0 keys:2
>>a
keys count:1
>>b
keys count:1
>>a*
keys count:1
>>del a
deleted 1 key(s)
>>select 1
using db1 keys count:1
>>c
keys count:1
>>exit()
```

### k8s 状态查询

`k8s` 命令的存在，主要是因为我日常需要查看 k8s 集群的信息，所以做到了命令里。

```bash
Description:
  get k8s resource info

Usage:
  ken k8s [command] [options]

Options:
  -c, --kubeconfig <kubeconfig>  kubeconfig file path
  -n, --namespace <namespace>    specified namespace
  -?, -h, --help                 Show help and usage information

Commands:
  1  list restarted pod
  2  list deployment resource usage
```

#### 查看 k8s 内重启过的容器

```bash
ken k8s 1
┌───────────┬──────────────────┬───────────────┐
│ Namespace │ Pod Name         │ Restart Times │
├───────────┼──────────────────┼───────────────┤
│ default   │ A-service        │ 187           │
│ default   │ B-service        │ 1             │
│ default   │ C-service        │ 3             │
└───────────┴──────────────────┴───────────────┘
```

#### 查看 deployment 的资源使用情况

`ken k8s 2` 大致输出如下

| Namespace | Deployment         | Memory Usage | Cpu Usage | Request Memory | Limit Memory | Request Cpu | Limit Cpu |
|-----------|--------------------|--------------|-----------|----------------|--------------|-------------|-----------|
| default   | kube-state-metrics | 3.57%        | 0.25%     | 32Mi           | 1Gi          | 10m         | 200m      |


### 静态文件代理 web

`web` 直接将当前目录暴露成 http，并提供访问。方便调试、静态文件下载等等需求

```bash
Description:
  static file http server

Usage:
  ken web [options]

Options:
  -w, --webroot <webroot>  file path [default: .]
  -p, --port <port>        http port [default: 5000]
  -?, -h, --help           Show help and usage information

# 使用示例
ken web
listening http://0.0.0.0:5000
HTTP/1.1 GET / 200 text/html; charset=utf-8 5367
HTTP/1.1 GET /favicon.ico 404
```

1. 默认当前目录，也可以只用 `-w` 指定目录
2. 默认使用 5000 端口，也可以使用 `-p` 指定端口
### 更新 update

这个命令主要是为了更新 ken 程序自己。避免冗长的 bash 命令。

```bash
ken update -h
Description:
  update ken command

Usage:
  ken update [options]

Options:
  -f, --force                       force update current version [default: False]
  -kv, --ken-version <ken-version>  force upgrade to specific current version
  -p, --proxy                       use proxy url
  -t, --token <token>               github token for query github-api []
  -?, -h, --help                    Show help and usage information
```

1. `-p` 使用 `https://github.abskoop.workers.dev` 代理下载，方便国内用户
2. `-t` 是因为 github 的 api 存在次数限制。带上 token 可以大幅提升 api 的请求次数
3. `-kv` 可以指定特定的版本，例如 `-kv 1.3.2` 则更新到 1.3.2 版本。因为我不想留着一些无用的版本号，所以 1.3.1 可能不见了。。。建议不使用此命令，直接 update 到最新版本



### 网站连通性测试 wp

`wp` 是 `web ping` 的缩写. 顾名思义类似 `sp` 命令不断发送 http 请求, 帮助判断是否存活.

```shell
Description:
  web ping
  
Usage:
  ken wp <url> [options]
  
Arguments:
  <url>  url: https://www.kentxxq.com
  
Options:
  -i, --interval <interval>  web ping interval seconds [default: 1]
  -t, --timeout <timeout>    default:2 seconds [default: 2]
  -d, --disableKeepAlive     default: true [default: False]
  -f, --curlFile <curlFile>  if curlFile is not null ,Argument url will be ignore. default: '' []
  --debug                    enable verbose output [default: False]

# 每秒一次请求
ken wp https://baidu.com
09:51:24,https://baidu.com/: Redirect 245ms
09:51:25,https://baidu.com/: Redirect 37ms
09:51:26,https://baidu.com/: Redirect 40ms

# 支持导入curl.如果导入了curl文件,https://a.com 将不会生效
ken wp https://a.com -f D:\tmp\curl.txt
```

### 压测 bm

`bm` 是 `benchmark` 的缩写. 用来进行压测 http 压测的.

```shell
Description:
  http benchmark

Usage:
  ken bm <url> [options]

Arguments:
  <url>  url: https://test.kentxxq.com/Counter/Count

Options:
  -d, --duration <duration>      duration: benchmark duration [default: 10]
  -c, --concurrent <concurrent>  concurrent: concurrent request [default: 50]
  -f, --curlFile <curlFile>      if curlFile is not null ,Argument url will be ignore. default: '' []


# 默认50并发,10秒钟.请求了3328次
ken bm https://test.kentxxq.com/counter/count
完成次数3328
```
