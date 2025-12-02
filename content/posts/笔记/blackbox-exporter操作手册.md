---
title: blackbox-exporter操作手册
tags:
  - blog
  - devops
date: 2023-12-28
lastmod: 2023-12-28
categories:
  - blog
description: 
---

## 简介

`blackbox-exporter` 是一个 [[笔记/point/prometheus|prometheus]] 生态的产品，通过采集 http、tcp、dns 等等信息，暴露相关的指标给 [[笔记/point/prometheus|prometheus]]。

项目开源 [在这里](https://github.com/prometheus/blackbox_exporter)

## 安装

1. 下载 [Releases · prometheus/blackbox\_exporter](https://github.com/prometheus/blackbox_exporter/releases)
2. `tar xf xxx.tar.gz` 解压
3. 配置 [[笔记/point/Systemd|Systemd]] 守护配置 `/etc/systemd/system/blackbox_exporter.service`

    ```toml
    [Unit]
    Description=blackbox_exporter
    After=network.target
    
    [Service]
    User=root
    Type=simple
    ExecStart=/blackbox_exporter/blackbox_exporter --config.file=/blackbox_exporter/blackbox.yml
    Restart=on-failure
    
    [Install]
    WantedBy=multi-user.target
    Alias=blackbox.service
    ```

4. `systemctl daemon-reload ; systemctl enable blackbox_exporter --now`
5. `ss -ltnp | grep 9115` 验证服务端口启动成功

## 使用

### 配置采集

编辑 [[笔记/point/prometheus|prometheus]] 配置文件，添加采集任务

```yaml
scrape_configs:
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://prometheus.io    
        - https://prometheus.io   
        - http://example.com:8080
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115
```

- 采集使用了 `http_2xx` 模块，模块和模块名在 blackbox_exporter 的配置文件中定义
- 采集了 3 个网站的信息
- relabel
    1. 把站点地址存放到 target 参数中。这样 prometheus 请求 blackbox 就会带上域名信息，blackbox 才知道要采集哪个站点
    2. 把站点地址写入到 `instance` 这个 label 中，方便把指标进行分类
    3. 把 prometheus 实际请求的地址改成 blackbox 的服务地址

### 展示

使用 [[笔记/grafana-ui教程|grafana-ui]] 进行指标的展示。对比了一下，[这个](https://grafana.com/grafana/dashboards/13659-blackbox-exporter-http-prober/) 简单可用。

![[附件/blackbox监控图.png]]

## 相关文档

- [Blackbox Exporter (HTTP prober) | Grafana Labs](https://grafana.com/grafana/dashboards/13659-blackbox-exporter-http-prober/)
- [网络探测：Blackbox Exporter - prometheus-book](https://yunlzheng.gitbook.io/prometheus-book/part-ii-prometheus-jin-jie/exporter/commonly-eporter-usage/install_blackbox_exporter#yu-prometheus-ji-cheng)
- [GitHub - prometheus/blackbox\_exporter: Blackbox prober exporter](https://github.com/prometheus/blackbox_exporter)
