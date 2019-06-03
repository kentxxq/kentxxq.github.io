---
title:  centos部署web服务（可拓展）
date:   2018-04-17 00:00:00 
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","gunicorn","flask","nginx","配置部署"]
description: "centos部署web服务（可拓展）"
---



> 学习了一下如何搭建大型的web应用，可拓展到承接大量的请求


架构说明
===
1. 第一层购买域名以及云dns解析
2. 第二层在这一个服务器搭建nginx的服务器。反向代理这一个服务器集群提供的服务
3. 第三层在每一台服务器使用gunicorn，开启多个进程来处理flask请求
4. 第四层flask连接到云内部的数据库，同时也就不用担心数据库的同步问题了。（费用如果很高，那说明你需求量很高，很赚钱了啊）
> 现在是云时代。我喜欢所有的东西都放在云上。除非是大企业在机房自建，不然够用了
> 域名部分我就不说了。。一般在对应的云上面找到，然后点点点就ok



![大概示意图](/images/centos/web拓扑图.png)

安装环境
===
```bash
# 设置nginx包
# root @ kentxxq in /etc/yum.repos.d [14:17:01]
$ cat nginx.repo
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1
# 安装nginx
yum install nginx
# 安装python
curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
# 添加到.bash_profile的尾部
export PATH="/root/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
# 安装指定版本的python，安装所需的包
pyenv install 3.6.3
pyenv global 3.6.3
# 安装所需要的包
pip install gevent
pip install flask
pip install gunicorn
```


配置文件
===
```bash
########################
# nginx配置文件
########################
$ root @ kentxxq in /etc/nginx [14:28:10]
$ cat nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    upstream gunicorns {
        server 127.0.0.1:8080;
    }

    server{
        listen 80;
        # using web sub domain to access
        server_name http://gunicorns;
        access_log  /var/log/nginx/web_access.log;

        location / {
            proxy_pass http://127.0.0.1:8080;
            proxy_read_timeout 300;
            proxy_connect_timeout 300;
            proxy_redirect     off;

            proxy_set_header   X-Forwarded-Proto $scheme;
            proxy_set_header   Host              $http_host;
            proxy_set_header   X-Real-IP         $remote_addr;
        }
    }




########################
# gunicorn配置文件
########################
# root @ kentxxq in ~ [14:29:23]
$ cat gunicorn.py
# coding:utf-8
import multiprocessing


#绑定到的ip地址和端口
bind="127.0.0.1:8080"

#这是一个不阻塞的,默认sync性能不够好
worker_class = 'gevent'

#线程数量.推荐是cpu数量*2+1个.
#一般来说48核心的cpu机器还没12个4核心机器好,如果坏了一台还有11台能用
workers = multiprocessing.cpu_count() * 2 + 1


#默认是1,改成2吧
#官方推荐2-4 x $(NUM_CORES)
threads = 2

#日志级别:info不记录访问的日志信息
loglevel = 'info'
#错误日志的路径
errorlog='/var/log/gunicorn.log'
#pid文件,作用是记录pid..
#不过我一般用 ps -ef|grep gunicorn来查看主进程,然后kill -term 主线程pid  来关闭..
pidfile='/var/log/gunicorn.pid'

#任何代码的变动,都会重新reload项目
reload=True

#连接超时
timeout=30

#把任务变成后台的守护进程.不收到终端关闭的影响
daemon=True




########################
# flask文件
########################
# root @ kentxxq in ~ [14:30:31]
$ cat test.py
# coding:utf-8

from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'
```


启动
===
```bash
# 按照指定的参数，启动flask
gunicorn -c gunicorn.py
# 启动nginx代理
systemctl start nginx
```
> 其实我可以用systemd和supervisor来帮助我启动服务。但是supervisor还没有发布python3的版本，而systemd我不是太喜欢，且不支持web来操作。。所以后续再更新吧。。