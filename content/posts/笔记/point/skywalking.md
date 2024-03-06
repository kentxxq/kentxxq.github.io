---
title: skywalking
tags:
  - point
  - skywalking
date: 2023-07-19
lastmod: 2024-03-05
categories:
  - point
---

`skywalking` 是一个链路追踪工具.

要点:

- 开源免费
- [[笔记/point/java|java]] 支持很好

## 安装

### 二进制版本

```shell
wget https://dlcdn.apache.org/skywalking/8.9.1/apache-skywalking-apm-8.9.1.tar.gz
tar -xzf apache-skywalking-apm-8.9.1.tar.gz
```

修改配置 `config/application.yml`,用 [[笔记/point/elastic|elastic]] 存储数据

```shell
storage:
  selector: ${SW_STORAGE:elasticsearch}
```

`bin/startup.sh` 启动后接入

```shell
mkdir -p /data/apm/
cd /data/apm
wget https://dlcdn.apache.org/skywalking/java-agent/8.9.0/apache-skywalking-java-agent-8.9.0.tgz
tar -xzf apache-skywalking-java-agent-8.9.0.tgz skywalking-agent

# java启动命令添加参数
-javaagent:/data/apm/skywalking-agent/skywalking-agent.jar -Dskywalking.agent.service_name=服务名 -Dskywalking.collector.backend_service=skywalking服务端:11800
```

### docker 版本

```shell
# 启动后台，并且消费kafka内的数据
# 12800/http 11800/grpc
docker run --name oap --restart always -d -p11800:11800 -p12800:12800 -e SW_KAFKA_FETCHER=default -e SW_KAFKA_FETCHER_SERVERS="地址:9092" -e SW_STORAGE=elasticsearch -e SW_STORAGE_ES_CLUSTER_NODES=地址:9200 -e SW_ES_USER=admin -e SW_ES_PASSWORD="密码" apache/skywalking-oap-server:9.7.0

# 启动ui，对接后台
# 8080/http
docker run --name oap-ui --restart always -d -p8080:8080 -e SW_OAP_ADDRESS=http://10.0.0.40:12800 -e SW_ZIPKIN_ADDRESS=http://10.0.0.40:9412 apache/skywalking-ui:9.7.0
```

[[笔记/point/nginx|nginx]] 配置

```nginx
server {
    listen 80;
    server_name skywalking-ui-dev.kentxxq.com;
    return 301 https://$server_name$request_uri;
    access_log /usr/local/nginx/conf/hosts/logs/skywalking-ui-dev.kentxxq.com.log k-json;
}

server {
    listen 443 ssl http2;
    server_name skywalking-ui-dev.kentxxq.com;
    access_log /usr/local/nginx/conf/hosts/logs/skywalking-ui-dev.kentxxq.com.log k-json;

    # 普通header头,ip之类的
    include /usr/local/nginx/conf/options/normal.conf;
    # 证书相关
    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;

    location / {
        proxy_pass http://10.0.0.40:8080;
    }
}
```

### docker-compose

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: skywalking-oap-deployment
  namespace: tools
spec:
  replicas: 1
  selector:
    matchLabels:
      app: skywalking-oap
  template:
    metadata:
      labels:
        app: skywalking-oap
    spec:
      containers:
        - name: skywalking-oap
          image: apache/skywalking-oap-server:9.7.0
          env:
            - name: SW_STORAGE
              value: elasticsearch
            - name: SW_STORAGE_ES_CLUSTER_NODES
              value: 地址:9200
            - name: SW_ES_USER
              value: "admin"
            - name: SW_ES_PASSWORD
              value: "密码"
```
