---
title: openclaw手册
tags:
  - blog
date: 2026-03-10
lastmod: 2026-03-23
categories:
  - blog
description:
---

## 简介

openclaw 太火了，稍微玩一下。

## 安装/维护

[迁移 Migration Guide - OpenClaw](https://docs.openclaw.ai/install/migrating)

```shell
pnpm install -g openclaw@latest

# 初始化
openclaw onboard --install-daemon

# 重启，也会重启 gateway
openclaw daemon restart

# 升级
openclaw update

# 卸载
openclaw uninstall
```

## 使用/常用命令

启动服务 gateway

```shell
# gateway
# 启动
openclaw gateway
openclaw gateway start
# 关闭
openclaw gateway stop
# 状态
openclaw gateway status
openclaw gateway health

# 完整配置
openclaw configure 
```

 对话

```shell
# 进入命令行聊天框
openclaw tui
```

channel 配置

```shell
openclaw plugins list
openclaw channels list
# 重新配置
openclaw configure --section channels
```

状态监控

```shell
# 日志
openclaw logs --follow


# agent
openclaw agents list


# 模型
openclaw models list
openclaw models set qwen-max
openclaw models status
openclaw configure --section models


openclaw status
openclaw health
# 端口/配置检查
openclaw doctor
```
