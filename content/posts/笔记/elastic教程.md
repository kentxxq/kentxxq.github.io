---
title: elastic教程
tags:
  - blog
  - elastic
date: 2024-04-22
lastmod: 2024-04-22
categories:
  - blog
description: 
---

## 简介

这里记录 [[笔记/point/elastic|elastic]] 的使用.

## 单点安装

```shell
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://mirrors.aliyun.com/elasticstack/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
apt update -y
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

## 集群部署

集群部署只是在 `elasticsearch.yml` 的配置上有区别. 启动以后会自动服务发现/加入集群/rebalance 数据.

```shell
vim /etc/elasticsearch/elasticsearch.yml

# 集群名称，所有节点保持一致，同一网段会自动发现
cluster.name: es-cluster
# 节点名称，一般为主机名 node-1、node-2、node-3
node.name: node-1
# 节点角色，master表示管理节点，data表示数据节点
node.roles: [master,data]
# 数据存放路径
path.data: /data/elasticsearch/data
# 日志存放路径
path.logs: /data/elasticsearch/logs
# 绑定监听IP
network.host: 0.0.0.0
# 设置端口
http.port: 9200
# 跨域相关设置
http.cors.enabled: true
http.cors.allow-credentials: true
http.cors.allow-origin: "*"
# 节点发现. 每个节点的ip
discovery.seed_hosts: ["10.1.43.74:9300","10.1.43.75:9300","10.1.43.76:9300"]
# 集群初始化Master节点，会在第一次选举中进行计算.. 可以作为master的节点
cluster.initial_master_nodes: ["10.1.43.74:9300","10.1.43.75:9300","10.1.43.76:9300"]
# 启用节点上Elastic Search的xpack安全功能
xpack.security.enabled: false
# discovery.type默认是多节点
# discovery.type: multi-node
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

## 常用命令

### 修改密码

```shell
cd /usr/share/elasticsearch/
# 自动生成密码
sudo bin/elasticsearch-setup-passwords auto
# 自定义密码
sudo bin/elasticsearch-setup-passwords interactive
```

### 备份/恢复

创建一个备份仓库:

```shell
# 创建一个backup仓库
# 配置了本地路径, 压缩, 1g分片, 备份和恢复速度限制(避免影响系统)
curl -XPOST '{ip}:9200/_snapshot/backup' -H  'Content-Type: application/json' -d 
'{ "type": "fs",  "settings": { "location": "/data/task/elk/elasticsearch-7.6.2/back", "compress": true, "chunk_size": "1g", "max_snapshot_bytes_per_sec": "50m", "max_restore_bytes_per_sec": "50m"}}'
```

备份:

```shell
# 创建一个名为rx_20220823的快照
curl -XPUT '{ip}:9200/_snapshot/backup/rx_20220823?wait_for_completion=true'

# 备份指定的索引 relalist_expert_group_member,relalist_expert_group_summary
curl -XPUT '{ip}:9200/_snapshot/backup/rx_20220823?wait_for_completion=true' -H 'Content-Type: application/json' -d '{"indices": "relalist_expert_group_member,relalist_expert_group_summary"}'
```

恢复

```shell
curl -XPOST '{ip}:9200/_snapshot/backup/rx_20220823/_restore' -H 'Content-Type: application/json' -d'{ "ignore_unavailable": true, "include_global_state": false }'
```

### 问题定位

参考 [Elasticsearch 集群故障排查及修复指南-腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1749462)

查看集群状态

```shell
curl -XGET 'http://{Elasticsearch_IP}:9200/_cluster/state?pretty'
```

查看有问题的索引

```shell
GET _cat/indices?v&health=red
GET _cat/indices?v&health=yellow
GET _cat/indices?v&health=green
```

查看问题原因, 分析

```shell
GET /_cat/shards?v&h=n,index,shard,prirep,state,sto,sc,unassigned.reason,unassigned.details&s=sto,index

# 关注state, unassigned.reason 字段
```

如果是 `allocation` 分片问题. 进一步分析 `my_index_003`.

```shell
GET /_cluster/allocation/explain
{
  "index": "my_index_003",
  "shard": 0,
  "primary": false
}

# explanation会有具体的原因
```

## 优化

### 写入优化

- 写入前副本为 0
- refresh_interval 设置为 -1，禁用刷新机制
- bulk 批量写入
- 恢复副本数和刷新间隔
- 尽量使用自动生成的 id

### 查询优化

- 避免 `*` 和 `?` 查询. 通配符查询会很慢
- `terms查询` 是多个词条的查询. 减少这种查询
- 基于时间创建索引
- 不断调整分片的分布
    - 默认主键分片
    - 可以设置字段范围分片
    - 字段 hash 分片

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

## 资料

- [ES详解 - 优化：ElasticSearch性能优化详解 | Java 全栈知识体系](https://pdai.tech/md/db/nosql-es/elasticsearch-y-peformance.html#%E5%87%8F%E5%B0%91%E5%89%AF%E6%9C%AC%E6%95%B0%E9%87%8F)
