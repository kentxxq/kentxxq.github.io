---
title: nginx编译和升级
tags:
  - blog
  - nginx
date: 2023-07-06
lastmod: 2023-12-05
categories:
  - blog
description: "这里记录 [[笔记/point/nginx|nginx]] 的模块编译和升级操作."
---

## 简介

这里记录 [[笔记/point/nginx|nginx]] 的模块编译和升级操作.

## 编译

### 正常编译

 [[笔记/linux命令与配置#c/c++ 项目依赖|装好依赖]] 后开始编译

```shell
# 准备目录
mkdir nginx ; cd nginx

# 下载tengine https://tengine.taobao.org/download_cn.html
curl https://tengine.taobao.org/download/tengine-3.0.0.tar.gz -o 
tengine-3.0.0.tar.gz
tar xf tengine-3.0.0.tar.gz

# 下载,解压 https://nginx.org/en/download.html
curl http://nginx.org/download/nginx-1.24.0.tar.gz -o nginx-1.24.0.tar.gz
tar -xf nginx-1.24.0.tar.gz
cd nginx-1.24.0

# 监控信息 --with-http_stub_status_module 
# ssl证书 --with-http_ssl_module
# tcp代理和tcp代理证书 --with-stream --with-stream_ssl_module
# tcp代理的时候，把客户端ip传到PROXY协议的header头部 --with-stream_realip_module,虽然我一直用header传输
# 启用http2  --with-http_v2_module
./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_ssl_module --with-stream --with-stream_ssl_module --with-stream_realip_module --with-http_v2_module --with-http_stub_status_module
make && make install

# 软连接
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx

# 验证
nginx -t
# 启动
nginx
# 报错 [emerg] getpwnam("nginx") failed
useradd -s /bin/false nginx
```

#### 支持 connection 请求

[GitHub - chobits/ngx\_http\_proxy\_connect\_module: A forward proxy module for CONNECT request handling](https://github.com/chobits/ngx_http_proxy_connect_module) 作用是支持 connection 请求, 也就是正向代理

```shell
# clone到解压后的nginx目录
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git
patch -p1 < ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch

# 加入编译module
--add-module=ngx_http_proxy_connect_module
```

#### 第三方模块调试

```shell
# 加入tengine的内存调试模块
./configure ... --add-module=/root/nginx/tengine-3.0.0/modules/ngx_debug_pool
```

## 升级

```shell
# 下载,解压
curl http://nginx.org/download/nginx-1.24.0.tar.gz -o ~/nginx-1.24.0.tar.gz
tar xf ~/nginx-1.24.0.tar.gz

# nginx -V查看现有配置，然后到新版本nginx目录下执行同样配置
./configure 编译参数(configure-arguments)

# 编译  
make
# 备份一下
cp /usr/local/nginx/sbin/nginx nginx.bak
# 停老版本nginx  
nginx -s stop
# 替换文件  
cp objs/nginx /usr/local/nginx/sbin/nginx  
# 测试是否正常  
nginx -t  
# 启动新版本nginx  
nginx
```
