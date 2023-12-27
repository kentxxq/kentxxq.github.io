---
title: grafana-ui教程
tags:
  - blog
  - grafana
  - 监控
  - devops
date: 2023-07-11
lastmod: 2023-12-27
categories:
  - blog
description: "[[笔记/point/grafana|grafana]] 的使用教程"
---

## 简介

`grafana-ui` 是 [[笔记/point/grafana|grafana]] 公司的 UI 展示组件.

## 安装

### 服务安装

参考官网 [Install Grafana on Debian or Ubuntu | Grafana documentation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/),这个下载很慢, 建议挂上 [[笔记/linux命令与配置#代理 apt|apt代理]]

```shell
# 安装必要的包和签名key
apt install -y apt-transport-https software-properties-common wget
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
# 添加repo
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
# 安装, grafana-enterprise是企业版
apt update -y; apt install grafana -y

# 启动
systemctl enable grafana-server --now
# 默认密码 admin/admin
curl 127.0.0.1:3000
```

### nginx 配置

配置 [[笔记/point/nginx|nginx]] 转发访问

```nginx
server {
    listen 80;
    server_name om-grafana.chinnshi.com;
    return 301 https://$server_name$request_uri;
    access_log /usr/local/nginx/conf/hosts/logs/om-grafana.kentxxq.com.log k-json;
}

server {
    listen 443 ssl http2;
    server_name om-grafana.chinnshi.com;
    access_log /usr/local/nginx/conf/hosts/logs/om-grafana.kentxxq.com.log k-json;

    include /usr/local/nginx/conf/options/normal.conf;
    include /usr/local/nginx/conf/options/ssl_chinnshi.conf;

    location / {
        proxy_pass http://127.0.0.1:3000;
    }
}
```

## 操作

### 重置密码

```shell
# 如果报错找不到默认配置 --homepath "/usr/share/grafana" <new_password>
grafana-cli admin reset-admin-password <new password>
```
