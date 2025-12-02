---
title: Dockerfile教程
tags:
  - blog
  - docker
date: 2023-09-05
lastmod: 2025-11-17
categories:
  - blog
description: 
---

## 简介

存放我如何编写 Dockerfile 以及一些构建示例.

## 构建工具

- `docker build` 是最简单, 最普遍的构建方式.
- `buildx` 适用于跨平台构建，通过 --platform 参数可以 `x86`，arm 等架构构建
- `kaniko` 适用于 rootless ，或无法访问 docker 守护进程的环境（容器内部构建）
- `buildkid` #todo/笔记  [如何使用 docker buildx 构建跨平台 Go 镜像 | Shall We Code?](https://waynerv.com/posts/building-multi-architecture-images-with-docker-buildx/)

## 构建细节

### 构建传参

```shell
docker build -t 名字:哈希值-发版号 --build-arg filename=参数值 --build-arg a=b .
```

### 运行传参

```dockerfile
# 假设这里是启动命令
CMD java -Xmx1g -Duser.timezone=GMT+8 -Dfile.encoding=UTF-8 -jar start.jar --spring.profiles.active=$PROFILE
```

运行的时候配置环境变量 `PROFILE=dev`，因为内部

### 构建分层划分

| 镜像名称 | 镜像作用   | 示例                          | 说明                           |
| -------- | ---------- | ----------------------------- | ------------------------------ |
| base     | 基础镜像层 | `FROM openjdk:8 AS base`      | 多次使用, 统一底层镜像         |
| build    | 构建层     | `FROM maven:3-jdk-8 AS build` | 专门构建使用，验证是否正确构建 |
| publish  | 汇总部署层 | `FROM build AS publish`       | 基于 build 层来生成最终构建物  |
| final    | 最终镜像层 | `FROM base AS final`          | 复用干净的 base 层，打包 image |

### 镜像文件夹

- `/app/src`: 源码目录
- `/app/build`: 构建物生成目录
- `/app/publish`: 最终汇总目录. 把构建物移动过来, 同时下载一些必要的图片, 证书等等
- `/workload`: `final` 运行的目录

### add 和 copy 命令的区别

- `add` 可以解压文件
- `copy` 在 multistage 时，拷贝之前的文件

### cmd 和 entrypoint 的区别

- 除非手动指定 --entrypoint 否则启动命令就是 entrypoint 不会改变
- 如果有 entrypoint 了，cmd 就会接到 entrypoint 后面，变成 entrypoint 的参数
- 只有 cmd 的情况下，默认执行 cmd
- 如果传入了 cmd 参数，会覆盖 dockerfile 内的 cmd 参数

举例

1. 假设有一个 curl 镜像设置了 `entrypoint 为 curl`，` cmd 是 --help`
2. 那么默认运行就会打印 curl 的帮助文档
3. 如果运行 `dockcer run xxx 域名`，就会替代掉原有的 cmd 命令，执行 `curl 域名`

## 示例

### 常用镜像版本

- java
	- 21
		- `openjdk:26-ea-21-bookworm` 26 是打包这个镜像用的 jdk 版本，不用管。重点是 21，bookworm
		- `maven:3-eclipse-temurin-21⁠` 重点是 maven 3, jdk 是 21

### 镜像基础环境 - 持续更新

#### ubuntu

采用最新的 [[笔记/point/ubuntu|ubuntu]] LTS 版本

