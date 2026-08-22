---
title: grafana-pyroscope教程
tags:
  - blog
  - grafana
  - pyroscope
date: 2024-06-07
lastmod: 2024-06-26
categories:
  - blog
description: 
---

## 简介

`pyroscope` 是 [[笔记/point/grafana|grafana]] 的 [[笔记/point/持续性能分析|持续性能分析]] 工具.

## 内容

### 安装

到 [Release-GitHub](https://github.com/grafana/pyroscope/releases/latest) 下载 `pyroscope_1.6.0_linux_amd64.tar.gz`

```shell
tar xf pyroscope_1.6.0_linux_amd64.tar.gz
```

配置文件 `pyroscope.yaml`

```yaml
server:
  http_listen_port: 4040
  grpc_listen_port: 4041
memberlist:
  bind_port: 4042
storage:
  backend: s3
  s3:
    bucket_name: pyroscope
    endpoint: minio-api.kentxxq.com
    # insecure: true
    access_key_id: 你的id
    secret_access_key: 你的key
```

守护进程 `/etc/systemd/system/pyroscope.service`

```toml
[Unit]
Description=pyroscope
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
# 环境变量 $MY_ENV1
# Environment=MY_ENV1=value1
# Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
# EnvironmentFile=/path/to/environment/file1

WorkingDirectory=/root/tmp
ExecStart=/root/om/pyroscope/pyroscope -config.file=/root/om/pyroscope/pyroscope.yaml
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
```

- 端口: `4040`
- 验证 `curl -vvv localhost:4040/ready`
