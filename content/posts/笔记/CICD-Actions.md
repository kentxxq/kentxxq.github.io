---
title: CICD-Actions
tags:
  - blog
  - CICD
date: 2023-07-26
lastmod: 2023-07-27
categories:
  - blog
description: 
---

## 简介

[[笔记/point/github|github]] 的 [[笔记/point/CICD|CICD]] 工具名字叫 `action`,而 [[笔记/point/gitea|gitea]] 采用了兼容的方式. 因为 github 肯定会经常用到, 而以后私人也可以使用 gitea, 所以记录一下使用方法.

代码放在这里, 可以 fork 练习一下. [GitHub - kentxxq/learn-actions](https://github.com/kentxxq/learn-actions)

## 功能示例

### 触发事件

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
name: cache
on:
  push:
  workflow_dispatch:

jobs:
  a:
    runs-on: ubuntu-latest
    steps:
      - name: cache 1.txt
        id: cache1
        uses: actions/cache@v3
        with:
          path: 1.txt
          key: 1.txt

      - name: build 1.txt
        if: steps.cache1.outputs.cache-hit != 'true'
        run: |
          touch 1.txt
          echo 1 > 1.txt
          echo 1.txt创建完成
```

### Docker 构建

#### Gitea 版本

```yml
name: docker
on:
  push:
  workflow_dispatch:

jobs:
  test-docker:
    runs-on: ubuntu-latest
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
name: build-in env
on:
  push:
  workflow_dispatch:

jobs:
  build-in-env:
    runs-on: ubuntu-latest
    steps:
      # 所有的内置对象示例 https://docs.github.com/en/actions/learn-github-actions/contexts#example-contents-of-the-github-context
      - run: echo ${{ github.event_name }}
      - run: echo ${{ runner.os }}
      - run: echo ${{ github.ref }}
      - run: echo ${{ github.repository }}
      - run: echo ${{ github.workspace }}
      - name: List files in the repository
        run: |
          ls ${{ github.workspace }}
      - run: echo ${{ job.status }}
      - run: echo ${{ github.api_url }}
      - run: echo ${{ github.server_url }}
      - run: echo ${{ github.base_ref	 }}
      - run: sleep 2

```

### 上传,下载,Release

```yml
name: release
on:
  push:
  workflow_dispatch:

jobs:
  build-1:
    runs-on: ubuntu-latest
    steps:
      - run: |
          touch 1.txt
          echo 1 > 1.txt
      - name: upload txt1
        uses: actions/upload-artifact@v3
        with:
          name: txt1
          path: 1.txt

  build-2:
    runs-on: ubuntu-latest
    steps:
      - run: |
          touch 2.txt
          echo 2 > 2.txt
      - name: upload txt2
        uses: actions/upload-artifact@v3
        with:
          name: txt2
          path: 2.txt

  test-release-gitea:
    needs: [build-1, build-2]
    runs-on: ubuntu-latest
    # gitea 必须要tag,否则无法工作,同时避免在github上运行
    # if: ${{ startsWith(github.ref, 'refs/tags/') && contains(github.server_url, '你的服务器地址,例如github.com') }}
    if: ${{ startsWith(github.ref, 'refs/tags/') && contains(github.server_url, 'ken') }}
    steps:
      - name: download txt
        uses: actions/download-artifact@v3
        with:
          name: txt1
      - name: setup go
        uses: actions/setup-go@v4
        with:
          go-version: ">=1.20.1"
      - name: release
        id: release1
        uses: https://gitea.com/actions/release-action@main
        with:
          files: |-
            txt1/1.txt
          api_key: "${{secrets.RELEASE_TOKEN}}"

  test-release-github:
    runs-on: ubuntu-latest
    needs: [build-1, build-2]
    # 打tag才运行,且避免在gitea上运行
    if: ${{ startsWith(github.ref, 'refs/tags/') && contains(github.server_url, 'github') }}
    steps:
      # 下载特定artifact
      # - name: download txt
      #   uses: actions/download-artifact@v3
      #   with:
      #     name: txt2
      - name: download txt
        uses: actions/download-artifact@v3
      - run: |
          ls
          cat txt1/1.txt
          cat txt2/2.txt
      - name: release
        id: release
        uses: "marvinpinto/action-automatic-releases@latest"
        with:
          repo_token: "${{ secrets.GITHUB_TOKEN }}"
          automatic_release_tag: "latest"
          prerelease: false
          title: "${{ github.ref_name }}" # kentxxq.Cli是tag构建,所以输出的是tag名称
          files: |
            txt2/2.txt

```

## Csharp 构建示例

```yml
name: check-dotnet-single-file
on:
  push:
    paths:
      - "**/workflows/check-dotnet-single-file.yml"
  workflow_dispatch:
jobs:
  linux-x64-dotnet8-StripSymbols:
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v3

      - name: setup dotnet
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: "8"

      - name: command
        run: |
          dotnet new console --name hello-world -f net8.0
          cd hello-world
          cat hello-world.csproj
          dotnet publish -r linux-x64 -c Release -p:PublishTrimmed=true -p:PublishAot=true -p:StripSymbols=true --self-contained
          ls -lh bin/Release/net8.0/linux-x64/publish/hello-world

  linux-x64-dotnet7-StripSymbols:
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v3

      - name: setup dotnet
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: "7"

      - name: command
        run: |
          dotnet new console --name hello-world -f net7.0
          cd hello-world
          cat hello-world.csproj
          dotnet publish -r linux-x64 -c Release -p:PublishTrimmed=true -p:PublishAot=true -p:StripSymbols=true --self-contained
          ls -lh bin/Release/net7.0/linux-x64/publish/hello-world

  linux-x64-dotnet6:
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v3

      - name: setup dotnet
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: "6"

      - name: command
        run: |
          dotnet new console --name hello-world -f net6.0
          cd hello-world
          dotnet publish -r linux-x64 -c Release -p:PublishSingleFile=true -p:PublishTrimmed=true --self-contained true
          ls -lh bin/Release/net6.0/linux-x64/publish/hello-world

  linux-x64-dotnet7:
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v3

      - name: setup dotnet
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: "7"

      - name: command
        run: |
          dotnet new console --name hello-world -f net7.0
          cd hello-world
          dotnet publish -r linux-x64 -c Release -p:PublishSingleFile=true -p:PublishTrimmed=true --self-contained true
          ls -lh bin/Release/net7.0/linux-x64/publish/hello-world

  # win-x64-dotnet7:
  #   if: ${{ startsWith(github.ref, 'refs/tags/') && contains(github.server_url, 'github') }}
  #   runs-on: windows-latest
  #   steps:
  #     - name: checkout
  #       uses: actions/checkout@v3

  #     - name: setup dotnet
  #       uses: actions/setup-dotnet@v3
  #       with:
  #         dotnet-version: "7"

  #     - name: command
  #       run: |
  #         dotnet new console --name hello-world -f net7.0
  #         cd hello-world
  #         dotnet publish -r win-x64 -c Release -p:PublishSingleFile=true -p:PublishTrimmed=true --self-contained true
  #         ls bin\Release\net7.0\win-x64\publish\

```

## 组织流水线

### 创建一个复用流水线

复用流水线地址 `octo-org/example-repo/.github/workflows/reusable-workflow.yml@main`

```yml
name: Reusable workflow example

on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string
    secrets:
      token:
        required: true

jobs:
  triage:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/labeler@v4
      with:
        repo-token: ${{ secrets.token }}
        configuration-path: ${{ inputs.config-path }}
```

### 复用流水线

```yml
jobs:
  call-workflow-passing-data:
    # uses: ./.github/workflows/workflow-2.yml
    # uses: octo-org/another-repo/.github/workflows/workflow.yml@v1
    # uses: octo-org/this-repo/.github/workflows/workflow-1.yml@172239021f7ba04fe7327647b213799853a9eb89
    uses: octo-org/example-repo/.github/workflows/reusable-workflow.yml@main
    with:
      config-path: .github/labeler.yml
    secrets:
      envPAT: ${{ secrets.envPAT }}
```

### 设计成一个工作流

`ecs`, `docker`, `小程序` 等等发版流程, 做成 workflow.

开发人员在引入我们的 workflow 后, 在 repo 配置环境变量即可运行.

## 不兼容

- Gitea 不支持并发 [concurrency](https://docs.gitea.com/zh-cn/next/usage/actions/comparison#concurrency)
- Gitea 只能复制流水线, 无法和 github 一样页面导入 [工作流程 - GitHub 文档](https://docs.github.com/zh/actions/using-workflows/creating-starter-workflows-for-your-organization)
