---
title: telegram
aliases:
  - tg
tags:
  - point
date: 2024-05-29
lastmod: 2024-05-29
categories:
  - point
---

`telegram` 是一个流行的聊天 app.

- 群组
- 频道
- 私聊

## 机器人

- 获取自己的 `userid`:
    - 搜索 `get_id_bot` 机器人. 输入 `/start` 就会响应你的 id
    - 和你自己的叫人对话. `https://api.tg域名.org/bot<apiToken>/getUpdates` 就会有 `message.from.id`
- 获取群组的 `chatid`
    - 把 `get_id_bot` 机器人拉到群组. 和它说点什么, 就会响应 chatid
    - 和你自己的叫人对话. `https://api.tg域名.org/bot<apiToken>/getUpdates` 就会有 `message.chat.id`
