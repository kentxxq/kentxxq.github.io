---
title: gitlab-cicd教程
tags:
  - blog
  - gitlab
date: 2024-01-16
lastmod: 2024-01-18
categories:
  - blog
description: "这里记录 [[笔记/point/gitlab|gitlab]] 的 [[笔记/point/CICD|CICD]] 使用. 安装部署可以看 [[笔记/gitlab教程|gitlab教程]]."
---

## 简介

这里记录 [[笔记/point/gitlab|gitlab]] 的 [[笔记/point/CICD|CICD]] 使用.

安装部署可以看 [[笔记/gitlab教程|gitlab教程]].

## 流水线总览

### 前置动作

在 [[笔记/point/gitlab|gitlab]] 的 UI 界面操作，规范 [[笔记/point/CICD|CICD]] 相关的内容。

1. 创建一个 `group` 名为 `devops`，存放所有 [[笔记/point/CICD|CICD]] 相关内容
2. 创建一个 `repo` 名为 `cicd-entrypoint`，存放流水线的入口文件
3. 创建 cicd 文件
    - `main.yml` 是入口。包含通用步骤和引入其他步骤
    - `debug.yml` 调试相关。可以输出变量，调试语法等
    - `global.yml` 全局动作。可以用来发送通知。
    - `java.yml` 是特定 java 的内容
4. 创建 gitlab 全局 CICD 环境变量，`admin管理界面=>setting=>CICD=>Variables`
    - `image_registry` 镜像仓库地址
    - `image_registry_username` 镜像仓库用户名
    - `image_registry_password` 镜像仓库密码
    - `dingding_bot` 钉钉群机器人

### `main.yml`

#### 限制分支启动流水线

```yaml
workflow:
  rules:
    # main只是用来测试，后面可能会删除
    # - if: $CI_COMMIT_REF_NAME == "main" || $CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "main"
    #  when: always
    - if: $CI_COMMIT_REF_NAME == "test"
      when: always
    - if: $CI_COMMIT_REF_NAME == "beta"
      when: always
    - if: $CI_COMMIT_REF_NAME == "prod"
      when: always
    # 默认禁止执行CICD
    - when: never
```

- 默认即使项目引入，也不启动流水线
- 只有 test, beta, prod 启动流水线

#### 整体步骤规划

定义一个比较通用的构建步骤。例如：

- `debug` 调试：打印初始信息，初始变量
- `global_before` 全局初始动作： 发送构建通知到钉钉群
- `before` **流水线级别前置动作**：如果是定时构建，检查代码是否有变化。或者跑单元测试
- `build_code` 构建代码：前端构建 dist，java 构建 jar 包
- `build_image` 构建镜像：拿到产物，构建推送镜像
- `deploy` 部署动作：部署代码到 [[笔记/point/k8s|k8s]]
- `after` **流水线级别后置动作**：删除本地缓存？产物？
- `global_after` 全局结束动作：通知发版完成

```yaml
stages:
  - debug
  - global_before
  - before
  - build_code
  - build_image
  - deploy
  - after
  - global_after
```

#### 流水线变量

一些你可能用到的流水线变量。相比 gitlab 的全局变量：

- 只有使用这个流水线的才会有这个值，避免全局污染
- 同时不需要每个项目都进行变量配置，方便

```yaml
variables:
  # 应用容器数量 默认1
  # 生产环境使用对应的环境变量来配置
  replica_count: ${replica_count}
```

#### 引入其他步骤

```yaml
include:
  - local: "/debug.yml"
  - local: "/global.yml"

  - local: "/java.yml"
    rules:
      - if: $app_type == "java"

  - local: "/node_static.yml"
    rules:
      - if: $app_type == "node_static"
```

- 引入调试，全局动作的 yml 文件
- 如果检测到变量 `app_type` 是 `java`，说明要使用 `java.yml` 流程
- `node_static` 类型是 node 构建出来静态页文件，让 nginx 去提供 http 服务

### `debug.yml` 调试

```yml
debug:
  image: busybox:latest
  stage: debug
  variables:
    GIT_STRATEGY: none
  rules:
    - if: $DEBUG == "true"
  script:
    - echo $CI_BUILDS_DIR
    - echo $CI_BUILDS_DIR
    - echo $CI_PROJECT_PATH
    - echo $CI_COMMIT_BRANCH
    - pwd
    - echo $CI_COMMIT_BRANCH
    - echo $CI_COMMIT_REF_NAME
    - echo $CI_MERGE_REQUEST_TARGET_BRANCH_NAME
    - echo $app_type
```

- 输出一些变量值
- 特定项目需要 debug 的时候，配置环境变量才会运行。节省时间

### `global.yml` 全局动作

- 构建前发送钉钉通知
- 发版成功，失败。都有一个任务钉钉通知

