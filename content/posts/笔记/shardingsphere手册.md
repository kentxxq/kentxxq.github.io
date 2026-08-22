---
title: shardingsphere手册
tags:
  - blog
date: 2025-12-15
lastmod: 2025-12-15
categories:
  - blog
description:
---

## 简介

记录使用 [shardingsphere](https://shardingsphere.apache.org/)

## 配置文件

`database-1.yaml` 用于配置第一个分片库

```yaml
databaseName: sharding_enterprise

dataSources:
  ds_0:
    url: jdbc:mysql://mysql:3306/database?useSSL=false
    username: fake_user
    password: fake_password
    connectionTimeoutMilliseconds: 30000
    idleTimeoutMilliseconds: 60000
    maxLifetimeMilliseconds: 1800000
    maxPoolSize: 50
    minPoolSize: 1

rules:
- !SHARDING
  tables:
    t_organization:
      actualDataNodes: ds_0.t_organization_${0..19}
      tableStrategy:
        standard:
          shardingColumn: eid
          shardingAlgorithmName: t_organization_inline
      keyGenerateStrategy:
        column: eid
        keyGeneratorName: snowflake
  shardingAlgorithms:
    t_organization_inline:
      type: INLINE
      props:
        algorithm-expression: t_organization_${eid % 20}
  keyGenerators:
    snowflake:
      type: SNOWFLAKE
```
