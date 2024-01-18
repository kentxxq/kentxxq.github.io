---
title: Dockerfile教程
tags:
  - blog
  - docker
date: 2023-09-05
lastmod: 2024-01-18
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

## 示例

### Dockerfile-java 示例

```Dockerfile
# 基础层
FROM openjdk:8 AS base
RUN mkdir -p /data/weblog \
&& sed -i "s@http://ftp.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
&& sed -i "s@http://security.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
&& sed -i "s@http://deb.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
&& apt-get install apt-transport-https ca-certificates \
&& apt-get update -y \
&& apt-get install vim telnet less -y
# 时区
ENV TZ Asia/Shanghai



# 构建层
FROM maven:3-jdk-8 AS build
WORKDIR /app/src
# 外部参数
ARG oss_end_point
ARG oss_ak
ARG oss_sk
# ossmaven
RUN wget -q http://gosspublic.alicdn.com/ossutil/1.7.5/ossutil64 \
&& chmod 755 ossutil64 \
&& ./ossutil64 cp -r oss://tz-devops/cicd/ cicd/ -e $oss_end_point -i
$oss_ak -k $oss_sk
# 拷贝文件,帮助缓存
ADD pom.xml /app/src/pom.xml
RUN mvn verify clean -q --fail-never --settings ./cicd/settings.xml
# 拷贝代码
COPY . /app/src
RUN mvn clean package -q -U -Dmaven.test.skip=true --settings ./cicd
/settings.xml



# 汇总部署层
FROM base AS publish
WORKDIR /tmp/publish
ARG ModuleName
COPY --from=build /app/src /tmp/publish
RUN mkdir -p /app/publish \
&& cp `find . -type f -regex ".*/$ModuleName[-.0-9]*[-SNAPHOTREL]*.jar"
` /app/publish/$ModuleName.jar



# 最终镜像层
FROM base AS final
WORKDIR /workload
ARG ModuleName
ENV moduleName=$ModuleName
ARG DEPLOY_PARAMS
ENV deploy_params=$DEPLOY_PARAMS
COPY --from=publish /app/publish/* /workload/
RUN ls && echo $deploy_params && echo $moduleName.jar
CMD java $deploy_params -jar $moduleName.jar
```

### Dockerfile 静态页示例

```Dockerfile
FROM nginx:1.21.1 AS base
RUN mkdir -p /data/weblog \
&& sed -i "s@http://ftp.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
&& sed -i "s@http://security.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
&& sed -i "s@http://deb.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
&& apt-get install apt-transport-https ca-certificates \
&& apt-get update -y \
&& apt-get install vim telnet less -y
ENV TZ Asia/Shanghai



FROM node:12 AS build
WORKDIR /app/src
RUN sed -i "s@http://ftp.debian.org@https://repo.huaweicloud.com@g" /etc
/apt/sources.list \
&& sed -i "s@http://security.debian.org@https://repo.huaweicloud.
com@g" /etc/apt/sources.list \
&& sed -i "s@http://deb.debian.org@https://repo.huaweicloud.com@g" /etc
/apt/sources.list \
&& apt-get install apt-transport-https ca-certificates \
&& apt-get update -y \
&& apt-get install vim telnet less -y
# yaml
RUN npm config set registry "镜像源" \
&& yarn config set registry "镜像源"
ADD package.json /app/src/package.json
COPY *.lock /app/src/
COPY *.json /app/src/
ARG node_install_way
RUN $node_install_way
COPY . /app/src
ARG DEPLOY_CMD
RUN $DEPLOY_CMD



FROM base AS publish
WORKDIR /tmp/publish
COPY --from=build /app/src/dist /tmp/publish/dist
RUN mkdir -p /app/publish \
&& cp -r /tmp/publish/dist/ /app/publish



FROM base AS final
WORKDIR /workload
ARG DEPLOY_PARAMS
ENV deploy_params=$DEPLOY_PARAMS
COPY --from=publish /app/publish/dist/ /usr/share/nginx/html
```

### CICD 外部构建版本

#### Dockerfile-java 示例

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
ENV TZ Asia/Shanghai
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

#### Dockerfile-node 示例

```Dockerfile
FROM node:16 AS base
WORKDIR /workload
# 安装所需的程序
RUN sed -i "s@http://ftp.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://security.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://deb.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false update -y \
    && apt-get install apt-transport-https ca-certificates -y \
    && apt-get install vim telnet less -y

# 进行时区基本信息的设置
ENV TZ="Asia/Shanghai"

# 开始构建
COPY .nuxt /workload/.nuxt
COPY static /workload/static
COPY package.json /workload/package.json
COPY node_modules /workload/node_modules
COPY nuxt.config.js /workload/nuxt.config.js
CMD npm run start
```

#### Dockerfile 静态页示例

配合 [[笔记/nginx配置#容器版本|nginx容器配置]] 使用

```Dockerfile
FROM nginx:1.21.1 AS base
# 安装所需的程序
RUN mkdir -p /data/weblog \
    && sed -i "s@http://ftp.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://security.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://deb.debian.org@https://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && apt-get -o Acquire::Check-Valid-Until=false update -y \
    && apt-get install apt-transport-https ca-certificates -y \
    && apt-get install vim telnet less iproute2 iputils-ping -y
# 进行时区等基本信息的设置
ENV TZ Asia/Shanghai

FROM base AS final
WORKDIR /workload
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY dist /usr/share/nginx/html
```

alpine 版本

```Dockerfile
FROM nginx:alpine

# sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
# 设置时区
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk add --update tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

COPY dist/build/h5 /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```
