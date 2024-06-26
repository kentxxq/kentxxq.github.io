---
title: grafana-agent教程
tags:
  - blog
  - grafana
  - grafana-agent
date: 2023-07-14
lastmod: 2024-06-17
categories:
  - blog
description: "grafana-agent 是 [[笔记/point/grafana|grafana]] 公司的产品之一, 用于接收 OTLP 数据."
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
systemctl enable grafana-agent --now

# 9090端口被占用,重新设置端口,并允许外部机器访问
vim /etc/default/grafana-agent
CUSTOM_ARGS="-server.http.address=0.0.0.0:9091 -server.grpc.address=0.0.0.0:9092"
```

## 已弃用, 转 alloy

[官方已弃用grafana-agent](https://grafana.com/docs/agent/latest/),请使用 [[笔记/grafana-alloy教程|grafana-alloy]] 替代.
