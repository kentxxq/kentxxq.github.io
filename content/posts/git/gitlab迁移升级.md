---
title:  gitlab-迁移-升级-代理
date:   2022-01-12 10:56:00+08:00
categories: ["笔记"]
tags: ["gitlab"]
keywords: ["gitlab","迁移","升级","docker","备份","恢复","代理"]
description: "最开始只是使用gitlab作为仓库存储，随着cicd等功能的深入使用，需要对gitlab有更加细节的了解。因此开始记录gitlab相关的配置操作，方便后续的运维操作"
---



> 最开始只是使用gitlab作为仓库存储，随着cicd等功能的深入使用，需要对gitlab有更加细节的了解。因此开始记录gitlab相关的配置操作，方便后续的运维操作。




### 相关

要对gitlab进行操作，最好还是看官方文档为主。可以用网上的其他博主资料作参考，用于快速定位配置项。

1. [gitlab升级路线文档](https://docs.gitlab.com/ee/update/index.html)
2. [gitlab备份恢复文档](https://docs.gitlab.com/ee/raketasks/backup_restore.htm)
3. [gitlab相关版本搜索](https://hub.docker.com/r/gitlab/gitlab-ce/tags)

## 相关操作

### 备份

1. `gitlab-backup create`：大概观察一下备份结果。备份文件xxx.tar.gz会放在数据目录的backups下。
2. 备份`gitlab.rb`、`gitlab-secrets.json`


### 恢复

**一定要与备份时候的gitlab版本号完全一致！！！**

1. 在新机器上起一个gitlab
2. 拷贝xxx.tar.gz文件到backups文件夹
3. `gitlab-ctl stop puma`
4. `gitlab-ctl stop sidekiq`
5. `gitlab-backup restore BACKUP=xxx`:这里xxx是代表备份的文件名
6. `gitlab-ctl stop`停止所有服务
7. 拷贝`gitlab.rb`、`gitlab-secrets.json`到config目录
8. `gitlab-ctl reconfigure`
9. `gitlab-ctl restart`

### 升级

如果发现数据丢失的情况，肯定是没有按照官方文档的特定顺序操作！！

升级路线参考
```bash
# 从13.0.4开始升级，那么升级路线是
gitlab/gitlab-ce:13.0.14-ce.0
gitlab/gitlab-ce:13.1.11-ce.0
gitlab/gitlab-ce:13.8.8-ce.0
gitlab/gitlab-ce:13.12.15-ce.0
gitlab/gitlab-ce:14.0.12-ce.0
gitlab/gitlab-ce:14.1.8-ce.0
gitlab/gitlab-ce:14.6.1-ce.0

# 启动命令
docker run \
--privileged=true \
--hostname xxx.kentxxq.com \
--detach \
--publish 80:80 \
--publish 443:443 \
--publish 222:22 \
--name gitlab \
--restart unless-stopped \
--volume /home/gitlab/config:/etc/gitlab \
--volume /home/gitlab/logs:/var/log/gitlab \
--volume /home/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:13.0.14-ce.0
```

1. 新版容器启动
2. exec进入容器gitlab-ctl stop停止容器
3. stop容器
4. rm容器
5. 循环第一步

## nginx代理内网gitlab

`vim /etc/gitlab/gitlab.rb`编辑配置文件
```yml
# 配置域名地址
external_url 'https://xxx.kentxxq.com'

# 配置 ssh 地址
gitlab_rails['gitlab_ssh_host'] = 'xxx.kentxxq.com'

# Nginx 授信地址
gitlab_rails['trusted_proxies'] = ['nginx的ip地址']

# SSH 端口
gitlab_rails['gitlab_shell_ssh_port'] = 10022

# 服务监听方式
gitlab_workhorse['listen_network'] = "tcp"

# 服务监听地址
gitlab_workhorse['listen_addr'] = "0.0.0.0:80"

# 禁用自带的 nginx
nginx['enable'] = false
```

`gitlab-ctl reconfigure && gitlab-ctl restart` 重新配置gitlab并启动，此时的端口情况如下：
1. 22端口：git-ssh方式拉取的端口
2. 10022端口：在gitlab上显示的git-ssh拉取端口
3. 80端口：关闭gitlab自带的nginx转发，直接把web界面设置到80端口上

nginx方面的配置如下：
1. nginx 把http代理到gitlab-80端口
2. nginx 配置stream，把10222端口tcp代理到gitlab-22端口