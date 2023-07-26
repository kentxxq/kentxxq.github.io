---
title: CICD-Actions
tags:
  - blog
  - CICD
date: 2023-07-26
lastmod: 2023-07-26
categories:
  - blog
description: 
---

## 简介

[[笔记/point/github|github]] 的 [[笔记/point/CICD|CICD]] 工具名字叫 `action`,而 [[笔记/point/gitea|gitea]] 采用了兼容的方式. 因为 github 肯定会经常用到, 而以后私人也可以使用 gitea, 所以记录一下使用方法.

## 内容

## 触发事件

```yml
name: Actions Demo
run-name: ken is testing out Actions 🚀
on:
  # gitea无法手动触发
  # workflow_dispatch:

  # 可以为空
  push:

  # 这样也可以
  push:
    tags:
      - '**'
    paths:
      - '**.js'
      - '!xxx/***' # 忽略路径
    branches:
      - main
      - 'releases/**'
```

### 缓存

```yml
jobs:
  # 测试缓存,缓存后build操作不再执行
  test-cache-all:
    steps:
      - name: cache 1.txt
        id: cache1
        uses: actions/cache@v3
        with:
          path: 1.txt
          key: 1.txt

      - name: build 1.txt
        # 条件判断cache1是id
        if: steps.cache1.outputs.cache-hit != 'true'
        run: |
          touch 1.txt
          echo 1 > 1.txt
          echo 1.txt创建完成
```

### 上传下载

```yml
jobs:
  # 上传
  test-upload-all:
    steps:
      - name: upload txt1
        uses: actions/upload-artifact@v3
        with:
          name: artifact-txt1
          path: 1.txt

      - name: upload txt2
        uses: actions/upload-artifact@v3
        with:
          name: artifact-txt2
          path: 2.txt

  # 下载
  download:
    needs: test-upload-all
    steps:
      - name: download txt
        uses: actions/download-artifact@v3
        with:
          name: artifact-txt1

      - name: echo
        run: |
          pwd
          ls
          cd artifact-txt1
          pwd
          ls
          cat 1.txt
```

### Csharp 构建示例

```yml
jobs:
  build:
    # 这里和runner的标签匹配,可以多个[a,b]
    runs-on: ubuntu-latest
    strategy:
      matrix:
        dotnet-version: ["6", "7"]
    steps:
      - name: 拉取代码 https://github.com/actions/checkout
        uses: actions/checkout@v3
      - name: 配置dotnet-sdk  https://github.com/actions/setup-dotnet
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: ${{ matrix.dotnet-version }}
          cache: true
          cache-dependency-path: subdir/packages.lock.json
      - run: |
          dotnet --version
          dotnet --help
```

### Docker 构建

#### Gitea 版本

```yml
jobs:
  test-docker:
    container: catthehacker/ubuntu:act-latest
    steps:
      - name: check docker version
        run: |
          docker version
```

#### Github 版本

[Build and push Docker images · Actions · GitHub Marketplace · GitHub](https://github.com/marketplace/actions/build-and-push-docker-images)

```yml
jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      - name: check docker version
        run: |
          docker version
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: user/app:latest
```

### 内置变量

```yml
jobs:
  build-in-env:
    runs-on: ubuntu-latest
    steps:
      # 所有的内置对象示例 https://docs.github.com/en/actions/learn-github-actions/contexts#example-contents-of-the-github-context
      - run: echo ${{ gitea.event_name }}
      - run: echo ${{ runner.os }}
      - run: echo ${{ gitea.ref }}
      - run: echo ${{ gitea.repository }}
      - run: echo ${{ gitea.workspace }}
      - name: List files in the repository
        run: |
          ls ${{ gitea.workspace }}
      - run: echo ${{ job.status }}
      - run: echo ${{ github.api_url }}
      - run: echo ${{ github.server_url }}
      - run: echo ${{ github.base_ref	 }}
      - run: sleep 2
```

### Release 发布

```yml
jobs:
  # 测试release
  test-release-gitea:
    # gitea 必须要tag,否则无法工作,同时避免在github上运行
    # if: ${{ startsWith(gitea.ref, 'refs/tags/') && contains(gitea.server_url, '你的服务器地址,例如github.com') }}
    if: ${{ startsWith(gitea.ref, 'refs/tags/') && contains(gitea.server_url, 'ken') }}
    steps:
      - name: download txt
        uses: actions/download-artifact@v3
        with:
          name: artifact-txt1
      - name: setup go
        uses: actions/setup-go@v4
        with:
          go-version: ">=1.20.1"
      - name: release
        id: release1
        uses: https://gitea.com/actions/release-action@main
        with:
          files: |-
            artifact-txt1/*.txt
          api_key: "${{secrets.RELEASE_TOKEN}}"

  test-release-github:
    # 打tag才运行,且避免在gitea上运行
    if: ${{ startsWith(github.ref, 'refs/tags/') && contains(github.server_url, 'github') }}
    steps:
      - name: download txt
        uses: actions/download-artifact@v3
        with:
          name: artifact-txt2
      - name: release
        id: release
        uses: "marvinpinto/action-automatic-releases@latest"
        with:
          repo_token: "${{ secrets.GITHUB_TOKEN }}"
          automatic_release_tag: "latest"
          prerelease: false
          title: "${{ github.ref_name }}" # kentxxq.Cli是tag构建,所以输出的是tag名称
          files: |
            artifact-txt2/2.txt
```

## 遗留问题

- Gitea 不支持并发 [Fetching Title#4efs](https://docs.gitea.com/zh-cn/next/usage/actions/comparison#concurrency)
