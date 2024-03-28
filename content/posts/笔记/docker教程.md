---
title: docker教程
tags:
  - blog
  - docker
date: 2023-06-27
lastmod: 2024-03-04
categories:
  - blog
description: "这里记录 [[笔记/point/docker|docker]] 的所有配置和操作."
---

## 简介

这里记录 [[笔记/point/docker|docker]] 的所有配置和操作. 相关的概念可以通过 [[笔记/k8s组件剖析#容器|容器]] 来了解.

## 安装/卸载 docker

[官方文档Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/) 速度慢? 可以试试 [清华源](https://mirrors.tuna.tsinghua.edu.cn/help/docker-ce/), [阿里源](https://developer.aliyun.com/mirror/docker-ce?spm=a2c6h.13651102.0.0.74f31b11uNneF2) 和 [华为源](https://mirrors.huaweicloud.com/mirrorDetail/5ea14d84b58d16ef329c5c13)

```shell
# 前置准备
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 开始安装
apt update -y
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
vim /etc/docker/daemon.json
systemctl daemon-reload
systemctl enable docker --now

# 卸载
apt remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

华为国内源：

#todo/笔记 下面有问题

```shell
curl -fsSL https://mirrors.huaweicloud.com/docker-ce/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://mirrors.huaweicloud.com/docker-ce/linux/debian $(lsb_release -cs) stable"
echo "deb [arch=armhf] https://mirrors.huaweicloud.com/docker-ce/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
apt update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

清华源，速度一般般：

```shell
# 删掉以前的版本
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove $pkg; done
# 安装一些必备的内容
apt-get update
apt-get install ca-certificates curl gnupg

# 信任 Docker 的 GPG 公钥并添加仓库：
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## dockerd 配置参数

 - `/etc/docker/daemon.json` 的 `registry-mirrors` 是拉取镜像的地址, 代替 `docker.io`.
 - 而 `proxies` 是设置容器网络代理, 这样容器里的 curl 就能使用到代理了.

 参考 [镜像源](https://docs.docker.com/registry/recipes/mirror/#configure-the-docker-daemon) 和 [http代理](https://docs.docker.com/config/daemon/systemd/#httphttps-proxy)

```json
{
  "registry-mirrors": ["https://hub-mirror.c.163.com"],
  "proxies": {
      "http-proxy": "http://proxy.example.com:3128",
      "https-proxy": "https://proxy.example.com:3129",
      "no-proxy": " localhost,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.test.example.com"
  }
}
```

[[笔记/point/Systemd|Systemd]] 配置 http/https 代理, 这样 dockerd 就能使用代理了

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:3128"
Environment="HTTPS_PROXY=https://proxy.example.com:3129"
Environment="NO_PROXY=localhost,127.0.0.1,docker-registry.example.com,.corp"
```

## 命令解析

### 示例解析

```shell
# -d 后台运行,--restart=always 总是重启,
# -v /mydata/:/data/ 本地/mydata/挂载到容器/data/
# 暴露本地12端口,映射到容器34端口. 
# 仅本地示例 -p 127.0.0.1:8000:8080
# 默认启动,如果加上/bin/bash,就是进入bash命令
docker run -d --name testserver \
-v /mydata/:/data/ \
-e A=a \
-p 12:34 \
--restart=always \
kentxqq/testserver:1.2 \
/bin/bash

# -t指定名字myapp .代表Dockerfile在当前目录
docker build -t myapp .
```

### nodejs 示例

```shell
# 挂载前端node项目到 /app 目录，然后 npm start 启动
docker run -d -p3000:3000 \
-v /data/frontend/shop-pc:/app \
-w /app \
node:14 /bin/bash -c "npm start"
```

## 操作命令

### 构建镜像

```shell
# 当前文件夹下的Dockerfile文件
# -t 指定名称，默认前缀是docker.io
# --progress=plain 详细日志 --no-cache 禁用缓存
docker build --progress=plain --no-cache -t kentxxq/test-server:latest .
```

### 查看容器映射的端口

```shell
docker port 容器名
```

### 进入和退出容器

```shell
docker exec --rm -it 容器id /bin/bash
# 如果不想关闭容器
ctrl+p ctrl+q
```

### 导入导出

#### 镜像

```shell
# 保存1个或多个镜像到tar文件
docker save busybox nginx > 2img.tar
# 导入
docker load -i dockerdemo.tar
```

#### 容器

```shell
# 导出容器
docker export 容器id xxx.tar
# 导入成镜像
docker import xxx.tar 镜像:tag
```

### 定时镜像清理

```shell
# vim /etc/crontab
0 2 * * * root /usr/bin/docker rmi $(docker images -q) -f
10 2 * * * root /usr/bin/docker image prune -a -f
```

### IO 问题 - 定位容器

```shell
# 查看活动中的进程io
iotop -oP

# 排查
docker inspect -f "{{.Id}} {{.State.Pid}} {{.Name}} " $(docker ps -q) | grep pid
```

### 清空 docker 日志

```shell
# 找到路径
docker inspect --format='{{.LogPath}}' 7ce2a0df954b

truncate -s 0 /var/lib/docker/containers/完整id/完整id-json.log
```

### 上传 docker 镜像

起因是国内经常因为网络问题, 无法正常拉取镜像. 需要手动把常用的镜像备份过来 (即使配置了代理源, 因为会请求 dockerhub 的接口, 这里也会导致失败).

这里记录一下 [[笔记/point/docker|docker]] 的镜像上传.

1. 在网络通常的情况下先拉取镜像

   ```shell
   docker pull maven:3.6.1-jdk-8
   ```

2. 给镜像打 `tag`

   ```shell
   docker tag maven:3.6.1-jdk-8 你的镜像仓库地址/命名空间/maven:3.6.1-jdk-8
   # 这里拿阿里云的镜像仓库举例
   # 镜像仓库命名为msb-images,下面是镜像仓库地址
   # msb-images-registry-vpc.cn-zhangjiakou.cr.aliyuncs.com 私网
   # msb-images-registry.cn-zhangjiakou.cr.aliyuncs.com 公网
   # public 为命名空间
   docker tag maven:3.6.1-jdk-8 msb-images-registry-vpc.cn-zhangjiakou.cr.aliyuncs.com/public/maven:3.6.1-jdk-8
   ```

3. 登录,推送镜像

   ```shell
   # 登录
   docker login --username=用户名 -p 密码 msb-images-registry.cn-zhangjiakou.cr.aliyuncs.com
   # 推送
   docker push msb-images-registry-vpc.cn-zhangjiakou.cr.aliyuncs.com/public/maven:3.6.1-jdk-8
   ```

### 文件拷贝

#### 从镜像拷贝文件到本地

```shell
id = $(docker create 镜像名)
docker cp $id:path - > 本地文件名
docker rm -v $id
```

[[笔记/point/powershell|powershell]] 版本:

```shell
$id = docker create 镜像名
docker cp "${id}:镜像内源文件路径" - | Set-Content 目标文件名
docker rm -v $id
```

### docker 内安装 chrome

```Dockerfile
FROM python:latest

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# install chromedriver
RUN apt-get install -yqq unzip
RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# set display port to avoid crash
ENV DISPLAY=:99
```