```yml
global_before:
  image: docker.m.daocloud.io/curlimages/curl
  stage: global_before
  variables:
    GIT_STRATEGY: none
  script:
    - export text="### ⚠${CI_PROJECT_NAME}自动构建中...⚠ \n * 分支名：${CI_COMMIT_REF_NAME} \n * 提交人：${CI_COMMIT_AUTHOR}\n * 提交信息：${CI_COMMIT_MESSAGE} \n * 提交id：${CI_COMMIT_SHORT_SHA} \n * 流水线地址：${CI_PIPELINE_URL} "
    - >
      curl --location --request POST $dingding_bot
      --header 'Content-Type: application/json'
      --data-raw '{ 
        "msgtype": "markdown", 
        "markdown": { 
          "title": "gitlab",
          "text": "'"${text}"'"
        }
      }'

global_after_on_failure:
  image: docker.m.daocloud.io/curlimages/curl
  stage: global_after
  variables:
    GIT_STRATEGY: none
  when: on_failure
  script:
    - export text="### ❌${CI_PROJECT_NAME}构建发布失败❌ \n * 分支名：${CI_COMMIT_REF_NAME} \n * 提交人：${CI_COMMIT_AUTHOR}\n * 提交信息：${CI_COMMIT_MESSAGE} \n * 提交id：${CI_COMMIT_SHORT_SHA} \n * 流水线地址：${CI_PIPELINE_URL} "
    - >
      curl --location --request POST $dingding_bot
      --header 'Content-Type: application/json'
      --data-raw '{ 
        "msgtype": "markdown", 
        "markdown": { 
          "title": "gitlab",
          "text": "'"${text}"'"
        }
      }'

global_after_on_success:
  image: docker.m.daocloud.io/curlimages/curl
  stage: global_after
  variables:
    GIT_STRATEGY: none
  when: on_success
  script:
    - export text="### ✅${CI_PROJECT_NAME}发布成功✅ \n * 分支名：${CI_COMMIT_REF_NAME} \n * 提交人：${CI_COMMIT_AUTHOR}\n * 提交信息：${CI_COMMIT_MESSAGE} \n * 提交id：${CI_COMMIT_SHORT_SHA} \n * 流水线地址：${CI_PIPELINE_URL} "
    - >
      curl --location --request POST $dingding_bot
      --header 'Content-Type: application/json'
      --data-raw '{ 
        "msgtype": "markdown", 
        "markdown": { 
          "title": "gitlab",
          "text": "'"${text}"'"
        }
      }'
```

## 实现构建部署

### 缓存/产物

- 缓存：每次构建拉取，通常只是 1 个 stage 自己使用。例如前端只有安装依赖的时候用的上，其他时候都不需要 `node_modules`
- 产物：提供给用户下载，在不同 stage 之间传递。例如前端 `dist` 构建物传递到 docker 镜像构建

### 前端示例

```yaml
node-build:
  image: docker.m.daocloud.io/node:18
  stage: build_code
  # 缓存node_modules
  # 用项目id做key，不和其他项目缓存共享
  cache:
    - key: cache-$CI_PROJECT_ID
      paths:
        - node_modules
  # 产物dist文件夹
  # 1星期以后删除
  artifacts:
    paths:
      - dist
    expire_in: 1 week
  script:
    - npm i --registry=https://registry.npmmirror.com --disturl=https://npmmirror.com/dist
    - npm run build:h5
    - npm run build:mp-weixin

node-deploy:
  image:
    name: m.daocloud.io/gcr.io/kaniko-project/executor:debug
    entrypoint: [""]
  stage: build_image
  script:
    # 不需要任何配置，产物会被下载过来。而cache不会
    - ls dist/build/h5
    - mkdir -p /kaniko/.docker
    - |
      echo "
      {
        \"auths\": {
          \"${image_registry}\":{
            \"username\":\"${image_registry_username}\",
            \"password\":\"${image_registry_password}\"
          }
        }
      }
      " > /kaniko/.docker/config.json
    - cat /kaniko/.docker/config.json
    - >
      /kaniko/executor
      --registry-mirror=docker.m.daocloud.io
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${image_registry}/om/demo:${CI_COMMIT_TAG}"
```

## 使用流水线

创建一个代码仓库，根路径添加 `.gitlab-ci.yml` 文件。内容如下：

```yaml
include:
  - project: "devops/cicd-entrypoint"
    ref: main
    file: "/main.yml"
```

## 报错处理

### 多行字符串

总结情况如下：

- 如果是多行单独的命令。建议使用 `多行独立的 script 语句`
- 如果是一条长命令，例如 `docker run xxx`，`curl xxx`。建议使用 > 折叠符号
    - 每一行的起始位置都应该对齐，**不包含空格**
- 如果是 `echo xxx > 一个文件`，想要保持文件的格式。建议使用 | 符号
    - 为了确保格式正确，**建议用引号包裹字符串**

可以在 [这个网站](https://yaml-multiline.info/) 学习怎么使用。gitlab 也有 [相关的文档示例](https://docs.gitlab.cn/ee/ci/yaml/script.html#%E6%8A%98%E5%8F%A0-yaml-%E5%A4%9A%E8%A1%8C%E5%9D%97%E6%A0%87%E9%87%8F%E4%B8%8D%E4%BF%9D%E7%95%99%E5%A4%9A%E8%A1%8C%E5%91%BD%E4%BB%A4)。
