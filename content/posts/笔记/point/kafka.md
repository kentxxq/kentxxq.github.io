---
title: kafka
tags:
  - point
date: 2025-09-03
lastmod: 2025-11-28
categories:
  - point
---

## k8s 单点

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kafka
spec:
  type: NodePort
  selector:
    app: kafka
  ports:
    - name: kafka
      port: 9092
    - name: controller
      port: 9093

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kafka
spec:
  serviceName: kafka
  replicas: 1
  selector:
    matchLabels:
      app: kafka

  template:
    metadata:
      labels:
        app: kafka
    spec:
      containers:
        - name: kafka
          image: apache/kafka:3.9.1
          imagePullPolicy: IfNotPresent

          ports:
            - name: kafka
              containerPort: 9092
            - name: controller
              containerPort: 9093

          env:
            # 节点 ID，单节点固定写 1
            - name: KAFKA_NODE_ID
              value: "1"

            # 单节点必须同时承担 broker + controller
            - name: KAFKA_PROCESS_ROLES
              value: "broker,controller"

            # Kafka 实际监听的端口
            - name: KAFKA_LISTENERS
              value: "PLAINTEXT://:9092,CONTROLLER://:9093"

            # Kafka 对客户端公告的地址（必须是 Pod DNS）
            - name: KAFKA_ADVERTISED_LISTENERS
              value: "PLAINTEXT://kafka-0.kafka.default.svc.cluster.local:9092"

            # 明文监听映射（KRaft 模式必需）
            - name: KAFKA_LISTENER_SECURITY_PROTOCOL_MAP
              value: "PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT"

            # 指定 controller 使用哪个 listener
            - name: KAFKA_CONTROLLER_LISTENER_NAMES
              value: "CONTROLLER"

            # 单节点 KRaft 的 quorum votor
            - name: KAFKA_CONTROLLER_QUORUM_VOTERS
              value: "1@kafka-0.kafka.default.svc.cluster.local:9093"

            # 持久化目录
            - name: KAFKA_LOG_DIRS
              value: "/var/lib/kafka/data"

            # 避免 KRaft 模式要求初始化元数据
            - name: KAFKA_AUTO_CREATE_TOPICS_ENABLE
              value: "true"

          volumeMounts:
            # 将 PV 挂载到 Kafka 日志目录
            - name: data
              mountPath: /var/lib/kafka

  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: nfs184
        resources:
          requests:
            storage: 10Gi

```

## 疑难杂症

### kafka-zookeeper

- [zookeeper：Unexpected exception, exiting abnormally ：：java.io.EOFException - 香吧香 - 博客园](https://www.cnblogs.com/zjdxr-up/p/18233329)
    - 通常是因为 `log.0`, `snap.0000000` 文件内容异常
    - 我的磁盘满过一次，导致输入无法写入。删掉 `log.0` 后重启成功

### kafka

- 磁盘满过一次，会导致 kafka 判定磁盘无法写入
    - 删除 `data` 目录下的 `.lock文件`，重启容器（如果有多个实例，都需要删除）
