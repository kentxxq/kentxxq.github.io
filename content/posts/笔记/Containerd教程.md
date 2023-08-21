---
title: Containerd教程
tags:
  - blog
  - containerd
date: 2023-08-02
lastmod: 2023-08-21
categories:
  - blog
description: "[[笔记/point/Containerd|Containerd]] 的操作配置."
---

## 简介

这里记录 [[笔记/point/Containerd|Containerd]] 的操作配置, 相关的概念可以通过 [[笔记/k8s组件#容器|容器]] 来了解.

## 内容

### 安装

到 [官方仓库release](https://github.com/containerd/containerd/releases) 下载二进制包, 并解压.

- `containerd`: 包含 `containerd` 和 `ctr`.
  配合 `tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz` 使用, 解压到 `/usr/local` 内.
- `cri-containerd`: 上面的 + `runc`
  配合
- `cri-containerd-cni`: 上面的 + `cni` 的 `host-device,macvlan等等`
- `containerd-static` 应该是静态库链接用的.

```shell
# containerd使用
# 解压到/usr/local
tar Cxzvf /usr/local containerd-1.6.2-linux-amd64.tar.gz

# cri-containerd-cni
# 解压到/
tar Cxzvf / cri-containerd-1.6.2-linux-amd64.tar.gz
```

[[笔记/point/Systemd|Systemd]] 守护配置路径 `/etc/systemd/system/containerd.service`

```ini
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
```

加载配置, 开机启动

```shell
systemctl daemon-reload
systemctl enable containerd --now
```

### 镜像源和代理

#### 代理

修改启动时的环境变量 `/etc/systemd/system/containerd.service`

```ini
[Service]
Environment="HTTPS_PROXY= http://9.21.61.141:3128/"
Environment="HTTP_PROXY= http://9.21.61.141:3128/"
Environment="NO_PROXY=localhost, 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.test.example.com"
```

#### 镜像源不生效 (暂时 20230803)

和 [[笔记/point/docker|docker]] 镜像源不同的地方:

- **只有 CRI 才会生效. 也就是说 crictl 和 k8s 可以使用, ctr 无法使用.**
- [[笔记/point/docker|docker]] 只能配置 [Docker Hub](http://dockerhub.com/), 而 [[笔记/point/Containerd|Containerd]] 可以配置任意仓库.

开始操作

1. 先检查 `/etc/containerd/config.toml` 里面有没有需要用到的配置, 记录一下.
2. 开始生成默认配置, 考虑加入第一步中的有用配置.

    ```shell
    containerd config default > /etc/containerd/config.toml
    ```

3. 编辑配置文件 `/etc/containerd/config.toml`,可以参照

    ```toml
    [plugins."io.containerd.grpc.v1.cri".registry]
       config_path = "/etc/containerd/certs.d"

    # 登录校验是暂时这么配,后面可能会改.参考https://github.com/containerd/containerd/blob/main/docs/cri/registry.md#configure-registry-credentials
    # The registry host has to be a domain name or IP. Port number is also
    # needed if the default HTTPS or HTTP port is not used.
    [plugins."io.containerd.grpc.v1.cri".registry.configs."gcr.io".auth]
    username = ""
    password = ""
    auth = ""
    identitytoken = ""
    ```

4. 创建对应文件和目录. 下面为 `docker.io` 配置镜像

    ```shell
    # 所有容器默认源
    mkdir -p /etc/containerd/certs.d/_default
    
    vim /etc/containerd/certs.d/_default/hosts.toml
    server = "https://hub-mirror.c.163.com"
    [host."https://hub-mirror.c.163.com"]
    capabilities = ["pull", "resolve"]

    # 官方源
    mkdir -p /etc/containerd/certs.d/docker.io
    
    vim /etc/containerd/certs.d/docker.io/hosts.toml
    server = "https://docker.io"]
    [host."https://hub-mirror.c.163.com"]
    capabilities = ["pull", "resolve"]

    # gcr
    mkdir -p /etc/containerd/certs.d/k8s.gcr.io
    
    vim /etc/containerd/certs.d/k8s.gcr.io/hosts.toml
    server = "https://k8s.gcr.io"]
    [host."https://registry.cn-hangzhou.aliyuncs.com/google_containers"]
    capabilities = ["pull", "resolve"]

    # 自有源
    mkdir -p /etc/containerd/certs.d/192.168.12.34:5000
    
    vim /etc/containerd/certs.d/192.168.12.34:5000/hosts.toml
    server = "https://192.168.12.34:5000"
    [host."192.168.12.34:5000"]
    capabilities = ["pull", "resolve"]
    ca = "/path/to/ca.crt"
    skip_verify = true
    ```

> [!info] 相关延展
> `registry.mirrors` 和 `registry.configs` 已经被**弃用**
> 参见 [registry.md](https://github.com/containerd/containerd/blob/main/docs/cri/registry.md) , [config.md](https://github.com/containerd/containerd/blob/main/docs/cri/config.md#registry-configuration), [hosts.md](https://github.com/containerd/containerd/blob/main/docs/hosts.md#registry-configuration---examples)

#### 镜像源生效

上面的配置不生效, 需要追踪 [这个issue](https://github.com/containerd/containerd/issues/6438)......, 记录一下现在生效的配置 #todo/笔记  `k8s.gcr.io` 重定向到了 `registry.k8s.io`,是不是也需要代理, 记录一下

> 注释掉 `config_path`, 会开始读取 `mirrors` 配置

```toml
    [plugins."io.containerd.grpc.v1.cri".registry]
#      config_path = "/etc/containerd/certs.d"

      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://1ocw3lst.mirror.aliyuncs.com
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
          # http.StatusNotFound
          # endpoint = ["https://registry.cn-hangzhou.aliyuncs.com/google_containers"]
          endpoint = ["k8s.dockerproxy.com"]
```

### ctr 操作

#### 命名空间 namespace

- 默认是 `default` 命名空间 , `ctr image ls -n default`
- [[笔记/point/Containerd|Containerd]] 默认命名空间 `default`
- [[笔记/point/docker|docker]] 默认命名空间 `moby`.
  如果找不到容器, 修改 [[笔记/point/docker|docker]] 的启动命令后重启再试.  `/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock` => `/usr/bin/dockerd --containerd /run/containerd/containerd.sock`
- [[笔记/point/k8s|k8s]] 默认命名空间 `k8s.io`

```shell
# 列出所有命名空间
ctr ns ls
# 创建
ctr ns create test
# 删除
ctr ns rm test
```

#### 镜像 image

```shell
# i,image,images都可以

# 镜像查看
ctr i ls
# 镜像拉取,带上docker.io
ctr i pull docker.io/kentxxq/test-server:latest
# 镜像tag
ctr i tag docker.io/kentxxq/test-server:latest  xx/oo:latest
# 删除镜像
ctr i rm

# 导出镜像
ctr i export kentxxq.tar.gz docker.io/kentxxq/test-server:latest
# 导入镜像
ctr i import kentxxq.tar.gz

# 把容器的内容挂载到主机的/xxoo下面
ctr image mount docker.io/library/nginx:alpine /xxoo
# 卸载目录
ctr image unmount /xxoo
```

#### 运行 run

```shell
# 前台运行
ctr run --rm docker.io/kentxxq/test-server:latest tt
# 后台运行
ctr run -d docker.io/kentxxq/test-server:latest tt
```

#### 容器 container

```shell
# c,container,containers都可以

# 查看容器
ctr container ls
# 创建容器,但是没有启动.需要下面的任务task
ctr c create docker.io/kentxxq/test-server:latest test-server
# 容器详情
ctr c info test-server
# 删除容器
ctr c rm test-server
```

#### 任务 task

```shell
# t,task都可以

# 启动容器
ctr t start -d test-server
# 查看运行容的容器
ctr t ls
# 进入容器,需要 --exec-id 任意唯一id
ctr t exec --exec-id 0 -t test-server /bin/bash
# 暂停
ctr t pause test-server
# 恢复
ctr t resume test-server
# kill
ctr t kill test-server
# 删除
ctr t rm test-server

# 查看容器限制
ctr task metrics test-server
# 查看容器在主机在进程名
ctr task ps test-server
PID      INFO
52022    -
52022运行着dotnet TestServer.dll
52022的父进程52004为containerd-shim-runc-v2 -namespace default -id test-server -address /run/containerd/containerd.sock
```

### crictl 操作

[[笔记/point/k8s|k8s]] 通过 [[笔记/point/CRI|CRI]] 标准操作容易运行时, `crictl` 就是一个 [[笔记/point/CRI|CRI]] 的 `cli` 工具.

**因为容器相关的命令很难用, 并且官方只建议用来调试! 我只写一些可能用到的命令.**

```shell
# 镜像
# 列出镜像
crictl images
# 拉取净吸纳过
crictl pull


# pod
# pod列表
crictl pods
# 在容器执行命令
crictl exec -i -t 1f73f2d81bf98 ls
# 查看日志,动态查看最新10行
crictl logs 87d3992f84f74
crictl logs --tail=10 87d3992f84f74
```

> 在配置文件 `/etc/containerd/config.toml` 中如果有 `disabled_plugins = ["cri"]`,crictl 会因无法请求 [[笔记/point/Containerd|Containerd]] 报错
