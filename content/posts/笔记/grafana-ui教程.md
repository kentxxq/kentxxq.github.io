---
title: grafana-ui教程
tags:
  - blog
  - grafana
  - 监控
  - devops
date: 2023-07-11
lastmod: 2023-08-02
categories:
  - blog
description: "[[笔记/point/grafana|grafana]] 的使用教程"
---

## 简介

`grafana-ui` 是 [[笔记/point/grafana|grafana]] 公司的 UI 展示组件.

## 安装

参考官网 [Install Grafana on Debian or Ubuntu | Grafana documentation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/),这个下载很慢, 建议挂上 [[笔记/linux命令与配置#代理 apt|apt代理]]

```shell
# 安装必要的包和签名key
apt install -y apt-transport-https software-properties-common wget
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
# 添加repo
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# 安装
apt update -y; apt install grafana -y

# 启动
systemctl enable grafana-server --now
# 默认密码 admin/admin
curl 127.0.0.1:3000
```

## 操作

### 重置密码

```shell
# 如果报错找不到默认配置 --homepath "/usr/share/grafana" <new_password>
grafana-cli admin reset-admin-password <new password>
```
