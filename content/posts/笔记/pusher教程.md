---
title: pusher教程
tags:
  - blog
date: 2024-05-09
lastmod: 2024-05-09
categories:
  - blog
description: 
---

## 简介

`pusher` 是我开发的一个推送工具. 用于解决的在推送过程中的各种问题.

- 统一入口, 分发到各个平台 + 设备
- 支持自定义模板, 处理信息

## 模板

### 模板示例

#### 阿里云 flow-webhook

[阿里云 flow-webhook](https://help.aliyun.com/document_detail/2668755.html?spm=a2cl9.flow_devops2020_goldlog_detail.0.0.38274398pinAjQ#2d50648465o0j) 的 payload 如下

```json
{
  "event": "task",
  "action": "status",
  "task": {
    "pipelineId": 183,
    "pipelineName": "test pipeline",
    "stageName": "构建",
    "taskName": "java构建",
    "buildNumber": 19,
    "statusCode": "SUCCESS", 
    "statusName": "运行成功",
    "pipelineUrl": "https://rdc.aliyun.com/ec/pipelines/156539?build=19",
    "message": "[test pipeline]流水线阶段[构建]任务[java构建]运行成功"
  },
  "sources": [
    {
      "repo": "git@gitlab:test.git",
      "branch": "master",
      "commitId": "xdfdfdff",
      "privousCommitId": "ddddd"
    }
  ],
  "globalParams": [
    {"key": "env", "value": "test1"},
    {"key": "test2", "value": "test2"}
  ]
}
```

参数名:


- `pipelineName`: `$.task.pipelineName`
- `statusName`: `$.task.statusName`
- `pipelineUrl`: `$.task.pipelineUrl`
- `repo`: `$.sources[0].data.repo`
- `branch`: `$.sources[0].data.branch`
- `commitId`: `$.sources[0].data.commitId`
- `test2`: `$..[?(@.key == 'env')].value`

模板:

```shell
流水线状态: {{statusName}}
流水线名称: {{pipelineName}}
流水线地址: {{pipelineUrl}}
代码仓库: {{repo}}
代码分支: {{branch}}
commitId: {{commitId}}
变量env: {{env}}
```
