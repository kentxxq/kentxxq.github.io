---
title: RSS使用
tags:
  - blog
date: 2023-09-11
lastmod: 2024-04-17
categories:
  - blog
description: 
---

## 简介

## 为什么需要 RSS

信息茧房:

- [男性和女性的评论区不一样？算法连这也不放过 - cnBeta.COM 移动版](https://m.cnbeta.com.tw/view/1382883.htm)

## RSS 客户端

- 移动端
    - [yang991178/fluent-reader-lite](https://github.com/yang991178/fluent-reader-lite) 所有平台
    - 安卓客户端 [Releases · Ashinch/ReadYou (github.com)](https://github.com/Ashinch/ReadYou)
    - 苹果 [Ranchero-Software/NetNewsWire: RSS reader for macOS and iOS. (github.com)](https://github.com/Ranchero-Software/NetNewsWire)
- [万物皆可RSSHub](https://docs.rsshub.app/routes/bbs#v2ex-zui-re-%2F-zui-xin-zhu-ti)
- 桌面端
    - 跨平台 [raven-reader](https://github.com/hello-efficiency-inc/raven-reader)
    - 跨平台 [fluent-reader]( https://github.com/yang991178/fluent-reader )
    - 苹果 [NetNewsWire](https://github.com/Ranchero-Software/NetNewsWire)
- 自部署 web 端
    - [commafeed](https://github.com/Athou/commafeed)
    - [FreshRSS](https://github.com/FreshRSS/FreshRSS), php 写的
    - [miniflux](https://github.com/miniflux/v2), go 写的
    - [selfoss](https://selfoss.aditu.de/)
    - [nkanaev/yarr](https://github.com/nkanaev/yarr)
    - [Tiny Tiny RSS (tt-rss.org)](https://tt-rss.org/), php 写的
    - Grafana 也可以订阅 rss 并展示 [RSS/Atom plugin for Grafana | Grafana Labs](https://grafana.com/grafana/plugins/volkovlabs-rss-datasource/?tab=installation)
- 主流平台
    - Feedly, 老牌生态好. 100 feed, 3 个文件夹. 内容列表嵌入广告
    - [Inoreader – Build your own newsfeed](https://www.inoreader.com/zh-hans/)
        - Pc 是站点, 有移动端.
        - 内容嵌入广告.
        - 功能比 feedly 多.
        - 移动端没有底部导航栏, 使用不习惯 (不方便)
    - [NewsBlur](https://newsblur.com/) 样式比较老, 64 个站点订阅. 不订阅一次只能看 3 篇文章, 可以专注, 但不实用....
    - [reeder苹果收费](https://reederapp.com/) 苹果平台最好的
    - [Feeder](https://feeder.co/), 200 免费订阅, 无广告
    - [QiReader](https://www.qireader.com/) 30 个订阅有点少
    - [FeedMe (RSS Reader | Podcast) - Apps on Google Play](https://play.google.com/store/apps/details?id=com.seazon.feedme&hl=en_US) 可以使用 feedly 账号.. 仅安卓
- 可参考教程
    - [重新捡起RSS：RSSHub + FreshRSS 建立信息流 (l3zc.com)](https://l3zc.com/2023/07/rsshub-freshrss-information-flow/)
    - [用Miniflux自建轻便好用的RSS服务 (zoomyale.com)](http://zoomyale.com/2018/miniflux_rss/)

## RSS 订阅源

- ithome
- [快科技(原驱动之家)--科技改变未来 (mydrivers.com)](https://rss.mydrivers.com/)
- [奇客资讯网](https://www.solidot.org/)
- b 站每周必看 `https://rsshub.app/bilibili/weekly`
- 知乎热榜 `https://rsshub.app/zhihu/hotlist`
- 捕蛇者说
- 二分电台
- 代码之外

因为记性不好, 我不喜欢的也记录一下

- 忽左忽右
- 大内密探
- 谐星聊天会

## 临时记录

### iphone

feedly 同步设置

```
b 站配置在浏览器打开. 列表点击=>打开网页=>app 内打开
电脑端在 b 站页面打开
美团
金山词霸ok
```

Feeder 不能为每个内容设置打开方式...

> 可以订阅 twitter, 但是需要收费. 例如订阅源直接添加 `https://www.twitter.com/elonmusk`

```
电脑用 full 模式,更好用.
金山词霸兼容不好
美团 ok
b 站 ok

手机用 full
b站ok
美团ok
金山词霸兼容不好
```

NetNewsWire

```shell
b站点链接直接跳转
默认是simple模式
同步有一些问题,对接feedly,不如feedly好用
```
