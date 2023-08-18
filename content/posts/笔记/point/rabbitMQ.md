---
title: rabbitMQ
tags:
  - point
  - rabbitMQ
date: 2023-08-16
lastmod: 2023-08-16
categories:
  - point
---

`rabbitMQ` 是一个消息中间件.

要点:

- 开源免费
- 用户量较大

### 运行

```shell
docker run -d --rm -p 5672:5672 --hostname my-rabbit --name some-rabbit -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password rabbitmq:latest
```
