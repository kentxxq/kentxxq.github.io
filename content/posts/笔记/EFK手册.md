---
title: EFK手册
tags:
  - blog
date: 2025-10-28
lastmod: 2025-10-31
categories:
  - blog
description:
---

## 简介

[[EFK]] 的使用记录

## xyy

### 流转过程

1. 日志目录挂载到 filebeat 容器内可以采集
	- `/var/log/pods` 容器日志目录
	- `/var/log/containers` 目录下的 log 会软链接到 `/var/log/pods` 下的文件
2. filebeat 把内容采集后写入到 redis
3. logstash 从 redis 中采集
4. 写入到对应的 es 索引中

### 配置/命令

#### filebeat

- 启动 filebeat 查看是否开始采集对应的日志文件 `filebeat -e -c filebeat.yml -d "publish" -path.data /tmp/filebeat-data`

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: filebeat-input
  namespace: elk
data:
  filebeat.yml: |
    filebeat.inputs:
    - type: container
      enabled: true
      paths:
        - "/var/log/containers/nginx-ingress-nginx-ingress-controller*.log"
      fields:
        app: ingress-nginx
        env: ingress-nginx
      fields_under_root: true
      tail_files: true
    - type: log
      paths:
        - "/logs/prd/*.log"
      max_bytes: 20000
      multiline.pattern: '^([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3})|^DEBUG|^INFO |^WARN |^ERROR|^ DEBUG|^ INFO |^ WARN |^ ERROR'
      multiline.negate: true
      multiline.match: after
      tail_files: true
      fields:
        env: wlsk-prd
      fields_under_root: true
    processors:
     - drop_fields:
         fields: ["prospector", "input", "beat", "host", "input_type", "source", "agent", "ecs.version", "log"]
    # 去掉 output.redis ，使用 output.console 即可打印到控制台
    # output.console:
    #  pretty: true
    output.redis:
      hosts: ["ip地址"]
      db: 10
      password: "密码"
      timeout: 60
      key: "key_name"

```

#### redis

```shell
# 查看日志长度
LLEN key_name

# 查看前 10 条
LRANGE tomcat 0 9
# 查看所有的日志内容
LRANGE tomcat 0 -1
```

#### logstash

logstash 输出详细的采集日志

- `output` 内配置 `stdout { codec => rubydebug }` 可以让 logstash 在 console 打印详细日志

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: logstash
  namespace: elastic-system
data:
  logstash.conf: |
    input {
          redis {
            host => "ip地址"
            data_type => "list"
            db => 10
            password => "密码"
            key => "key_name"
          }
          beats {
            port => 9600
          }
    }
    filter {
      ## ingress-nginx 日志：message 是 JSON，需要先解析
      if [app] == "ingress-nginx" {
        json {
          source => "message"
        }

        # 把内部字段提取到顶层方便 ES 索引
        mutate {
          remove_field => ["message"]
        }

        date {
          match => [ "nginx_timestamp", "ISO8601" ]
          timezone => "Asia/Shanghai"
          remove_field => ["nginx_timestamp"]
        }
      }

      ## 原有 Tomcat 日志逻辑（保留）
      else {
        grok {
          patterns_dir => ["/etc/patterns"]
            match => {
              "message" => [
                "%{IPV4:ip} %{LOGLEVEL:level} %{PROJECT:project} %{TOMCAT_DATESTAMP:time} %{ACTION:action}",
                "%{LOGLEVEL:level} %{PROJECT:project} %{TOMCAT_DATESTAMP:time} %{ACTION:action}"
              ]
            }
        }
        date {
          timezone => "Asia/Shanghai"
          match => [ "time", "yyyy-MM-dd HH:mm:ss.SSS" ]
          remove_field => [ "time" ]
        }

        mutate {
          remove_field => "@version"
          remove_field => "message"
        }
      }
    }
    output {
      codec => rubydebug
      if [app] == "ingress-nginx" {
        elasticsearch {
          hosts => ["http://elasticsearch:9200"]
          index => "%{+YYYY.MM.dd}-ingress-nginx"
          user => "用户名"
          password => "密码"
        }
      } else if [env] =~ /^wlsk-dev.*/ {
        elasticsearch {
          hosts => ["http://elasticsearch:9200"]
          index => "%{+YYYY.MM.dd}-wlsk-dev"
          user => "用户名"
          password => "密码"
        }
      }
    }

```
