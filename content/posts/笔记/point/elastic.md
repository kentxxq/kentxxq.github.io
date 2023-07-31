---
title: elastic
tags:
  - point
  - elastic
date: 2023-07-19
lastmod: 2023-07-31
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
systemctl start elasticsearch
systemctl enable elasticsearch
curl -X GET "localhost:9200/_cat/health?v"
```
