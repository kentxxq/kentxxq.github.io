---
title:  开发以及运维的流程-docker
date:   2019-01-03 00:00:00 
categories: ["笔记"]
tags: ["server"]
keywords: ["server","流程","docker","python","pipenv","wget","centos","nginx","redis","yum"]
description: "开发以及运维的流程-docker"
---



> 开发以及运维的流程-docker

个人开发以及部署
===
1. github提交代码
2. 触发webhook，通过脚本让服务器上的容器停止，清除，重新打包，部署

从拿到centos服务器开始
===

安装系统所需的repo
---
```bash
#官方的拓展库
sudo yum install epel-release -y
#Rpmfution只会分发red hat的规范不允许使用的库，它依赖于epel
sudo yum install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
sudo yum install https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
#Elrepo    专注于硬件的驱动程序，比rpmfusion要多一些些，例如kmod同时还有内核，非常有用
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# 如果你需要超级高版本的git或者php之类的，可以看看这个库
# 先默认用base里的，如果版本不能满足，那么就search一下，指不定能用上里面测试过的，兼容性好的包
sudo yum install centos-release-scl unzip -y
# 更新到最新的版本
sudo yum update -y
```

配置我所需要用到的服务
---
```bash
#Nginx 我的http代理
vi /etc/yum.repos.d/nginx.repo

[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1

#shadowsocks 翻墙工具c版本
vi /etc/yum.repos.d/shadowsocks.repo

[librehat-shadowsocks]
name=Copr repo for shadowsocks owned by librehat
baseurl=https://copr-be.cloud.fedoraproject.org/results/librehat/shadowsocks/epel-7-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/librehat/shadowsocks/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1

#sudo 让kentxxq可以免密码sudo
vi /etc/sudoers
kentxxq ALL=(ALL) NOPASSWD: ALL
useradd kentxxq
yourpassword
```

安装我所需要的工具
---
```bash
#Ohmyzsh 好用的shell
sudo yum install -y git zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
#修改.zshrc文件。在linux中，先使用bashrc来初始化bash参数，然后用profile来修改个人参数。而zsh只需要修改zshrc即可）

#pyenv python的版本管理工具
#依赖
sudo yum install -y gcc zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel  openssl-devel xz xz-devel libffi-devel
#开始安装
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
#global 是改变用户目录下的配置，
#local 是在当前文件夹内添加.python_version文件虚拟目录改成项目目录
pyenv install 3.7.1
pyenv global 3.7.1

#pipenv python的包管理工具
pip install pipenv
#把项目环境放入到项目目录。最好加入到.zshrc中
export PIPENV_VENV_IN_PROJECT=1

#direnv 进入目录以后自动切换到对应的python环境
sudo yum install golang
cd direnv
make
make install
#修改.zshrc 
eval "$(direnv hook zsh)"

#安装ss
sudo yum install shadowsocks-libev -y
#修改它的systemd文件，方便配置
[Unit]
Description=Shadowsocks-libev Default Server Service
Documentation=man:shadowsocks-libev(8)
After=network.target network-online.target
[Service]
Type=simple
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/config.json -u
[Install]
WantedBy=multi-user.target
```

可选操作
---
```bash
#安装dnf包管理器
wget http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64/dnf-conf-0.6.4-2.sdl7.noarch.rpm
wget http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64//dnf-0.6.4-2.sdl7.noarch.rpm
wget http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64/python-dnf-0.6.4-2.sdl7.noarch.rpm
yum install python-dnf-0.6.4-2.sdl7.noarch.rpm  dnf-0.6.4-2.sdl7.noarch.rpm dnf-conf-0.6.4-2.sdl7.noarch.rpm
```

开始部署自己的东西
===

