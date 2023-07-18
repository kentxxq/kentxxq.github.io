---
title: grafana-agent教程
tags:
  - blog
date: 2023-07-14
lastmod: 2023-07-17
categories:
  - blog
description: 
---

## 简介

`grafana-agent` 是 [[笔记/point/grafana|grafana]] 公司的产品之一, 用于接收 OTLP 数据.

## 安装

```shell
# 准备
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
# 安装
apt update -y; apt install grafana-agent -y
# 启用
systemctl enable grafana-agent; systemctl start grafana-agent;

# 9090端口被占用,重新设置端口,并允许外部机器访问
vim /etc/default/grafana-agent
CUSTOM_ARGS="-server.http.address=0.0.0.0:9091 -server.grpc.address=0.0.0.0:9092"
```
