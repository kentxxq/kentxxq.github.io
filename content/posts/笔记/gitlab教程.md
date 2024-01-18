---
title: gitlab教程
tags:
  - blog
  - gitlab
date: 2023-08-15
lastmod: 2024-01-17
categories:
  - blog
description: "这里记录 [[笔记/point/gitlab|gitlab]] 的安装, 配置."
---

## 简介

这里记录 [[笔记/point/gitlab|gitlab]] 的安装, 配置.

## 内容

### 安装

#### 环境准备

```shell
# 拉取镜像
docker pull gitlab/gitlab-ce:16.7.3-ce.0

# 跑起来
docker run \
--privileged=true \
--hostname git.kentxxq.com \
--detach \
--publish 80:80 \
--publish 443:443 \
--publish 222:22 \
--name gitlab \
--restart unless-stopped \
--volume /root/gitlab/config:/etc/gitlab \
--volume /root/gitlab/logs:/var/log/gitlab \
--volume /root/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:16.7.3-ce.0

# 停止，修改端口和url
docker stop gitlab
```

#### 修改端口和 url

- 主机配置文件路径 `/root/gitlab/config/gitlab.rb`
- 容器内 `/etc/gitlab/gitlab.rb`

```rb
# 配置域名地址
external_url 'https://git.kentxxq.com'
# ssh地址
gitlab_rails['gitlab_ssh_host'] = 'git.kentxxq.com'
# ssh端口
gitlab_rails['gitlab_shell_ssh_port'] = 10022
# nginx的地址,允许它代理gitlab
gitlab_rails['trusted_proxies'] = ['nginx的ip地址']
# 禁用自带的 nginx
nginx['enable'] = false
# 服务监听方式
gitlab_workhorse['listen_network'] = "tcp"
gitlab_workhorse['listen_addr'] = "0.0.0.0:80"
```

如果不生效, 可以在容器内使用环境变量（遇到过配置文件不生效的 bug，用来临时解决问题）。

```shell
export external_url="https://git.kentxxq.com"
gitlab-ctl reconfigure
gitlab-ctl restart
```

**重新启动 docker start gitlab**

#### 配置 nginx 转发

stream 放置在 `nginx.conf` 的最外层配置，用于 ssh 方式拉取代码

```nginx
stream {
    upstream gitlab {
        hash   $remote_addr consistent;
        server 172.16.0.52:222;
    }

    server {
        listen  10022;
        proxy_connect_timeout   30s;
        proxy_timeout 300s;
        proxy_pass  gitlab;
    }
}
```

配置域名代理

```nginx
server {
    listen 80;
    server_name git.kentxxq.com;
    return 301 https://$server_name$request_uri;
    access_log /usr/local/nginx/conf/hosts/logs/git.kentxxq.com.log k-json;
}

server {
    listen 443 ssl http2;
    server_name git.kentxxq.com;
    access_log /usr/local/nginx/conf/hosts/logs/git.kentxxq.com.log k-json;

    # 普通header头,ip之类的
    include /usr/local/nginx/conf/options/normal.conf;
    # 证书相关
    include /usr/local/nginx/conf/options/ssl_chinnshi.conf;

    location / {
        proxy_pass http://172.16.0.52:80;
    }
}
```

### 常用配置

#### 全局变量数

[[笔记/point/gitlab|gitlab]] 的全局变量数有上限.

```bash
gitlab-rails console
# 等待出现控制台
Plan.default.actual_limits.update!(ci_instance_level_variables: 100)
```

#### 配置生效

```shell
gitlab-ctl reconfigure
gitlab-ctl restart
```

### 升级

