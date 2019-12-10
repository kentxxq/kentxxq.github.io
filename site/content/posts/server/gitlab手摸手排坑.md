---
title:  gitlab手摸手排坑
date:   2019-05-06 16:56:00 +0800
categories: ["笔记"]
tags: ["gitlab"]
keywords: ["centos","gitlab","gitlab runner","gitlab ci","git","排坑"]
description: "公司准备趁着项目重写的契机，准备从svn切换到git。于是也出现了很多的坑"
---

> 公司准备趁着项目重写的契机，准备从svn切换到git。于是也出现了很多的坑。


技术选型
===
之前写过一篇关于gitea的文章，但是这一次我选择了gitlab。

资源占用
---

先展示一下采用docker运行后的对比`sudo docker stats`

![gitlab_内存使用情况对比](/images/server/gitlab_内存使用情况对比.png)

可以看到gitlab使用了**3GB以上的内存**！我的天。

**我就一个代码仓库啊！就我一个用户正在用啊！cpu时不时飙到了30%是什么鬼啊！**

![gitlab_超高的内存使用](/images/server/gitlab_超高的内存使用.png)

进入到gitlab后台管理监控，直接吓尿。。

为了ci，选了gitlab
---
ci有很多，`jenkins`,`gitlab ci`,`drone`,`travis ci`等等。

jenkins的界面我是真的不喜欢。操作也比较繁琐，没有一个单独文件来的直观。虽然貌似功能(插件)很丰富？！**适合有过经验的人**

travis ci是因为github才被了解到的。可惜不开源，就不考虑了。**适合开源项目用**

drone的缺点就是没有很好的集成到一起，文档也不够全面，再加上了解的过程中，网友们遇到了不少坑。**适合想硬件资源比较紧张/对go非常感兴趣/喜欢尝试新鲜事物的(排坑是必须的)**

gitlab ci开源。有广大的用户群。文档完善。与gitlab集成非常好。**唯一缺点就是对硬件要求比较高**

开始部署
===

1. [安装docker](https://docs.docker.com/install/linux/docker-ce/centos/)
2. 安装运行gitlab。[根据官方文档](https://docs.gitlab.com/omnibus/docker/)，我修改了默认的端口。同时取消了22和443端口的映射。因为用不上啊。
```bash
# 要点:
# 1. 确保存在/data文件夹
# 2. restart always代表每次重启docker服务，都会启动它
sudo docker run --detach \
  --hostname yhserver \
  --publish 1080:80
  --name gitlab \
  --restart always \
  --volume /data/gitlab/config:/etc/gitlab \
  --volume /data/gitlab/logs:/var/log/gitlab \
  --volume /data/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
```
3. [安装运行gitlab runner并且注册](https://docs.gitlab.com/runner/install/linux-repository.html)，推荐使用推荐的方法，也就是yum安装gitlab runner。这里需要注意的是，如果你需要构建docker镜像，推荐使用shell作为executor。
4. 在项目中添加`.gitlab-ci.yml`文件，参考[ci配置文档](https://docs.gitlab.com/ee/ci/yaml/)

排坑
===

gitlab ci无法克隆
---
默认配置文件在`/etc/gitlab-runner/config.toml`文件内。在**url**下加入`clone_url`即可重新设置拉取代码的url地址。
```bash
[root@YHcentos7 gitlab-runner]# cat config.toml 
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "YHcentos7"
  url = "http://192.168.0.22:1080/"
  clone_url = "http://192.168.0.22:1080"
  token = "你的token"
  executor = "shell"
  [runners.custom_build_dir]
  [runners.docker]
    tls_verify = false
    image = "centos:latest"
    privileged = false
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    volumes = ["/cache"]
    shm_size = 0
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
```


no route to host
---
如果拉取代码报错提示no route to host，请检查防火墙！被坑了好久。。。

`firewalld.service`或者`iptables`或者`selinux`！！！
