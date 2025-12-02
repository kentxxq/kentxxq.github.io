---
title: redis
tags:
  - point
  - redis
date: 2023-07-06
lastmod: 2025-11-27
categories:
  - point
---

`redis` 通常用来做缓存数据库.

要点:

- 免费
- 性能高
- 缓存常用

## 安装

### 二进制

```shell
# 密码在 /usr/local/redis/redis.conf 添加 requirepass fake_password
./redis-server /usr/local/redis/redis.conf --port 6379 --bind 0.0.0.0 --daemonize yes
```

###  容器

```shell
docker run --name ken-redis -d -p6379:6379 --restart=always -v /data/redis-data:/data redis --requirepass "fake_password"
```

### k8s 单点

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-nodeport
spec:
  type: NodePort
  selector:
    app: redis
  ports:
    - port: 6379           # Service 内部端口
      targetPort: 6379     # Pod 容器端口
      nodePort: 30037      # NodePort，指定范围 30000-32767，可选，不指定会自动分配

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  serviceName: "redis"      # 对应 headless service
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:7
          args: ["redis-server", "--save", "60", "1", "--loglevel", "warning", "--requirepass", "fake_password"]
          ports:
            - containerPort: 6379
          volumeMounts:
            - name: redis-data
              mountPath: /data
  volumeClaimTemplates:
    - metadata:
        name: redis-data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: sc-nfs14
        resources:
          requests:
            storage: 1Gi
```

## 操作/配置

### 操作手册

```shell
# 删除 ip地址的8号库的a_*
redis-cli -h ip地址 -a 密码 -n 8 keys 'a_*' | xargs redis-cli -h ip地址 -a 密码 -n 8 del

# 把0库所有内容移动到1库
redis-cli -a 密码 -n 0 keys '*' | xargs -I '{}' redis-cli -a didi -n 0 move '{}' 1
```
