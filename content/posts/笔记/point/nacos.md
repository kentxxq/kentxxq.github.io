---
title: nacos
tags:
  - point
  - nacos
date: 2023-08-16
lastmod: 2025-11-28
categories:
  - point
---

`nacos` 是一个配置, 注册中间件.

要点:

- 免费, 开源
- 阿里巴巴支持, 且有商业版

### [[笔记/point/docker-compose|docker-compose]] 运行验证

参考链接 [Nacos Docker 快速开始](https://nacos.io/zh-cn/docs/v2/quickstart/quick-start-docker.html)

```shell
git clone https://github.com/nacos-group/nacos-docker.git
cd nacos-docker
docker compose -f example/standalone-derby.yaml up
```

上面的版本有 [[笔记/point/prometheus|prometheus]] 和 [[笔记/point/grafana|grafana]],去掉以后加鉴权.

```yml
version: "2"
services:
  nacos:
    image: nacos/nacos-server:latest
    container_name: nacos
    environment:
      - PREFER_HOST_MODE=hostname
      - MODE=standalone
      - NACOS_AUTH_ENABLE=true
      - NACOS_AUTH_IDENTITY_KEY=你的key
      - NACOS_AUTH_IDENTITY_VALUE=你的value
      - NACOS_AUTH_TOKEN=你的秘钥fake_password
    volumes:
      - ./data:/home/nacos/data
      - ./standalone-logs/:/home/nacos/logs
    ports:
      - "8080:8080"
      - "8848:8848"
      - "9848:9848"
```

### k8s 单点

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nacos
spec:
  type: NodePort
  selector:
    app: nacos
  ports:
    - name: http
      port: 8080
      targetPort: 8080
    - name: rpc
      port: 8848
      targetPort: 8848
    - name: cluster
      port: 9848
      targetPort: 9848

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nacos
spec:
  serviceName: "nacos"
  replicas: 1
  selector:
    matchLabels:
      app: nacos
  template:
    metadata:
      labels:
        app: nacos
    spec:
      containers:
        - name: nacos
          image: nacos/nacos-server:v2.5.2  
          ports:
            - containerPort: 8080
              name: http
            - containerPort: 8848
              name: rpc
            - containerPort: 9848
              name: cluster
          env:
            - name: PREFER_HOST_MODE
              value: "hostname"
            - name: MODE
              value: "standalone"
            - name: NACOS_AUTH_ENABLE
              value: "true"
            - name: NACOS_AUTH_IDENTITY_KEY
              value: "serverIdentity"
            - name: NACOS_AUTH_IDENTITY_VALUE
              value: "security"
            - name: NACOS_AUTH_TOKEN
              value: "fake_password"
          volumeMounts:
            - name: nacos-data
              mountPath: /home/nacos/data
  volumeClaimTemplates:
    - metadata:
        name: nacos-data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: nfs184
        resources:
          requests:
            storage: 10Gi
```

### 单点运行

1. 到 [Releases · alibaba/nacos (github.com)](https://github.com/alibaba/nacos/releases) 下载最新版本, 解压
2. 创建数据库 `nacos_config`, 执行 sql 文件 `conf/mysql-schema.sql `
3. 编辑配置文件 `conf/application.properties`

    ```toml
    # 数据库连接
    spring.sql.init.platform=mysql
    db.num=1
    db.url.0=jdbc:mysql://127.0.0.1:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC 
    db.user.0=root
    db.password.0=密码 
    # 开启授权
    # 参考 https://nacos.io/docs/latest/manual/admin/deployment/deployment-cluster/#11-%E4%BD%BF%E7%94%A8mysql%E6%95%B0%E6%8D%AE%E5%BA%93%E6%8E%A8%E8%8D%90
    nacos.core.auth.enabled=true
    nacos.core.auth.system.type=nacos
    nacos.core.auth.server.identity.key=你的key
    nacos.core.auth.server.identity.value=你的value
    nacos.core.auth.plugin.nacos.token.secret.key=base64后的
    ```

4. 启动 `bin/startup.sh -m standalone`

### 集群运行

1. 到 [Releases · alibaba/nacos (github.com)](https://github.com/alibaba/nacos/releases) 下载最新版本, 解压
2. 创建数据库 `nacos_config`, 执行 sql 文件 `conf/mysql-schema.sql`
3. 编辑 `cluster.conf`

```conf
1.1.1.1:8848
2.2.2.2:8848
3.3.3.3:8848
```

1. 编辑配置文件 `conf/application.properties`

    ```toml
    # 数据库连接
    spring.sql.init.platform=mysql
    db.num=1
    db.url.0=jdbc:mysql://127.0.0.1:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=UTC 
    db.user.0=root
    db.password.0=密码 
    # 开启授权
    # 参考 https://nacos.io/docs/latest/manual/admin/deployment/deployment-cluster/#11-%E4%BD%BF%E7%94%A8mysql%E6%95%B0%E6%8D%AE%E5%BA%93%E6%8E%A8%E8%8D%90
    nacos.core.auth.enabled=true
    nacos.core.auth.system.type=nacos
    nacos.core.auth.server.identity.key=你的key
    nacos.core.auth.server.identity.value=你的value
    nacos.core.auth.plugin.nacos.token.secret.key=base64后的
    ```

2. 启动 `bin/startup.sh -m standalone`

### 重要备注

> 登录 `nacos/nacos`, **记得要修改密码**

### 转发配置

[[笔记/point/nginx|nginx]] 转发

```nginx
server {
    listen 443 ssl;
    server_name nacos.kentxxq.com;
    ssl_certificate /usr/local/nginx/conf/ssl/kentxxq.cer;
    ssl_certificate_key /usr/local/nginx/conf/ssl/kentxxq.key;

    location / {
        proxy_pass http://127.0.0.1:8848;
    }
}

server {
        listen 80;
        server_name  nacos.kentxxq.com;
        return 301 https://$server_name$request_uri;
}
```