- [升级路径](https://docs.gitlab.com/ee/update/index.html#1388)
- [DockerHub上搜索版本](https://hub.docker.com/r/gitlab/gitlab-ce/tags)

```shell
# 停止现有容器
docker stop gitlab
# 清理
docker system prune

# 启动容器
docker run \
--privileged=true \
--hostname git.kentxxq.com \
--detach \
--publish 80:80 \
--publish 443:443 \
--publish 222:22 \
--name gitlab \
--restart unless-stopped \
--volume /root/gitlab/config:/etc/gitlab \
--volume /root/gitlab/logs:/var/log/gitlab \
--volume /root/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:15.11.2-ce.0
# 登录后台查看没有任务执行,即可重复升级步骤
```

### 备份恢复

[官网备份手册](https://docs.gitlab.cn/jh/raketasks/backup_restore.html#%E4%B8%BA-docker-%E9%95%9C%E5%83%8F%E5%92%8C%E6%9E%81%E7%8B%90gitlab-helm-chart-%E5%AE%89%E8%A3%85%E8%BF%9B%E8%A1%8C%E6%81%A2%E5%A4%8D)

```shell
# 创建备份
docker exec -it gitlab gitlab-backup create
# 拷贝 gitlab.rb,secrets.json,1686724904_2023_06_14_14.8.4_gitlab_backup.tar
# 停止两个服务
gitlab-ctl stop puma
gitlab-ctl stop sidekiq
# 开始恢复,忽略掉_gitlab_backup.tar
docker exec -it gitlab gitlab-backup restore BACKUP=1686724904_2023_06_14_14.8.4
# 重启容器
docker restart gitlab
```

### CICD

这里只是 [[笔记/point/CICD|CICD]] 的安装调试，具体使用看 [[笔记/gitlab-cicd教程|gitlab-cicd教程]].

#### Shell-runner

前期准备

- 多机器共享一个 nas, 缓存加速
- 放置 Maven 或 nodejs 等仓库配置文件
- `ossutil64` 帮助拉取 OSS 上的隐私文件 `wget -q http://gosspublic.alicdn.com/ossutil/1.7.9/ossutil64 /opt/ossutil64`
- 安装 [[笔记/point/docker|docker]],并配置 [[笔记/docker教程#配置参数|镜像源]]
- 安装 `helm`

    ```bash
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    # 验证效果
    helm version
    ```

- 安装 `kubectl`

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl version --client
    ```

开始安装

```shell
curl -LJO "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-"runner_amd64.deb
dpkg -i gitlab-runner_amd64.deb
usermod -aG docker gitlab-runner
```

配置 runner

```shell
root@cicd:~# gitlab-runner register
Runtime platform                                    arch=amd64 os=linux pid=18805 revision=8925d9a0 version=14.1.0
Running in system-mode.
Enter the GitLab instance URL (for example, https://gitlab.com/):
https://git.kentxxq.com/
Enter the registration token:
token秘钥
Enter a description for the runner:[cicd]: docker-ci
Enter tags for the runner (comma-separated):docker-ciRegistering runner... succeeded                     runner=3uS9CxxN
Enter an executor: parallels, shell, ssh, virtualbox, docker+machine, kubernetes, custom, docker-ssh, docker-ssh+machine, docker:shell
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
```

修改配置 `/etc/gitlab-runner/config.toml`, 然后重启 `gitlab-runner restart`

```shell
concurrent = 20
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "runner01"
  url = "https://git.kentxxq.com/"
  token = "token秘钥"
  executor = "shell"
  #pre_clone_script = "sudo chown -R gitlab-runner:gitlab-runner ."
  #pre_clone_script = "sudo chmod -R 777 ."
  [runners.custom_build_dir]
    enabled = true
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
```

免密 sudo

```shell
# vim /etc/sudoers加入 
gitlab-runner ALL=(ALL) NOPASSWD: ALL
```

#### docker-runner

```shell
# 注册
docker run --rm -it -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register

# 启动
docker run -d --name gitlab-runner --restart always \
  -v /root/gitlab-runner/config:/etc/gitlab-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gitlab/gitlab-runner:latest
```

#### 缓存配置

配置 runner 文件 `~/gitlab-runner/config/config.toml` 的 `runners.cache` 部分。

> [[笔记/point/minio|minio]] 的安装看 [[笔记/minio教程|minio教程]].

```toml
concurrent = 5
check_interval = 0
shutdown_timeout = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "shared"
  url = "https://gitlab.kentxxq.com/"
  id = 1
  token = "1"
  token_obtained_at = 2024-01-16T07:29:28Z
  token_expires_at = 0001-01-01T00:00:00Z
  executor = "docker"
  [runners.cache]
#    MaxUploadedArchiveSize = 0
    Type = "s3"
    Path = "cicd"
    Shared = true
    [runners.cache.s3]
      ServerAddress = "minio-cicd.kentxxq.com"
      AccessKey = "1"
      SecretKey = "2"
      BucketName = "runner"
      Insecure = false
```

### 服务端 git-server-hook

通常放在 `<GitLab 安装路径>/repositories/<命名空间>/<项目名称>.git/hooks/pre-receive`.

```shell
#!/bin/bash
#pre-receive script
#set -x #for debugging
LG='test_new'

validate_ref()
{
    # --- Arguments
    oldrev=$(git rev-parse $1)
    newrev=$(git rev-parse $2)
    refname="$3"

    echo $oldrev
    echo $newrev
    echo $3

    commitList=`git rev-list $oldrev..$newrev`
    # echo $commitList
    split=($commitList)

    for s in ${split[@]}
    do
        echo "@@@@@@@"
        echo "$s"
        msg=`git cat-file commit $s | sed '1,/^$/d'`
        echo $msg
        result1=$(echo $msg|grep "$LG")
        result2=$(echo $3|grep "$LG")

        echo $result1
        echo $result2

        if [ "$result1"x != ""x ] && [ "$result2"x != "$3"x ] ;then
            echo "!!! include $LG"
            exit 1
        else
            echo "ok"
        fi
    done

}

fail=""

# Allow dual mode: run from the command line just like the update hook, or
# if no arguments are given then run as a hook script
if [ -n "$1" -a -n "$2" -a -n "$3" ]; then
    # Output to the terminal in command line mode - if someone wanted to
    # resend an email; they could redirect the output to sendmail
    # themselves
    PAGER= validate_ref $2 $3 $1
else
    while read oldrev newrev refname
    do
        validate_ref $oldrev $newrev $refname
    done
fi

if [ -n "$fail" ]; then
    exit $fail
fi
```
