---
title: rabbitmq 手册
tags:
  - point
  - rabbitmq
date: 2025-09-04
lastmod: 2025-10-15
categories:
  - blog
---

## 手册

- 查看 mq 信息，含版本信息 `rabbitmqctl status`
- 查看启用的插件 `rabbitmq-plugins list`
- 查看插件目录 `rabbitmq-diagnostics environment | grep plugins`
    - 下载的插件
        - 去 github 下载插件，最好是和 mq 版本一致，例如 https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/tag/v3.12.0 匹配 mq 的 `3.12.2` 系列版本
        - 放在 `plugins_dir` 目录里
    - 如果有 `RABBITMQ_PLUGINS` 环境变量，配置成 `rabbitmq_auth_backend_ldap, rabbitmq_delayed_message_exchange` 的格式即可自动启用
