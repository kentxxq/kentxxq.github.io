---
title: gitea教程
tags:
  - blog
  - gitea
date: 2023-07-24
lastmod: 2023-08-02
categories:
  - blog
description: "[[笔记/point/gitea|gitea]] 支持了 [[笔记/point/CICD|CICD]],且兼容 github 的 actions, 这样就可以复用很多的脚本了.这里记录一下相关的搭建, 配置, 使用."
---

## 简介

[[笔记/point/gitea|gitea]] 支持了 [[笔记/point/CICD|CICD]],且兼容 github 的 actions, 这样就可以复用很多的脚本了.

这里记录一下相关的搭建, 配置, 使用.

## 内容

### 基础安装

```shell
mkdir -p gitea/{data,config}
cd gitea
chown 1000:1000 config/ data/
vim docker-compose.yml
```

 [[笔记/point/docker-compose|docker-compose]] 配置文件

```yml
version: "3"

services:
  server:
    image: gitea/gitea:1.20-rootless
    restart: always
    volumes:
      # 数据
      - ./data:/var/lib/gitea
      # 配置
      - ./config:/etc/gitea
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      # web端口
      - "3000:3000"
      # ssh端口
      - "2222:2222"
```

`config/app.ini` 的重要配置

```ini
[server]
# ssh clone的时候域名地址
SSH_DOMAIN = git.kentxxq.com
SSH_PORT = 2222
# http clone地址
ROOT_URL = https://git.kentxxq.com/
```

### CICD

#### 配置

[[笔记/point/gitea|gitea]] `config/app.ini` 配置

```ini
# 开启cicd.actions是从github拉取
[actions]
ENABLED=true
```

放到一个新文件夹 `runner` 里

```shell
mkdir runner
cd runner
```

准备配置文件 `config.yaml`

```shell
# 注册信息
docker run --entrypoint="" --rm -it gitea/act_runner:latest act_runner generate-config > config.yaml

# 因为需要下载一些包,例如setup-dotnet.但是无法联通,所以建议配置代理
runner:
  envs:
    HTTP_PROXY: ''
    HTTPS_PROXY: ''
    NO_PROXY: 'localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.test.example.com'
```

配置文件 `vim docker-compose.yml`

```yml
version: "3"
services:
  runner:
    image: gitea/act_runner:latest
    environment:
      CONFIG_FILE: /config.yaml
      GITEA_INSTANCE_URL: "https://git.kentxxq.com/"
      GITEA_RUNNER_REGISTRATION_TOKEN: "8awCQkLBA2BKjXex3bud331Sh5bW5NUbMtyJQSmL"
      GITEA_RUNNER_NAME: "runner1"
      # 默认 ubuntu-latest
      GITEA_RUNNER_LABELS: "test"
      HTTP_PROXY: ''
      HTTPS_PROXY: ''
      NO_PROXY: 'localhost,*.baidu.com'
    volumes:
      - ./config.yaml:/config.yaml
      - ./data:/data
      - /var/run/docker.sock:/var/run/docker.sock
```

#### 测试

`代码块根目录/.gitea/workflows/demo.yaml`

```shell
name: Gitea Actions Demo
run-name: ${{ gitea.actor }} is testing out Gitea Actions 🚀
on:
  # 无法手动
  # workflow_dispatch:
  push:

jobs:
  Explore-Gitea-Actions:
    # 这里和runner的标签匹配,可以多个[a,b]
    runs-on: ubuntu-latest 
    steps:
      - run: echo "🎉 The job was automatically triggered by a ${{ gitea.event_name }} event."
      - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by Gitea!"
      - run: echo "🔎 The name of your branch is ${{ gitea.ref }} and your repository is ${{ gitea.repository }}."
      - name: Check out repository code
        uses: actions/checkout@v3
      - run: echo "💡 The ${{ gitea.repository }} repository has been cloned to the runner."
      - run: echo "🖥️ The workflow is now ready to test your code on the runner."
      - name: List files in the repository
        run: |
          ls ${{ gitea.workspace }}          
      - run: echo "🍏 This job's status is ${{ job.status }}."
```

#### 重建 runner

1. 管理后台删除 runner
2. `docker compose down`, `docker compose up -d`

## 维护命令

修改 admin 的密码 `gitea admin user change-password --username myname --password asecurepassword`