- [ubuntu 历史版本](https://en.wikipedia.org/wiki/Ubuntu_version_history)
- 如果网站写有配置文件文件，以网站为准。否则可以用我的写的配置
    - [阿里源ubutnu](https://developer.aliyun.com/mirror/ubuntu)
    - [清华源ubuntu](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/)

```dockerfile
# 24.04 nobile lts
FROM ubuntu:24.04

# 避免对话式弹窗
ENV DEBIAN_FRONTEND=noninteractive
# 进行时区基本信息的设置
ENV TZ=Asia/Shanghai
# 工作目录
WORKDIR /app

# ubuntu22.04以及之前的版本都是/etc/apt/sources.list,直接去阿里源找配置即可
# RUN mv /etc/apt/sources.list sources.list.bak
# COPY sources.list /etc/apt/sources.list
RUN mv /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
COPY ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources

RUN apt update -y && \
    apt install jq lftp vim ca-certificates apt-transport-https tzdata telnet less iproute2 iputils-ping selinux-utils policycoreutils ntp ntpdate htop nethogs nload tree lrzsz iotop iptraf-ng zip unzip ca-certificates curl gnupg libpcre3 libpcre3-dev openssl libssl-dev build-essential rsync sshpass dnsutils progress -y && \
    ls
```

ubuntu 24 配置文件 `ubuntu.sources`

```
Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
```

#### debian

使用最新的 debian 版本

- [Debian 版本历史 ](https://en.wikipedia.org/wiki/Debian_version_history)
- 如果网站写有配置文件文件，以网站为准。否则可以用我的写的配置
    - [阿里源debian](https://developer.aliyun.com/mirror/debian)
    - [清华源debian](https://mirrors.tuna.tsinghua.edu.cn/help/debian/)
    - debian 12/13 实测可以直接 `sed -i 's|deb.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources`

```dockerfile
# trixie 13
FROM debian:13

# 避免对话式弹窗
ENV DEBIAN_FRONTEND=noninteractive
# 进行时区基本信息的设置
ENV TZ=Asia/Shanghai
# 工作目录
WORKDIR /app


# debian11以及之前的都是/etc/apt/sources.list，直接去阿里源找配置即可
# RUN mv /etc/apt/sources.list sources.list.bak
# COPY sources.list /etc/apt/sources.list
RUN mv /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
COPY debian.sources /etc/apt/sources.list.d/debian.sources

RUN apt update -y && \
    apt install jq lftp vim ca-certificates apt-transport-https tzdata telnet less iproute2 iputils-ping selinux-utils policycoreutils ntpsec-ntpdate ntpsec htop nethogs nload tree lrzsz iotop iptraf-ng zip unzip ca-certificates curl gnupg libpcre2-dev openssl libssl-dev build-essential rsync sshpass dnsutils progress -y && \
    ls
```

debian 13 配置文件 `debian.sources`

```ini
Types: deb
# http://snapshot.debian.org/archive/debian/20250908T000000Z
URIs: http://mirrors.aliyun.com/debian
Suites: trixie trixie-updates
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp

Types: deb
# http://snapshot.debian.org/archive/debian-security/20250908T000000Z
URIs: http://mirrors.aliyun.com/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp
```

##### debian 12 以及历史版本

变化

- 13 和 12 有包不一样，所有 12 以及以前的软件包名以 12 为准
- debian11 以及之前的都是/etc/apt/sources.list，直接去阿里源找配置即可

```dockerfile
# bookworm 12
FROM debian:12

# 避免对话式弹窗
ENV DEBIAN_FRONTEND=noninteractive
# 进行时区基本信息的设置
ENV TZ=Asia/Shanghai
# 工作目录
WORKDIR /app

RUN mv /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak
COPY debian.sources /etc/apt/sources.list.d/debian.sources

RUN apt update -y && \
    apt install jq lftp vim ca-certificates apt-transport-https tzdata telnet less iproute2 iputils-ping selinux-utils policycoreutils ntp ntpdate htop nethogs nload tree lrzsz iotop iptraf-ng zip unzip ca-certificates curl gnupg libpcre3 libpcre3-dev openssl libssl-dev build-essential rsync sshpass dnsutils progress -y && \
    ls
```

debian 12 配置文件 `debian.sources`

```ini
Types: deb
URIs: http://mirrors.aliyun.com/debian
Suites: bookworm bookworm-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://mirrors.aliyun.com/debian-security
Suites: bookworm-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
```

#### alpine

- [阿里源apline](https://developer.aliyun.com/mirror/alpine)

```dockerfile
from alpine:latest

# sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
# 设置时区和源，lrzsz因为缺少维护，所以在testing仓库中，无法直接下载
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk add --no-cache --update jq tzdata vim chrony lftp ca-certificates tzdata less iproute2 iputils bind-tools busybox-extras htop nethogs nload tree iotop iptraf-ng zip unzip curl gnupg pcre pcre-dev openssl openssl-dev build-base rsync sshpass && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone
```

### 特定 dockerfile 示例

#### java

##### 多层构建

```dockerfile
FROM openjdk:8 AS base
COPY --from=apache/skywalking-java-agent:8.9.0-alpine /skywalking/agent /agent/
COPY --from=hengyunabc/arthas:latest /opt/arthas /arthas
# 参数
ARG oss_end_point 
ARG oss_ak 
ARG oss_sk 
# 安装所需的程序
RUN mkdir -p /data/weblog \
    && sed -i "s@http://ftp.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://security.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://deb.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false update -y \
    && apt-get install apt-transport-https ca-certificates -y \
    && apt-get install vim telnet less xfonts-utils iproute2 iputils-ping psmisc -y
# 进行时区基本信息的设置
ENV TZ=Asia/Shanghai
# 设置宋体
RUN mkdir -p /usr/share/fonts/simsun \
    && wget -q http://gosspublic.alicdn.com/ossutil/1.7.9/ossutil64 \
    && chmod 755 ossutil64 \
    && ./ossutil64 cp -r oss://oss仓库/fonts/ /usr/share/fonts/simsun/  -e $oss_end_point -i $oss_ak -k $oss_sk \
    && mkfontscale \
    && mkfontdir \
    && fc-list :lang=zh


FROM base AS final
WORKDIR /workload
ARG jar_path
ENV jar_path=$jar_path
ARG jar_name
ENV jar_name=$jar_name
# 外部设置特殊的启动参数
ARG deploy_params 
ENV deploy_params=$deploy_params

COPY $jar_path /workload/$jar_name
RUN echo $deploy_params && echo $jar_name
CMD exec java $deploy_params -jar $jar_name
```

##### openjdk 8 容器

openjdk 8 使用的是 `bullseye` ，配置文件 `sources.list`

```dockerfile
FROM openjdk:17-bullseye
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak 
COPY sources.list /etc/apt/sources.list

# 参考 debian 基础环境设置，安装软件包
```

##### openjdk 17 容器

openjdk: 17 默认使用 `oracle linux` ，这里我们使用 `17-bullseye` 版本

```dockerfile
FROM openjdk:17-bullseye
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak 
COPY sources.list /etc/apt/sources.list

# 参考 debian 基础环境设置，安装软件包
```

#### node

##### nginx 静态页容器

配合 [[笔记/nginx配置#容器版本|nginx容器配置]] 使用

```Dockerfile
FROM nginx:1.29.1 AS base
# nginx: 1.29.1 基于 debian 12
# 参考 debian 基础环境设置，安装软件包

FROM base AS final
WORKDIR /workload
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dist /usr/share/nginx/html
```

alpine 版本

```Dockerfile
FROM nginx:alpine

# 使用alpine基础配置

COPY dist/build/h5 /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

##### nuxt 独立容器

```Dockerfile
FROM node:24 AS base
# 参考 debian 基础环境设置，安装软件包

# 开始构建
COPY .nuxt /app/.nuxt
COPY static /app/static
COPY package.json /app/package.json
COPY node_modules /app/node_modules
COPY nuxt.config.js /app/nuxt.config.js
CMD npm run start
```

#### dotnet 多层构建

- `mcr.microsoft.com/dotnet/aspnet:9.0` 基于 debian 12

```Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
# todo 基础环境配置

# 去掉警告
ENV ASPNETCORE_HTTP_PORTS=''
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["TestServer.csproj", "TestServer/"]
RUN dotnet restore "TestServer/TestServer.csproj"
COPY . TestServer/
RUN dotnet publish TestServer/TestServer.csproj -o /app/build /p:PublishProfile=Properties/PublishProfiles/linux-x64.pubxml

FROM base AS publish
WORKDIR /app
COPY --from=build /app/build /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app /app
ENTRYPOINT ["dotnet","TestServer.dll"]
```

#### fastapi

```Dockerfile
# 自定义的基础镜像
FROM ubuntu-xq:20251022

# 设置环境变量
ENV TZ=Asia/Shanghai

# 更新系统 & 安装基础依赖
RUN apt-get update && apt-get install -y \
    curl git build-essential python3-venv ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv
COPY --from=ghcr.1ms.run/astral-sh/uv:latest /uv /uvx /usr/local/bin/
RUN uv --version

# 初始化 uv/python 环境依赖
WORKDIR /app
COPY pyproject.toml uv.lock .python-version ./
RUN uv python install && \
    uv sync --frozen --no-cache

# 复制项目代码
COPY . .

# CMD [".venv/bin/python", "main.py"]
CMD ["uv", "run", "uvicorn", "main:app", "--host","0.0.0.0", "--port","15000", "--workers","1"]
```
