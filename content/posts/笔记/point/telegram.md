---
title: telegram
aliases:
  - tg
tags:
  - point
date: 2024-05-29
lastmod: 2024-10-24
categories:
  - point
---

`telegram` 是一个流行的聊天 app.

- 群组
- 频道
- 私聊

## 收益

- [Super Channels, Star Reactions and Subscriptions](https://telegram.org/blog/superchannels-star-reactions-subscriptions)

## 机器人

### 机器人推荐

- `get_id_bot` 拿到自己个人 id, 群组 id, 频道 id 等等
- [不可错过的Telegram神器：十个实用Telegram机器人介绍](https://www.salesmartly.com/blog/docs/essential-telegram-tools-top-10-bots-introduction#0865bfed04fce4418f2b30b10396a4ce)

### 创建机器人

1. 在 tg 搜索 [@BotFather](https://telegram.me/BotFather) 然后创建机器人后得到
    - 机器人名称 `pusher`, 用于你在添加到 group , channel 时候搜索
    - `apitoken` 用于发送消息
2. 在 group, channel 里添加搜索机器人 `pusher`

### 发送信息

- 自己的 `userid`:
    - 搜索 `get_id_bot` 机器人. 输入 `/start` 就会响应你的 id
    - 和你自己的叫人对话. `https://api.tg域名.org/bot<apiToken>/getUpdates` 就会有 `message.from.id`
- 群组的 `chatid`
    - 把 `get_id_bot` 机器人拉到群组. 和它说点什么, 就会响应 chatid
    - 和你自己的叫人对话. `https://api.tg域名.org/bot<apiToken>/getUpdates` 就会有 `message.chat.id`
- 频道
    - `public channel` 的话, `chat id` 就是频道的名字. 比如你的频道地址是 `t.me/kentxxq-public-pusher`, 你的 `chat id` 就是 `@kentxxq-public-pusher`
    - `private channel`
        - 和你自己的叫人对话. `https://api.tg域名.org/bot<apiToken>/getUpdates` 里通过私有频道名称, 找到这个 json 结构体, 就可以拿到 chatid
        - `@username_to_id_bot` 拉进来, 然后把 `邀请链接invite link` 发到群里. 机器人就会把群的 chat_id 发出来, 然后**移除@username_to_id_bot**
        - `get_id_bot` 拉到群里, 发个消息即可
