---
title: apisix
tags:
  - point
date: 2025-07-31
lastmod: 2025-07-31
categories:
  - point
---

- 复制 ecs 制作多节点集群的时候, 需要修改 `/usr/local/apisix/conf/apisix.uid`, 例如 `22e987af-0aae-4f47-a04f-936cd71f130d`
- shell 操作 api

```shell
# 修改路由
curl http://127.0.0.1:9180/apisix/admin/routes -H "X-API-KEY: X-API-KEY" -X PUT -i  -d '
{   
    "id":"UserService_stage",
    "uri": "/user/*",
    "name":"UserService_stage",
    "host":"api-stage.chinnshi.com",
    "upstream": {
        "service_name": "ShiniUser.http",
        "type": "roundrobin",
        "discovery_type": "nacos",
        "discovery_args": {
          "namespace_id": "b66e2c35-3ae8-49bb-8247-13ed2a63d4de"
        }
    }
}'
```
