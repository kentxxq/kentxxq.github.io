---
title: elastic
tags:
  - point
  - elastic
date: 2023-07-19
lastmod: 2024-04-11
categories:
  - point
---

`elastic` 是一个分布式搜索和分析引擎. 适用于搜索, 分析.

AWS 开源了 [OpenSearch](https://github.com/opensearch-project/OpenSearch),是 elastic 的分支. 因为 elastic 不允许云服务商使用它来提供服务.

要点:

- 免费
- 日志常用 ELK/EFK 中的 E 就是 elastic
- 分词搜索功能

## 安装

```shell
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://mirrors.aliyun.com/elasticstack/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
apt install elasticsearch

# 配置文件
vim /etc/elasticsearch/elasticsearch.yml
#单节点添加
network.host: 0.0.0.0
discovery.type: single-node

# 配置 /etc/sysctl.conf
vm.max_map_count = 262144
sysctl -p

# 启动并验证
systemctl enable elasticsearch --now
curl -X GET "localhost:9200/_cat/health?v"
```

## 启动

[[笔记/point/Systemd|Systemd]] 守护进程

```toml
[Unit]
Description=es服务
Documentation=elastic文档
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
User=es
Environment=ES_JAVA_OPTS="-Xms4g -Xmx4g"
WorkingDirectory=/home/es/elasticsearch-7.17.3
ExecStart=/home/es/elasticsearch-7.17.3/bin/elasticsearch
# 总是间隔30s重启,配合StartLimitIntervalSec实现无限重启
RestartSec=30s 
Restart=always
# 相关资源都发送term后,后发送kill
KillMode=mixed
# 最大文件打开数不限制
LimitNOFILE=infinity
# 子线程数量不限制
TasksMax=infinity


[Install]
WantedBy=multi-user.target
Alias=es.service
```

[[笔记/point/supervisor|supervisor]] 守护进程

```toml
[program:es]
command = /home/es/elasticsearch-7.17.3/bin/elasticsearch

environment=ES_JAVA_OPTS="-Xms4g -Xmx4g"

user = es

# 自动重启
autorestart = true
# 启动失败的尝试次数
startretries = 3
# 进程20s没有退出，则判断启动成功
startsecs = 20

# 标准输出的文件路径
stdout_logfile =  /data/logs/es-stdout.log
# 日志文件最大大小
stdout_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stdout_logfile_backups = 5


# 标准输出的文件路径
stderr_logfile =  /data/logs/es-stderr.log
# 日志文件最大大小
stderr_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stderr_logfile_backups = 5
```

## 工具

[infini-console](https://infinilabs.cn/en/docs/latest/console/) 可以帮助我们管理多个 es 集群, 查询修改等操作.

```yml
version: "3.5"

services:
  infini-console:
    image: infinilabs/console:latest
    ports:
      - 9000:9000
    container_name: "infini-console"
```
