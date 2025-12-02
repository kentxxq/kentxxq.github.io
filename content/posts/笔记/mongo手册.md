---
title: mongo手册
tags:
  - blog
date: 2025-09-25
lastmod: 2025-11-28
categories:
  - blog
description: 
---

## 简介

记录一下我的日常 [[笔记/point/mongodb|mongodb]] 操作。持续更新

## 集群图

![[附件/mongo分片集群.excalidraw.svg]]

## k8s 单点

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mongo
  namespace: default
spec:
  ports:
    - name: tcp
      protocol: TCP
      port: 27017
      targetPort: 27017
  selector:
    app: mongo
  type: NodePort

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
  namespace: default
spec:
  serviceName: mongo
  replicas: 1
  selector:
    matchLabels:
      app: mongo
  template:
    metadata:
      labels:
        app: mongo
    spec:
      # pve 需要把 cpu 硬件模式改成 host，然后给 node 打上标签，调度到特定机器
      nodeSelector:
        cpu: host
      containers:
        - name: mongo
          image: nexus.weilaishuke.com/ops/mongo:7.0.26
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 27017
          env:
            - name: MONGO_INITDB_ROOT_USERNAME
              value: "fake_username"
            - name: MONGO_INITDB_ROOT_PASSWORD
              value: "fake_password"  # 修改成安全密码
          volumeMounts:
            - name: mongo-data
              mountPath: /data/db
  volumeClaimTemplates:
    - metadata:
        name: mongo-data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: nfs184
        resources:
          requests:
            storage: 20Gi
```

## 工具

### 命令行工具 - 全览

- mongod 服务本体
- mongos Sharded Cluster 路由器
- mongosh 交互客户端
- 其他
    - mongostat 实时性能监控工具
    - mongotop 实时查看各集合读写情况
    - mongodump 导出
    - mongostore 恢复

###  导入导出 mongodump / mongostore

```shell
# 导出库db_a
mongodump -d db_a

# 从db_a文件夹导入库
mongorestore -d db_a db_a/

# 恢复单个 mongodb 集合
mongorestore --db db_target --collection 集合名 /path/to/dbname/集合名.bson
```

## 内部操作

### 连接

建议使用 [[笔记/point/datagrip|datagrip]] 或 navicat 之类的工具连接，可以执行 db 命令

```shell
# 查看集群，分片情况
db.adminCommand({ listShards: 1 })
```

mongosh 连接用的很少

```shell
mongosh -h xxx.com -u 用户名 -p 密码
use 数据库名;
```

###  性能分析

- 参考 [阿里云文档](https://help.aliyun.com/zh/mongodb/use-cases/troubleshoot-the-high-cpu-utilization-of-apsaradb-for-mongodb)
    - `db.currentOp()` 查看执行中的异常会话
        - `db.killOp(opid)` 干掉会话
        - `secs_running` 执行时间是否过长?
        - `ns` 操作的集合 (表)
        - `op` 操作类型 (curd 之一)
    - 慢日志
        - 有全表扫描, 索引正确, 数据排序?

###  profiling 操作审计

原理是通过开启 oplog，记录操作记录。原理把操作记录到一个集合里，类似与 mysql 的慢查询表

```shell
# 查询是否开启 profiling
# slowms 超过这个数值就是慢查询
# was 开启状态 0 是关闭，2 是开启
db.getProfilingStatus()

# 关闭
db.setProfilingLevel(0)
# 开启
db.setProfilingLevel(2)

# 集合管理
# 查看 system.profile 集合信息
db.getCollectionInfos({ name: "system.profile" })
# 查看统计信息
db.system.profile.stats()
# 修改 capped collection 大小
db.runCommand({
  collMod: "system.profile",
  cappedSize: 10 * 1024 * 1024 // 10MB
})
#  如果想重新创建 profile 集合
db.system.profile.drop()
db.createCollection("system.profile", { capped: true, size: 10*1024*1024 })


# 查询
# 最近 20 条
db.system.profile.find().sort({ ts: -1 }).limit(20)
# 查询慢查询，例如执行时间大于 500ms 的操作
db.system.profile.find({ millis: { $gt: 500 } }).sort({ ts: -1 })
# 查看某个用户操作
db.system.profile.find({ user: "appUser" }).sort({ ts: -1 })
# 查询某个集合的操作
db.system.profile.find({ ns: "mydb.users" }).sort({ ts: -1 })

```

### 会话设置

快速操作 `mongo --eval 'db.adminCommand({getParameter: "*", transaction: 1})'`

```shell
// 或者查看所有相关参数
db.adminCommand({getParameter: "*", transaction: 1})

// 设置事务最大生命周期（秒）
db.adminCommand({ setParameter: 1, transactionLifetimeLimitSeconds: 3600 }) 

// 查看当前设置 
db.adminCommand({ getParameter: 1, transactionLifetimeLimitSeconds: 1 })
```

### 增删改查

```shell
# 1. 切换/创建数据库
use demoDB

# 2. 创建集合（collection）并插入一条文档
db.demoCollection.insertOne({
    name: "Kent",
    age: 30,
    hobby: ["coding", "reading"]
})

# 3. 插入多条文档
db.demoCollection.insertMany([
    { name: "Alice", age: 25, hobby: ["music", "travel"] },
    { name: "Bob", age: 28, hobby: ["sports"] }
])

# 4. 查询集合内容
db.demoCollection.find().pretty()

# 5. 查看集合信息
db.demoCollection.stats()
```

### 磁盘清理

```shell
# 列出所有数据库信息
db.adminCommand({ listDatabases: 1 })

# 列出每个库的大小
db.adminCommand({ listDatabases: 1 }).databases.forEach(d =>  
  print(d.name + ": " + (d.sizeOnDisk / 1024 / 1024 / 1024).toFixed(2) + " GB")  
)


# 查询库信息
use 特定的 db
# 查询空间占用，单位 GB
# fsUsedSize 磁盘使用量 
# totalSize 集合实际占用大小
# fsUsedSize比totalSize大了很多，说明有很多空间碎片
db.stats(1024*1024*1024)

# 查询库的各个集合磁盘使用量
var stats = [];
db.getCollectionNames().forEach(function(c) {
    var s = db.getCollection(c).stats();
    stats.push({
        collection: c,
        dataSizeGB: (s.size / (1024*1024*1024)).toFixed(2),
        storageSizeGB: (s.storageSize / (1024*1024*1024)).toFixed(2),
        totalSizeGB: (s.totalSize / (1024*1024*1024)).toFixed(2),
        indexSizeGB: (s.totalIndexSize / (1024*1024*1024)).toFixed(2)
    });
});
stats.sort(function(a, b) {
    return b.storageSizeGB - a.storageSizeGB;
});
printjson(stats);


# 删除集合数据不会释放空间
db.table.deletemany()
# 会释放空间。通常 mongo 会自动创建表，所以删表也问题不大
db.table.drop()
```

重建数据库

```shell
# 先停掉mongo，操作 repair 再启动服务
mongod --dbpath /var/lib/mongodb --repair --repairDatabase yourdb
```

导出=》删除库=》导入库

```shell
mongodump --db yourdb --out /tmp/backup

use yourdb
db.dropDatabase()

mongorestore /tmp/backup/yourdb
```
