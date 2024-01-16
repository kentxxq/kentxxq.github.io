---
title: gitlab-cicd教程
tags:
  - blog
  - gitlab
date: 2024-01-16
lastmod: 2024-01-16
categories:
  - blog
description: 
---

## 简介

这里记录 [[笔记/point/gitlab|gitlab]] 的 [[笔记/point/CICD|CICD]] 使用. 安装部署可以看 [[笔记/gitlab教程|gitlab教程]].

## 内容

### 缓存和产物

- 缓存：每次构建拉取，通常只是 1 个 stage 自己使用。例如前端只有安装依赖的时候用的上，其他时候都不需要 `node_modules`
- 产物：提供给用户下载，在不同 stage 之间传递。例如前端 `dist` 构建物传递到 docker 镜像构建

下面是前端的使用细节

```yml
stages:
  - debug
  - global_before
  - before
  - build_code
  - build_image
  - deploy
  - after
  - global_after

node-build:
  image: node:18
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
    - echo "{\"auths\":{\"镜像仓库地址\":{\"username\":\"用户名\",\"password\":\"密码"}}}" > /kaniko/.docker/config.json
    - /kaniko/executor
      --registry-mirror=docker.m.daocloud.io
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "镜像仓库地址/om/demo:${CI_COMMIT_TAG}"
```
