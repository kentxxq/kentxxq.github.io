---
title: docker镜像源
tags:
  - blog
  - k8s
  - docker
date: 2023-08-18
lastmod: 2024-06-04
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

可以参考, 做个 k 3 d 的教程?! [k8s 代理问题一站式解决 - 知乎](https://zhuanlan.zhihu.com/p/545327043)

## 公共镜像源

配置示例 `/etc/docker/daemon.json`

```json
{
    "registry-mirrors": [
        "https://docker.m.daocloud.io",
        "https://dockerproxy.com",
        "https://docker.mirrors.sjtug.sjtu.edu.cn",
        "https://mirror.baidubce.com",
        "https://docker.nju.edu.cn"
    ]
}
```

| 提供者      | 地址                                       |
| ----------- | ------------------------------------------ |
| [Docker 镜像代理](https://dockerproxy.com/) | `https://dockerproxy.com`                  |
| [百度云](https://cloud.baidu.com/doc/CCE/s/Yjxppt74z#%E4%BD%BF%E7%94%A8dockerhub%E5%8A%A0%E9%80%9F%E5%99%A8)      | `https://mirror.baidubce.com`              |
| [上海交大镜像站](https://mirrors.sjtug.sjtu.edu.cn/)    | `https://docker.mirrors.sjtug.sjtu.edu.cn` |
| [南京大学镜像站](https://doc.nju.edu.cn/books/35f4a)    | `https://docker.nju.edu.cn`                |
| [DaoCloud](https://github.com/DaoCloud/public-image-mirror)    | `https://docker.m.daocloud.io`             |

- `DaoCloud`, `dockerproxy`, `南京大学镜像站` 支持源站较多
- 其他
    - [DaoCloud支持的镜像源列表](https://github.com/DaoCloud/public-image-mirror/blob/main/mirror.txt)
    - [DaoCloud的二进制，helm加速](https://github.com/DaoCloud/public-image-mirror#%E5%8F%8B%E6%83%85%E9%93%BE%E6%8E%A5%E5%8A%A0%E9%80%9F%E4%B8%89%E5%89%91%E5%AE%A2)

> 不要使用阿里云镜像源, 因为数据不同步!

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
# header中的Docker-Content-Digest与上面repo-digest一致 sha256:a195f9fb6503531660b25f9aeefef1f48bbaf56f46da04bffe1568abb3d3aff6
# 找到对应架构的image-digest,例如amd64,linux
# digest: sha256:4a1d2e00b08fce95e140e272d9a0223d2d059142ca783bf43cf121d7c11c7df8
```

打开 [DockerHub的站点](https://hub.docker.com/_/nginx/tags?page=1&name=1.24),可以发现 `image-digest` 匹配.

![[附件/dockerhub的nginx-1.24版本digest.png]]

而 `image-digest` 是镜像 manifest 的 sha256 的哈希值. 而 manifest 记录着镜像每一层的 layers 哈希值.

也就是说, 网易源和 dockerhub 的每一层 layers 完全一致.

## 镜像 tag 脚本

```shell
for i in 镜像名1 镜像名2 镜像名3
do
    docker pull $i
    docker tag $i 镜像源.com/xxx/$i
    docker push 镜像源.com/xxx/$i
    docker rmi $i
done
```
