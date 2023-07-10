---
title: nginx编译和升级
tags:
  - blog
  - nginx
date: 2023-07-06
lastmod: 2023-07-06
categories:
  - blog
description: "这里记录 [[笔记/point/nginx|nginx]] 的模块编译和升级操作."
---

## 简介

这里记录 [[笔记/point/nginx|nginx]] 的模块编译和升级操作.

## 操作手册

### 编译

```shell
# 下载,解压
curl http://nginx.org/download/nginx-1.20.2.tar.gz -o nginx-1.20.2.tar.gz
tar -zxvf nginx-1.20.2.tar.gz
# 安装编译需要用的依赖
apt install libpcre3 libpcre3-dev openssl libssl-dev -y

# ssl证书 --with-http_ssl_module
# tcp代理 --with-stream
# tcp代理的时候，把客户端ip传到PROXY协议的header头部 --with-stream_realip_module,虽然我一直用header传输
# 启用http2  --with-http_v2_module
./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_ssl_module --with-stream --with-stream_realip_module --with-http_v2_module
make
make install

# 软连接
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx

# 验证
nginx -t
# 启动
nginx
# 报错 [emerg] getpwnam("nginx") failed
useradd -s /bin/false nginx
```

### 升级

```shell
# 下载,解压
curl http://nginx.org/download/nginx-1.22.1.tar.gz -o ~/nginx-1.22.1.tar.gz
tar xf ~/nginx-1.22.1.tar.gz

# nginx -V查看现有配置，然后到新版本nginx目录下执行同样配置  
./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_ssl_module --with-stream --with-stream_realip_module --with-http_v2_module

# 编译  
make
# 备份一下
cd /usr/local/nginx/sbin
cp nginx nginx.bak
# 停老版本nginx  
./nginx -s stop
# 替换文件  
cp ~/nginx-1.22.1/objs/nginx nginx  
# 重建软连接
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx
# 测试是否正常  
nginx -t  
# 启动新版本nginx  
nginx
```
