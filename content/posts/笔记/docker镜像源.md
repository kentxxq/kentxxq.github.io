---
title: docker镜像源
tags:
  - blog
  - k8s
  - docker
date: 2023-08-18
lastmod: 2025-02-10
keywords:
  - k8s
  - docker
  - containerd
  - 容器
  - 镜像源
  - mirror
  - registery
  - 代理
categories:
  - blog
description: "为什么会有这篇文章, 是因为我总是会遇到 docker, Containerd, k8s, minikube 等等网络问题. 统一在这里进行测试解决, 并且做成可用的方案. 工作和学习中无限使用!"
---

## 简介

为什么会有这篇文章, 是因为我总是会遇到 [[笔记/point/docker|docker]], [[笔记/point/Containerd|Containerd]], [[笔记/point/k8s|k8s]], [[笔记/point/minikube|minikube]] 等等网络问题.

统一在这里进行测试解决, 并且做成可用的方案. 工作和学习中无限使用!

## 搭建 registry

```yml
registry-demo:
  restart: always
  image: registry:2
  ports:
    - 5000:5000
  volumes:
    - /data/registry:/var/lib/registry
```

#todo/笔记 !!!!!!

- 搭建多个站点的 registry
- Registery 全部走 [[笔记/point/clash|clash]] 代理! 因为域名确认, 所以这里的 url 是能够确认的!
- Nginx 域名代理
- Containerd, k 8 s, docker, minikube 统一都走 nginx 不同域名.
- [cf-worker代理](https://mp.weixin.qq.com/s/gVP04sJpt8d0LLMNgquPGQ)
- 用 horbar 或者 Nexus 来代理，缓存镜像？减少运行时的配置复杂度，统一管理
    - [解决访问难题：使用Nexus 3搭建自己的Docker镜像代理加速服务 - 小z博客](https://blog.xiaoz.org/archives/20916)
    - [使用 Nexus OSS 为 Docker 镜像提供代理 / 缓存功能 | 随遇而安](https://www.iszy.cc/posts/14/#%E4%B8%BA-docker-hub-%E6%B7%BB%E5%8A%A0-docker-proxy-repository)

可以参考, 做个 k 3 d 的教程?! [k8s 代理问题一站式解决 - 知乎](https://zhuanlan.zhihu.com/p/545327043)

## 公共镜像源

配置示例 `/etc/docker/daemon.json`

```json
{
    "registry-mirrors": [
        "https://dockerproxy.net",
        "https://dockerpull.org"
    ]
}
```

参考链接: [国内的 Docker Hub 镜像加速器，由国内教育机构与各大云服务商提供的镜像加速服务 | Dockerized 实践 https://github.com/y0ngb1n/dockerized · GitHub](https://gist.github.com/y0ngb1n/7e8f16af3242c7815e7ca2f0833d3ea6)

## 镜像下载流程

1. Docker 发送 `image名称:tag` 到 registry 请求 `manifest.list` 数据, registry 返回一个不同架构的列表
    ![[附件/镜像下载流程1-请求manifest.list.png]]
2. 拿到 `linux+amd64` 的 `image-digest`, 请求服务器 `manifest` 数据
    ![[附件/镜像下载流程2-请求manifest.png]]
3. `config.digest` 就是你本地 `docker images` 中的 `docker id`. 如果本地存在就不会再拉取镜像
4. 镜像不存在则继续查看是否有 layers 已经存在, 存在的就不会去下载
5. 通过带上 `layersDigest` 请求 registry, 下载不存在的 layers

## 验证镜像一致性

这里拿 `nginx:1.24` 来举例.

```shell
# 从网易源拉取镜像,提示repo-digest值
docker pull hub-mirror.c.163.com/library/nginx:1.24
Digest: sha256:a195f9fb6503531660b25f9aeefef1f48bbaf56f46da04bffe1568abb3d3aff6

# 请求镜像源
curl -v --location 'https://hub-mirror.c.163.com/v2/library/nginx/manifests/1.24' \
--header 'Accept: application/vnd.docker.distribution.manifest.list.v2+json'
# 在返回的数据中:
# 1 header的Docker-Content-Digest与上面repo-digest一致 sha256:a195f9fb6503531660b25f9aeefef1f48bbaf56f46da04bffe1568abb3d3aff6
# 2 找到对应架构的image-digest用于在dockerhub进行核对
# 例如amd64,linux的digest为
# sha256:4a1d2e00b08fce95e140e272d9a0223d2d059142ca783bf43cf121d7c11c7df8
```

开始核对. 打开 [DockerHub的站点](https://hub.docker.com/_/nginx/tags?page=1&name=1.24),可以发现 `image-digest` 匹配.

![[附件/dockerhub的nginx-1.24版本digest.png]]

而 `image-digest` 是镜像 manifest 的 sha256 的哈希值. 而 manifest 记录着镜像每一层的 layers 哈希值.

也就是说, 网易源和 dockerhub 的每一层 layers 完全一致.

## 镜像 tag 脚本

```shell
docker login --username=你的用户名 registry.cn-shanghai.aliyuncs.com
# 输入密码
docker tag 镜像id  xxx.com/a/b:v1
docker push xxx.com/a/b:v1
```

或者

```shell
for i in 镜像名1 镜像名2 镜像名3
do
    docker pull $i
    docker tag $i 镜像源.com/xxx/$i
    docker push 镜像源.com/xxx/$i
    docker rmi $i
done
```

## 文章

- [OCI 镜像格式规范 :: Rectcircle Blog](https://www.rectcircle.cn/posts/oci-image-spec/#rootfs-diff-ids-vs-layers)