docker
---
参考[官方手册](https://www.docker.com/)比较好

mongodb
---
参考[官方手册](https://www.mongodb.com/)比较好
```bash
#初始化操作
mongo 127.0.0.1
use admin
db.createUser({user: "dba",pwd: "dba",roles: [ { role:”root”, db: "admin" } ]} )
```

mysql
---
参考[官方手册](https://www.mysql.com/)比较好
```bash
yum install mysql
```

nginx
---
```bash
server {
    listen       80;
    server_name  _; 
    rewrite ^(.*) https://$host$1 permanent; 
}

server {
    listen 443;
    server_name kentxxq.com;

    ssl on;
    ssl_certificate ssl/cert-1535694093490_kentxxq.com.crt;
    ssl_certificate_key ssl/cert-1535694093490_kentxxq.com.key;

    location /wechat/ {
        proxy_pass http://127.0.0.1:8080;
    }

    location / {
        proxy_pass http://127.0.0.1:1313;
    }
}
```



redis
---
```bash
sudo docker run -d --name redis --rm -p 6379:6379 redis:alpine
#使用redis-cli登陆来查看数据
```















个人部署脚本
---
进行容器关闭，镜像拉取，镜像清理，启动新容器  

```bash
#! /bin/bash


IMAGE="image-url"
echo '关闭容器'
sudo docker ps | grep wechat_test | awk '{print $1}' | xargs sudo docker stop
echo '拉取镜像'
sudo docker pull $IMAGE
echo '清理镜像'
sudo docker images prune
sudo docker images | grep 'none' |awk '{print $3}'|xargs sudo docker image rm -f
echo '启动wechat_test镜像'
sudo docker run -p 8080:8080 --rm --name wechat_test  -d $IMAGE
```

webhook服务  
===

```python
#! /home/kentxxq/.pyenv/shims/python
# coding:utf-8
from http.server import SimpleHTTPRequestHandler, HTTPServer
import logging
import os
import delegator
import json
import hmac
import hashlib
from threading import Thread


class deployThread(Thread):
    def __init__(self, signature: str, data: bytes):
        super().__init__()
        self.signature = signature
        self.data = data

    def run(self):
        print('进入部署')
        blog_v = hmac.new(blog_token, self.data, hashlib.sha1).hexdigest()
        wechat_v = hmac.new(wechat_token, self.data, hashlib.sha1).hexdigest()
        try:
            if self.signature == wechat_v:
                logging.info('开始执行wechat命令')
                result = delegator.run(
                    'sh /home/kentxxq/wechat/deploy.sh')
            elif self.signature == blog_v:
                print("开始执行blog命令")
                result = delegator.run(
                    'sh /home/kentxxq/blog/deploy.sh')
            print(result.out)
        except Exception:
            logging.info('请求错误')


class Handler(SimpleHTTPRequestHandler):
    def do_POST(self):
        '''禁用post请求'''
        print('收到post请求', self.path, self.headers)

        try:
            sha1_flag, signature = self.headers['X-Hub-Signature'].split('=')
            # 读取数据的时候，加上具体的长度，会加快非常多。。
            data = self.rfile.read(int(self.headers['Content-Length']))
            xx = deployThread(signature, data)
            xx.start()
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            # Send the html message
            self.wfile.write(b"ok")
            return
        except Exception:
            pass

    def do_GET(self):
        '''禁用get请求'''
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        # Send the html message
        self.wfile.write(b"hello")
        return


if __name__ == '__main__':
    addr = '127.0.0.1'
    port = 8555
    httpd = HTTPServer((addr, port), Handler)
    # 获取系统环境变量
    wechat_token = os.environ['WECHAT_AUTH_TOKEN'].encode(encoding='ascii')
    blog_token = os.environ['BLOG_AUTH_TOKEN'].encode(encoding='ascii')
    print('使用nohup python -u /usr/local/bin/docker-hook &，可以禁用缓存输出到nohup.out文件')
    httpd.serve_forever()

```

使用`nohup python -u /usr/local/bin/docker-hook &`进行后台，可以把日志输出到nohup.out文件


团队以及企业开发(上云k8s)
===
1. 项目直接部署到云服务商的代码管理
2. 开通k8s的产品服务，规划好要求
3. 建立流水线，触发测试环境的自动部署
4. 测试环境没有问题以后，人工触发生产环境的部署服务

理清楚几个概念
---
1. 设置集群的硬件需求
2. 部署一个应用，就是一个负载。可以多个应用/负载
3. 应用内的pod是k8s的最小控制单位。配置pod的replicas数量,来决定运行多少个容器提供服务。pod可以自动调节数量和故障节点切换
4. 创建一个service，它控制负载均衡当前应用所有的pods，并且对外提供访问
5. 对于集群外的云数据库，可以使用endpoints。使其变成一个内部可以访问的service
