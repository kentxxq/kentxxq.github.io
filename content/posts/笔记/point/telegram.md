---
title: telegram
aliases:
  - tg
tags:
  - point
date: 2024-05-29
lastmod: 2025-02-25
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

## 账号相关

### 封禁/限制

- 原因
    - 大量转发, 系统判定
    - 被举报
    - 滥用 api
    - 新账号限制必须是共同联系人
- 操作
    - 机器人
        - [Spam FAQ](https://telegram.org/faq_spam#q-what-do-i-do-now)
        - 找 `@SpamBot` 说明情况
        - 快的话等半小时解除, 会回复你 `bird`. 找个可用的账号测试一下私聊即可. 否则等待 1 周再看情况
    - 发邮件 [Site Unreachable](https://zhuanlan.zhihu.com/p/665245035)
- 其他
    - 封禁期删号重新注册也没用
    - 更换手机号, 然后注销. 再次用手机号注册 [记一次Telegram解除限制和搭建私聊机器人 – Hoyue の 自留地](https://hoyue.fun/telegram_spam_bot.html)
    - 可以间隔一段时间, 就来一次删除账号 [教你如何快速彻底注销Telegram账号并重新使用同号注册 - 忆学社](https://www.zeelis.com/t/432.html)

## telegraph

`telegraph` 是 telegram 推出的匿名博客平台. 地址 [telegra.ph](https://telegra.ph)

- 匿名, 不需要登录
- 清空浏览器缓存就会丢失编辑权限
- 可以绑定 telegram 账号
    - 添加 telegraph 机器人
    - `account name` 是帮助作者自己多个账号切换, 管理不同文章
    - `author name` 是文章公开的作者名, 对所有人公开
    - `profile link` 点击 `author name` 跳转到对应的地址, 例如 telegram 用户, 或者 group, channel

## fragment

`fragment` 是 tg 推出的数字货币平台. 提供对应的数字商品

- username 用来制作自己的 tg 短链
- number 用来登录自己的匿名账号
- stars 用来在 tg 打赏和付费
- premium 是 tg 的会员服务
- ads 在频道上投放广告, 挂上广告赚钱

## 客户端版本

- 建议用官方客户端
- premium 建议用 web / desktop 支付, 避免被多收费
- ios 会限制内容, 需要到 web 或者 desktop 端取消限制

## 百科全书

- 机器人推荐
    - [机器人推荐 \| TGwiki - Telegram知识库](https://tgnav.github.io/tgwiki/robot.html#%E5%AE%9E%E7%94%A8%E6%9C%BA%E5%99%A8%E4%BA%BA)
- 邮箱登录
    - [邮箱登录 \| TGwiki - Telegram知识库](https://tgnav.github.io/tgwiki/emaillogin.html)
    - [据说 telegram 启用邮箱登录的方法售价四位数了？ 我来免费教大家 - V2EX](https://www.v2ex.com/t/1037251)
- 新闻频道
    - https://t.me/cnbeta_com  
    - https://t.me/solidot  
    - https://t.me/CE_Observe  
    - https://t.me/TestFlightCN
