---
title: API规范
tags:
  - blog
date: 2024-07-04
lastmod: 2024-08-28
categories:
  - blog
description: 
---

## 简介

这里放我自己的 API 规范, 也是我在日常开发中的考量和实践.

## 响应格式

```json
{
    "code": 20000,
    "message": "登录成功",
    // "data":[]
    "data": {
        "token": ""
        // age : null
    }
}
```

- `http状态码`: 永远都是 `200`
    - 简化异常判断
    - http 状态码非常多, 每个人的理解都不一样. 放到应用内部进行规范. 减少歧义,减少心智负担
- `code`:
    - `20000` 正常
    - `50000` 异常
- `message`: 都可以自定义内容.
    - 默认 `操作成功`
    - 默认 `操作失败`
- `data`
    - data 可以是数组 , 数值, bool 或对象
    - 可以不返回没有的字段. 例如用户没有设置年龄, 那个 `age` 字段就可以不传输

## 响应内容

### 分页

```json
{
    "code": 20000,
    "message": "获取数据成功",
    "data": {
        "pageIndex": 2,
        "pageSize": 2,
        "pageData": ["1","2"],
        "totalCount": 320,
    }
}
```

- 传入参数
    - `pageIndex` 当前页码
    - `pageSize` 每页大小, 同时返回 pageSize 个数据
- 返回数据
    - `pageIndex` 同上
    - `pageSize` 同上
    - `pageData` 数据
    - `totalCount` 数据总量

### CURD

下面的操作返回就是 `data` 的值 (不要存放在 data 对象内)

- `insert`
    - http-post
    - 返回创建的实体. 和查询实体返回的结果一致
    - 创建多个实体, 返回实体列表
- `update`
    - http-post
    - 修改返回修改后的实体. 和查询实体返回的结果一致
    - **不建议**提供同时修改多个对象的操作, 应该改成特定功能. 例如把多个用户变成管理员, 直接使用特定接口, 而不是提交每隔用户的信息.
    - 代码
        - 控制层处理 http 请求, 输入验证, 返回请求
        - service 判断是否属于 xx 用户. 在这里把 ro 对象映射到 model
- `delete`
    - http-post
    - 返回 `true/false`

## 时间

- 前后端接口传输, 使用 `iso8601` 示例 `2024-08-28T16:35:39.0952381+08:00`
- 后端代码内都使用 `DateTimeOffset`
- 数据库存放 `Utc` 时间
