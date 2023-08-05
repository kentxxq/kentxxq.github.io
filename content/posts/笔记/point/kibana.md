---
title: kibana
tags:
  - point
  - kibana
date: 2023-07-26
lastmod: 2023-08-02
categories:
  - point
---

`kibana` 是一个 ui-web, 通常用来配合展示日志信息

## 安装

[官方安装文档]( https://www.elastic.co/guide/en/kibana/8.9/install.html)

- [deb包安装](https://www.elastic.co/guide/en/kibana/8.9/deb.html)

```shell
apt install kibana -y

vim /etc/kibana/kibana.yml			#修改
server.port: 5601
server.host: "0.0.0.0"      
elasticsearch.hosts: ["http://EFK:9200"]
i18n.locale: "zh-CN"          #这是显示中文

systemctl enable kibana --now
```

- [docker安装](https://www.elastic.co/guide/en/kibana/8.9/docker.html)
