---
title: skywalking
tags:
  - point
  - skywalking
date: 2023-07-19
lastmod: 2023-07-19
categories:
  - point
---

`skywalking` 是一个链路追踪工具.

要点:

- 开源免费
- [[笔记/point/java|java]] 支持很好

## 安装

```shell
wget https://dlcdn.apache.org/skywalking/8.9.1/apache-skywalking-apm-8.9.1.tar.gz
tar -xzf apache-skywalking-apm-8.9.1.tar.gz
```

修改配置 `config/application.yml`,用 [[笔记/point/elastic|elastic]] 存储数据

```shell
storage:
  selector: ${SW_STORAGE:elasticsearch}
```

`bin/startup.sh` 启动后接入

```shell
mkdir -p /data/apm/
cd /data/apm
wget https://dlcdn.apache.org/skywalking/java-agent/8.9.0/apache-skywalking-java-agent-8.9.0.tgz
tar -xzf apache-skywalking-java-agent-8.9.0.tgz skywalking-agent

# java启动命令添加参数
-javaagent:/data/apm/skywalking-agent/skywalking-agent.jar -Dskywalking.agent.service_name=服务名 -Dskywalking.collector.backend_service=skywalking服务端:11800
```
