---
title: taskfile手册
tags:
  - blog
  - taskfile
date: 2025-09-08
lastmod: 2025-09-09
categories:
  - blog
description: 
---

## 简介

[Taskfile](https://taskfile.dev/) 是一个类似 make 的工具，但是跨平台且 golang 编写

- 不依赖 shell，对比 just 在 windows 上更通用
- 通过 `-g` 参数设置全局命令，just 需要通过 shell 内的脚本来实现全局 alias
- make 等其他老牌工具对初学者不直观，例如环境变量，嵌套等。所以我没上手

## 命令

- `task --init` 初始化文件
    - 在 `$HOME` 下创建的文件，可以通过 `-g` 参数全局调用
- `task` 直接调用 `tasks/default`
- `task test lint -p/--parallel` 并发调用，不建议这么用。规则应该写到 yml 里
- `task test -c/--concurrency 4` 限制并行 4 个任务
- `task test RID=1` 传参 `RID` 为 1

## 示例

### 极简示例

```yaml
version: "3"

tasks:
  default:
    cmds:
      - echo 1
      - echo 2
      - echo 3
  a:
    cmds:
      - echo "a"
      
  # 极简写法
  simple: echo "simple"
  simple2:
    - task: simple
    - echo simple2
```

### 复杂示例

- 支持 taskfile 嵌套等高级用法。除非涉及到协作，或者超大量脚本，不建议增加复杂性

```yml
# https://taskfile.dev
version: "3"

# 全局设置，只打印命令的输出。也可以在 task 层级单独设置
# silent: true

# 变量
vars:
  GREETING: Hello, World!
  prod: production

# 环境变量
env:
  env_a: Hey, there!

# .env文件
dotenv: [".env", "{{.prod}}/.env", "{{.HOME}}/.env"]

tasks:
  # 默认任务
  default:
    cmds:
      - echo "{{.GREETING}}"
      - echo $env_a
      - echo "done"

  # 极简写法
  simple: echo "simple"
  simple2:
    - task: simple
    - echo simple2

  # 复杂示例
  demo:
    dir: /tmp # 设置目录
    prompt: This is a dangerous command... Do you want to continue? # 需要按 y 确认。cli也可以通过 -y/--yes 忽略
    cmds:
      # 稍后清理
      - mkdir -p tmpdir/
      - defer: rm -rf tmpdir/
      - defer: { task: echo-1 } # 如果有多个 defer，后面的 defer 先执行
      - echo 'Do work on tmpdir/'

      # 忽略错误
      - cmd: exit 1
        ignore_error: true

      # 循环
      - for: ["foo.txt", "bar.txt"]
        cmd: cat {{ .ITEM }}
      # 多层循环
      - for:
          matrix:
            OS: ["windows", "linux", "darwin"]
            ARCH: ["amd64", "arm64"]
        cmd: echo "{{.ITEM.OS}}/{{.ITEM.ARCH}}"
      - echo 'done'

  # 顺序调用多个task
  echo-order:
    cmds:
      - task: echo-1
      - task: echo-2
  # 并发，乱序
  echo-all:
    deps: [echo-1, echo-2]
  echo-1:
    cmds:
      - echo "1"
  echo-2:
    cmds:
      - echo "2"

  # 不同平台的汇总命令
  build-all:
    deps: [linux-build, mac-build, windows-build]
  windows-build:
    platforms: ["windows/amd64", "windows/arm64"]
    cmds:
      - echo "Only runs on windows"
  linux-build:
    platforms: ["linux/amd64", "linux/arm64"]
    cmds:
      - echo "Only runs on Linux"
  mac-build:
    platforms: ["darwin/amd64", "darwin/arm64"]
    cmds:
      - echo "Only runs on macOS"

  build:
    desc: "Build output.txt from input.txt"
    # 必须满足条件才会执行 cmds
    preconditions:
      - sh: "[ -f Taskfile.yml ]"
        msg: "Taskfile.yml must exist"
      - sh: "[ -f input.txt ]"
        msg: "input.txt must exist"
    # 原始文件变化才会执行
    sources:
      - input.txt
    # 判断文件是否存在，不存在也会执行（高级用法中用 hash 来判断文件是否变化）
    generates:
      - output.txt
    cmds:
      - cat input.txt | tr 'a-z' 'A-Z' > output.txt
      - echo "Build finished"

  # status 如果为真，就跳过 cmds
  make-dir:
    desc: "Create /tmp/mydir if it doesn't exist"
    status:
      - "[ -d /tmp/mydir ]"
      - "[ -f /tmp/mydir/tmp.txt ]"
    cmds:
      - mkdir -p /tmp/mydir
      - echo "Directory /tmp/mydir created"
      - touch /tmp/mydir/tmp.txt
```

## dotnet

```yaml
version: "3"

vars:
  RIDS:
    - win-x64
    - win-x86
    - win-arm64
    - osx-x64
    - osx-arm64
    - linux-x64
    - linux-musl-x64
    - linux-arm
    - linux-arm64

tasks:
  default:
    cmds:
      - task: dotnet-build

  # 当前系统环境 build
  dotnet-build:
    dir: "{{.PWD}}"
    cmds:
      - dotnet publish -c Release -o out/current /p:DeleteExistingFiles=true -p:DebugType=None -p:PublishSingleFile=true -p:IncludeNativeLibrariesInSingleFile=true --self-contained true /p:DeleteExistingFiles=true
      - ls -alh out/current

  # 构建所有 runtime
  dotnet-build-all:
    cmds:
      - for: { var: RIDS }
        task: dotnet-build-runtime
        vars:
          RID: "{{.ITEM}}"

  # 构建单个 runtime
  dotnet-build-runtime:
    dir: "{{.PWD}}"
    requires:
      vars: [RID]
    cmds:
      - dotnet publish -r {{.RID}} -c Release -o out/{{.RID}} -p:DebugType=None -p:PublishSingleFile=true -p:IncludeNativeLibrariesInSingleFile=true --self-contained true /p:DeleteExistingFiles=true
      - ls -alh out/{{.RID}}
```
