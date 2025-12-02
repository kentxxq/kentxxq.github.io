---
title: token
tags:
  - point
date: 2025-01-22
lastmod: 2025-01-22
categories:
  - point
---

同时使用 accessToken 和 refreshToken

- accessToken 离线校验, 或者走 cache 缓存, 不走数据库, 性能好.  refreshToken 走数据库, 性能差
- 微服务下的风险隔离, 获取授权和获取资源分离开. 资源服务可以解析 at. 用户服务只能用 rt 访问.
- 多一道控制. at 签出以后, 只能加入到黑名单来失效. 然后由 rt 来控制生成下一次的 at, 这样权限变更就容易了
- 一些安全策略. refreshToken 只允许特定设备, ip 使用
