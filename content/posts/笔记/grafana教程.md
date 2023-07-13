---
title: grafana教程
tags:
  - blog
  - grafana
date: 2023-07-11
lastmod: 2023-07-11
categories:
  - blog
description: "[[笔记/point/grafana|grafana]] 的使用教程"
---

## 简介

[[笔记/point/grafana|grafana]] 的使用教程

## 安装

参考官网 [Install Grafana on Debian or Ubuntu | Grafana documentation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/)

```shell
# 安装必要的包和签名key
apt install -y apt-transport-https
apt install -y software-properties-common wget
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
# 添加repo
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# 安装
apt update
apt install grafana
```
