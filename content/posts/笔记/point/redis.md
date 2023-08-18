---
title: redis
tags:
  - point
  - redis
date: 2023-07-06
lastmod: 2023-08-16
categories:
  - point
---

`redis` 通常用来做缓存数据库.

要点:

- 免费
- 性能高
- 缓存常用

### 运行

```shell
docker run --name ken-redis -d -p6379:6379 --restart=always -v /data/redis-data:/data redis --requirepass "didi"
```

### 操作手册

```shell
# 删除 ip地址的8号库的a_*
redis-cli -h ip地址 -a 密码 -n 8 keys 'a_*' | xargs redis-cli -h ip地址 -a 密码 -n 8 del

# 把0库所有内容移动到1库
redis-cli -a 密码 -n 0 keys '*' | xargs -I '{}' redis-cli -a didi -n 0 move '{}' 1
```
