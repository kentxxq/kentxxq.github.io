---
title:  elastalert2钉钉告警
date:   2022-05-24 21:13:00+08:00
categories: ["笔记"]
tags: ["监控"]
keywords: ["elastalert2","es","elastic","告警","日志","钉钉"]
description: "elastalert2是一个日志告警服务，原理其实很简单，就是查询es数据，并触发告警信息。刚好最近在自建k8s和efk相关的内容，顺便更新到博客吧"
---

> elastalert2是一个日志告警服务，原理其实很简单，就是查询es数据，并触发告警信息。刚好最近在自建k8s和efk相关的内容，顺便更新到博客吧。

## 背景介绍
我们的日志通过efk套件采集、查询。
日志数据是存储在es内部的，所以我们的告警可以通过查询es数据来实现

## elastalert的使用
因为我们采用docker部署，因此我们优先写好配置文件，然后放到容器中

### 配置[参考链接](https://elastalert2.readthedocs.io/en/latest/ruletypes.html)

#### 目录结构
```yml
elastalert.yaml # 主配置文件
rules/ # 存在告警规则
  demo1.yaml # 单个告警规则的配置文件
```

#### elastalert.yaml文件内容
```yml
rules_folder: /opt/elastalert/rules
run_every:
  seconds: 10
buffer_time:
  minutes: 15
es_host: es的主机ip
es_port: 9200
writeback_index: elastalert_status
alert_time_limit:
  days: 2
```

#### demo1.yaml文件内容
```yml
name: "demo1"
type: "frequency"
index: "xxx-index*" # 查询日志所在的索引
is_enabled: true
num_events: 1 # 出现几次就告警
timeframe: 
  minutes: 1 # 1分钟 出现了 num_events次 匹配记录，就告警
realert: 
  minutes: 1 # 1分钟内忽略重复告警
timestamp_field: "@timestamp"
timestamp_type: "iso"
use_strftime_index: false
# 下面是在邮件中可能用到的字段
#alert_subject: "Test 测试alter_subject \n {} "
#alert_subject_args:
#  - "message"
#  - "@log_name"
alert_text_type: alert_text_only 
# 下面是告警模板
alert_text: | 
  > 正式环境 告警信息
  > 时间: {0}
  > 主机名: {1}
  > 触发次数: {2}
  > 匹配次数: {3}
  > 日志信息: {4}
alert_text_args: # 告警模板中用到的参数
  - log_time
  - host.name
  - num_hits
  - num_matches
  - message
filter:
  - query:
      query_string:
        query: "LEVEL: ERROR" # 告警查询语句
alert:
  - "dingtalk" # 告警类型
dingtalk_access_token: "asidoijdosajdsao" # 钉钉机器人访问地址
dingtalk_msgtype: "text" # 消息类型
```

### 部署使用
```bash
# docker命令
docker run -d --name elastalert --restart=always \
-v $(pwd)/elastalert.yaml:/opt/elastalert/config.yaml \
-v $(pwd)/rules:/opt/elastalert/rules \
jertel/elastalert2 --verbose
# 查看日志
docker logs -f elastalert
```

## 效果大概如下
```bash
> 正式环境 告警信息
> 时间: <MISSING VALUE>
> 主机名: mall-trade-service-7b5459d68b-fmqm2
> 触发次数: 1
> 匹配次数: 1
> 日志信息: |dubbo-client-idleCheck-thread-1|TID:N/A|ERROR|o.a.d.r.e.s.header.ReconnectTimerTask:51|doTask| [DUBBO] Fail to connect to HeaderExchangeClient 
```