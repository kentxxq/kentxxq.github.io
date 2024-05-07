---
title: nginx配置
tags:
  - blog
  - nginx
date: 2023-07-06
lastmod: 2024-05-07
categories:
  - blog
description: "[[笔记/point/nginx|nginx]] 的配置示例. 文档中的配置文件, 目录结构最好结合 nginx编译和升级 使用."
---

## 简介

[[笔记/point/nginx|nginx]] 的配置示例, 文档中的配置文件, 目录结构最好结合 [[笔记/nginx编译和升级|nginx编译和升级]] 使用.

## 基础配置

### nginx.conf 主配置

> 日志格式解析可以参考 [[笔记/linux命令与配置#jq 处理 json|jq 处理 json]]

```nginx
# user nobody;
# 默认进入守护进程 daemon on; 这样就可以forking模式启动.
# 默认打开 master_process on; 这样会创建worker进程. 这是一个开发人员选项,如果off将只存在master进程处理
worker_processes  auto;
worker_cpu_affinity auto;
error_log /data/logs/nginx-error.log;
pid        /run/nginx.pid;
worker_rlimit_nofile 65535;
# 解决nginx-worker一直不退出的情况, worker process is shutting down
# 需要重启nginx生效
worker_shutdown_timeout 5s;

events {
    use     epoll;
    worker_connections  65535;
}

## tcp代理参考
stream {
    upstream service-a {
        hash   $remote_addr consistent;
        server 1.1.1.1:222;
    }

    server {
        listen  10022;
        proxy_connect_timeout   30s;
        proxy_timeout 300s;
        proxy_pass  service-a;
    }
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    # 普通日志格式
    log_format main  '$remote_addr - $remote_user [$time_local] "$request" '
                     '$status $body_bytes_sent "$http_referer" "$http_user_agent" '
                     '$request_length $request_time $upstream_addr '
                     '$upstream_response_length $upstream_response_time $upstream_status';

    # json日志格式
    log_format k-json escape=json '{ "@timestamp":"$time_iso8601", '
                         '"@fields":{ '
                         '"request_uri":"$request_uri", '
                         '"url":"$uri", '
                         '"upstream_addr":"$upstream_addr", '
                         '"remote_addr":"$remote_addr", '
                         '"remote_user":"$remote_user", '
                         '"body_bytes_sent":"$body_bytes_sent", '
                         '"host":"$host", '
                         '"server_addr":"$server_addr", '
                         '"request_time":"$request_time", '
                         '"status":"$status", '
                         '"request":"$request", '
                         '"request_method":"$request_method", '
                         '"upstream_response_time":"$upstream_response_time", '
                         '"http_referrer":"$http_referer", '
                         '"http_x_forwarded_for":"$http_x_forwarded_for", '
                         '"http_user_agent":"$http_user_agent" } }';

    # 允许配置很多的server_name
    server_names_hash_max_size 1024;
    # 配置字符集
    charset utf-8;
    # 访问日志
    access_log  /data/logs/nginx-access.log  main;
    # 默认http 1.0, 改成1.1
    proxy_http_version 1.1;
    # 内核完成文件发送,不需要read再write,没有上下文切换
    sendfile        on;
    # sendfile启用后才生效.累计一定大小后发送,减小额外开销,提高网络效率
    tcp_nopush     on;
    # 尽快发送数据,禁用Nagle算法(等凑满一个MSS-Maximum Segment Size最大报文长度或收到确认再发送)
    tcp_nodelay         on;
    
    # 可以看到 TCP_NOPUSH 是要等数据包累积到一定大小才发送, TCP_NODELAY 是要尽快发送, 二者相互矛盾. 
    # 实际上, 它们确实可以一起用.在传输文件的时候, 先填满包, 再尽快发送. 而其他的情况,都迅速发包,减少延迟.

    # 优先使用服务器支持的加密套件
    ssl_prefer_server_ciphers on;
    # 加速性能
    ssl_session_cache shared:SSL:10m;

    # 会话保持120秒
    keepalive_timeout   120;
    types_hash_max_size 2048;
    server_tokens off;

    # 超时时间
    proxy_connect_timeout 300;
    proxy_read_timeout 300;
    proxy_send_timeout 500;

    # 上传文件
    client_max_body_size 2048M;

    # 大Header会导致502,解决
    client_header_buffer_size  64k;
    # http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_buffer_size
    # 特殊的区域,一般存放的是header信息 
    proxy_buffer_size          256k;
    # 默认开启 proxy_buffering on; 只影响下面2个,不影响上面
    # 缓冲区的个数和大小,ERR_INCOMPLETE_CHUNKED_ENCODING 加大这里
    proxy_buffers              8 256k;
    # 在缓冲没有完全塞满的时候,需要划分一部分地方发送数据到客户端,这样可以加快响应.
    proxy_busy_buffers_size    512k;
    
    # 阿里云ingress
    # proxy_buffers: 4 256k
    # proxy-buffer-size: 256k
    # proxy-busy-buffers-size: 512k

    # 不把buffer外的内容写入到硬盘临时文件,但是会消耗比较多的内存
    # 解决ERR_HTTP2_PROTOCOL_ERROR
    # proxy_max_temp_file_size 0;


    # header允许下划线
    underscores_in_headers on;

    # 网络>硬盘>内存>cpu,所以尽量减少网络占用.
    # 1k内不压缩,因为1个数据包差不多能发送完.压缩也需要时间.
    # 然后我们尽量压榨cpu. 如果能1个数据包发完,那么传输速度提升了.
    # 打开br压缩
    brotli on;
    brotli_min_length 1k;
    brotli_comp_level 6;
    brotli_types application/atom+xml application/javascript application/json application/vnd.api+json application/rss+xml
                 application/vnd.ms-fontobject application/x-font-opentype application/x-font-truetype
                 application/x-font-ttf application/x-javascript application/xhtml+xml application/xml
                 font/eot font/opentype font/otf font/truetype image/svg+xml image/vnd.microsoft.icon
                 image/x-icon image/x-win-bitmap text/css text/javascript text/plain text/xml;

    # 打开gzip
    gzip on;
    gzip_min_length 1k;
    gzip_http_version 1.1;
    gzip_comp_level 7;
    # 压缩类型，下面的配置压缩了接口。可配置项参考nginx目录下的mime.types
    # 参考google压缩了html,css,js,json. text/html 总是会压缩,加上去返回而报错.
    # 图片属于压缩过了的格式, 应该由专门的服务或CDN转换图片格式
    # text/javascript 用于兼容html5之前写的项目
    gzip_types text/plain text/xml text/css text/javascript application/javascript application/json;
    gzip_vary on;

    gzip_disable "msie6";
    # 等价 gzip_disable "MSIE[1-6]\." 但性能更好,匹配更合适;


    # 包含目录
    include /usr/local/nginx/conf/hosts/*.conf;

    # 默认配置,保留是为了不加自定义配置也能起nginx
    server {
        listen       80 default_server;
        server_name  _;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```

### 通用 Header 配置

`/usr/local/nginx/conf/options/normal.conf`

```nginx
# 关闭代表不修改upstream返回的Location,Refresh
# 后端发送301,location地址可能会有问题,这时候需要开启
# proxy_redirect http:// https://; 把http改成https
proxy_redirect off;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Real-Port $remote_port;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

### 长连接 websocket 配置

`/usr/local/nginx/conf/options/upgrade_to_websocket.conf`

```nginx
proxy_http_version 1.1;
proxy_set_header Host $host;
proxy_set_header Upgrade $http_upgrade;
# proxy_set_header Connection "upgrade";
# 配合map $http_upgrade $connection_upgrade使用
proxy_set_header Connection $connection_upgrade;
```

### 证书配置

`/usr/local/nginx/conf/options/ssl_kentxxq.conf`

```nginx
ssl_certificate     /usr/local/nginx/conf/ssl/kentxxq.cer;
ssl_certificate_key /usr/local/nginx/conf/ssl/kentxxq.key;
```

### 时间转换

在 `server` 内使用 `/usr/local/nginx/conf/options/time.conf`

```nginx
# nginx 内置变量，解析为定义格式，仅支持到秒 （实现支持到毫秒）
#
# $time_iso8601  日期格式示例： 2022-09-08T18:16:01+08:00
# $time_local    日期格式示例： 02/Aug/2022:11:11:32 +0800
# $msec          日期格式示例： 1663839717.105 当前的Unix时间戳,单位为秒，小数为毫秒

# 格式化日期
if ($time_iso8601 ~ "^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(\+\d{2})") {
  set $year   $1;
  set $month  $2;
  set $day    $3;
  set $hour   $4;
  set $minute $5;
  set $second $6;
  # 时区，只到小时
  set $time_zone $7;
  # 自定义 yyyy-MM-dd hh:mi:ss 格式
  set $time_zh "$1-$2-$3 $4:$5:$6";
}
# 时间戳，单位毫秒  使用 $msec 去除中间的小数点实现
if ($msec ~ "^(\d+)\.(\d+)") {
  set $timestamp $1$2;
  # 自定义 yyyy-MM-dd hh:mi:ss,SSS 带毫秒格式
  set $time_zh_ms $time_zh,$2;
  # 自定义 yyyy-MM-dd hh:mi:ss.SSS 带毫秒格式
  set $time_zh_ms2 $time_zh.$2;
}
```

### map 配置

`/usr/local/nginx/conf/options/map.conf`

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

# $http_origin如果正则匹配了,$allow_origin会变成后面的值
map $http_origin $allow_origin {
    default "";
    "~http://www.kentxxq.com" http://www.kentxxq.com;
    "~https://www.kentxxq.com" https://www.kentxxq.com;
}

# 添加map会影响性能,如果不是全局使用,建议采用include局部转换时间
# # 自定义 yyyy-MM-dd hh:mi:ss 格式
# map $time_iso8601 $time_zh {
#   default $time_iso8601;
#   "~(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})(\+\d{2})" "$1 $2";
# }
# 
# # 时间戳，单位毫秒  使用 $msec 去除中间的小数点实现
# map $msec $timestamp {
#   default $msec;
#   ~(\d+)\.(\d+) $1$2;
# }
# 
# # 自定义 yyyy-MM-dd hh:mi:ss,SSS 带毫秒格式
# map "$time_iso8601 # $msec" $time_zh_ms {
#   default $time_zh,000;
#   "~(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})(\+\d{2}:\d{2}) # (\d+)\.(\d+)$" "$1 $2,$5";
# }
# 
# # 自定义 yyyy-MM-dd hh:mi:ss.SSS 带毫秒格式
# map "$time_iso8601 # $msec" $time_zh_ms2 {
#   default $time_zh.000;
#   "~(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})(\+\d{2}:\d{2}) # (\d+)\.(\d+)$" "$1 $2.$5";
# }
```

### 跨域配置文件

#### 全部跨域

`/usr/local/nginx/conf/options/allow_all_cross_origin.conf`

```nginx
# add_header 'Access-Control-Allow-Origin' * always;
add_header 'Access-Control-Allow-Origin' $http_origin always;
add_header 'Access-Control-Allow-Credentials' 'true';
add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, HEAD, PUT, DELETE, TRACE, CONNECT';
# add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type';
add_header 'Access-Control-Allow-Headers' *;
add_header 'Access-Control-Max-Age' 86400;
```

#### 全部 options 跨域

`/usr/local/nginx/conf/options/allow_all_options_cross_origin.conf`

```nginx
if ($request_method = 'OPTIONS') {
    # 前两条的配置为固定格式！兼容性最强。原因是客户端发送ajax请求，包含withCredentials的时候，origin不能为*，且Credentials必须为true。
    # 原因
    # 为了防止信息泄露的风险，需要Credentials为true。才能获取cookie等信息
    # 如果origin为*，那么不安全。这是因为浏览器的同源策略。让浏览器内的js不能拿a网站的信息请求b站点
    # 参考链接 
    # https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials
    # https://segmentfault.com/a/1190000015552557
    # 
    add_header 'Access-Control-Allow-Origin' $http_origin always;
    add_header 'Access-Control-Allow-Credentials' 'true';
    add_header 'Access-Control-Allow-Methods' 'GET,POST,OPTIONS,HEAD,PUT,DELETE, TRACE, CONNECT';
    add_header 'Access-Control-Allow-Headers' *;
    add_header 'Access-Control-Max-Age' 86400;
    add_header 'Content-Length' 0;
    return 204;
}
```

#### 特定匹配 options 跨域

`/usr/local/nginx/conf/options/allow_kentxxq_cross_origin.conf`

```nginx
if ($request_method = 'OPTIONS') {
    add_header 'Access-Control-Allow-Origin' $allow_origin always;
    add_header 'Access-Control-Allow-Credentials' 'true';
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS, HEAD, PUT, DELETE, TRACE, CONNECT';
    add_header 'Access-Control-Allow-Headers' 'Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,X-Requested-With,token,terminalType';
    add_header 'Access-Control-Max-Age' 86400;
    add_header 'Content-Length' 0;
    return 204;
}
```

### Upstream 配置

```nginx
upstream backend {
    # 默认轮训,有weight就是加权轮训
    # ip_hash; 适合session等固定机器场景
    # least_conn; 最少连接数
    server backend1.example.com max_fails=1 weight=10;
    server backend2.example.com max_fails=1 weight=5;
    server backend4.example.com;
    # 最大空闲连接数
    keepalive 10;
}
```

### 域名转发

#### 转发配置

`/usr/local/nginx/conf/hosts/www.kentxxq.com.conf`

```nginx
server {
    listen 80;
    server_name www.kentxxq.com;
    return 301 https://$server_name$request_uri;
    access_log /usr/local/nginx/conf/hosts/logs/www.kentxxq.com.log k-json;
}

server {
    http2 on;
    listen 443 ssl;
    server_name www.kentxxq.com;
    access_log /usr/local/nginx/conf/hosts/logs/www.kentxxq.com.log k-json;

    # 普通header头,ip之类的
    include /usr/local/nginx/conf/options/normal.conf;
    # 跨域
    include /usr/local/nginx/conf/options/allow_all_cross_origin.conf;
    # 证书相关
    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;

    location / {
        # 跨域
        include /usr/local/nginx/conf/options/allow_all_options_cross_origin.conf;
        proxy_pass http://1.1.1.1:80;
    }
}
```

#### debug 配置

`/usr/local/nginx/conf/hosts/debug.conf`

```nginx
server {
    listen 8000;
    access_log off;
    server_name _;
    include /usr/local/nginx/conf/options/time.conf;

    # 显示处理过,处理中的请求
    # https://nginx.org/en/docs/http/ngx_http_stub_status_module.html
    location /status_string {
        stub_status;
    }

    location /status_metrics {
        default_type text/plain;
        return 200 '# TYPE connections_active counter 
# HELP The current number of active client connections including Waiting connections. 
connections_active $connections_active $timestamp 

# TYPE connections_reading counter 
# HELP The current number of connections where nginx is reading the request header. 
connections_reading $connections_reading $timestamp 

# TYPE connections_writing counter 
# HELP The current number of connections where nginx is writing the response back to the client. 
connections_writing $connections_writing $timestamp

# TYPE connections_waiting counter 
# HELP The current number of idle client connections waiting for a request. 
connections_waiting $connections_waiting $timestamp';
}

    # 在header中展示各个时间
    location /time {
        default_type text/plain;
        return 200 'time';
        add_header time_zh $time_zh;
        add_header timestamp $timestamp;
        add_header time_msec $msec;
        add_header time_zh_ms $time_zh_ms;
        add_header time_zh_ms2 $time_zh_ms2;
        add_header time_local $time_local;
        add_header time_iso8601 $time_iso8601;
    }

    # tengine的debug模块,需要编译加入模块
    # https://tengine.taobao.org/document_cn/ngx_debug_pool_cn.html
    # location = /debug_pool {
    #    debug_pool;
    # }
}
```

### 静态页代理

#### 简单版

```nginx
location / {
    root /usr/share/nginx/html;
    index index.html;
    try_files $uri $uri/index.html /index.html;
}
```

#### 完整版本

```nginx
server {
    listen 80;
    server_name www.kentxxq.com;
    return 301 https://$server_name$request_uri;
    access_log /usr/local/nginx/conf/hosts/logs/www.kentxxq.com.log;
}

server {
    http2 on;
    listen 443 ssl;
    server_name www.kentxxq.com;
    access_log /usr/local/nginx/conf/hosts/logs/www.kentxxq.com.log;

    include /usr/local/nginx/conf/options/normal.conf;
    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;

    location / {
        if ($request_filename ~* .*\.(?:htm|html)$)
        {
           add_header Cache-Control "no-store";
        }
        root /usr/share/nginx/html;
        try_files $uri @index ;
    }

    location @index {
        add_header Cache-Control "no-store" ;
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri/index.html /index.html;
    }

    error_page 405 =200 $uri;
}
```

#### 容器版本

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name localhost default_server;
    client_max_body_size 200m;

    location / {
        if ($request_filename ~* .*\.(?:htm|html)$)
        {
           add_header Cache-Control "no-store";
        }
        root /usr/share/nginx/html;
        try_files $uri @index ;
    }

    location @index {
        add_header Cache-Control "no-store" ;
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri/index.html /index.html;
    }

    error_page 405 =200 $uri;
}
```

## 功能配置

### 黑/白名单

`/usr/local/nginx/conf/options/whitelist.conf`

```nginx
# ip
allow 1.1.1.1;
# 网段
allow 10.0.0.0/16; 

# 默认拒绝所有
deny all;
```

> 可以包含在 	http, server, location, limit_except 中。limit_except 是用来在 location 内部限制请求 method

### IP 限速

```nginx
http {
    # 白名单
    geo $whitelist {
        default 0;
        10.0.0.0/8 1;
        172.16.0.0/12 1;
        192.168.0.0/16 1;
        8.133.183.80 1;
    }
    # 白名单映射到空字符串,生成限速列表
    map $whitelist $limit {
        0 $binary_remote_addr;
        1 "";
    }
    # 应用限速列表,分配50m内存,每秒10次
    # 10r/m分钟 10r/h小时 10r/d天 10r/w周 10r/y年
    limit_req_zone $limit zone=iplimit:50m rate=10r/s;
}

# 域名限速
# burst代表最多蓄力100,即第一秒最多100+10次请求.
# 默认110次请求排队发送,nodelay则会不排队,直接把110次请求一次性发送
server {
    limit_req zone=iplimit burst=100 nodelay;
}
```

修改默认的 503 状态码（在 http 部分）

```nginx
limit_req_status 429; # 状态码
limit_req_log_level warn; # 记录warn级别的日志
```

> 多个 server_name 公用同一个 zone, 会导致低限速的一直影响高限速.
> 如果需要独立开, 应该配置多个 zone=xxx

### 代理 openai

```nginx
server {
    listen 8888;
    server_name ip;
    access_log /tmp/openai.com.log;

    location / {
        # 使用特定ca来验证证书,默认不验证
        # proxy_ssl_verify on;
        # proxy_ssl_trusted_certificate /etc/nginx/conf.d/cacert.pem;
        # 默认不带SNI,会返回错误的证书,因此需要开启
        proxy_ssl_server_name on;
        # 可以改变SNI的名称,但是没必要
        # proxy_ssl_name www.baidu.com;
        proxy_set_header Host api.openai.com;
        proxy_pass https://api.openai.com;
    }
}
```

相关资料:

- [Nginx 反向代理，当后端为 Https 时的一些细节和原理 - XniLe - Ops 2.0](https://blog.dianduidian.com/post/nginx%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86%E5%BD%93%E5%90%8E%E7%AB%AF%E4%B8%BAhttps%E6%97%B6%E7%9A%84%E4%B8%80%E4%BA%9B%E7%BB%86%E8%8A%82%E5%92%8C%E5%8E%9F%E7%90%86/)

### grpc 配置

```nginx
http {
    access_log  /usr/local/var/log/nginx/access.log;

    upstream auth_services {
        server 0.0.0.0:50051;
        server 0.0.0.0:50052;
    }

    upstream laptop_services {
        server 0.0.0.0:50051;
        server 0.0.0.0:50052;
    }

    server {
        http2 on;
        listen       8080 ssl;

        # Mutual TLS between gRPC client and nginx
        ssl_certificate cert/server-cert.pem;
        ssl_certificate_key cert/server-key.pem;

        ssl_client_certificate cert/ca-cert.pem;
        ssl_verify_client on;

        location /techschool.pcbook.AuthService {
            grpc_pass grpcs://auth_services;

            # Mutual TLS between nginx and gRPC server
            grpc_ssl_certificate cert/server-cert.pem;
            grpc_ssl_certificate_key cert/server-key.pem;
        }

        location /techschool.pcbook.LaptopService {
            grpc_pass grpcs://laptop_services;

            # Mutual TLS between nginx and gRPC server
            grpc_ssl_certificate cert/server-cert.pem;
            grpc_ssl_certificate_key cert/server-key.pem;
        }
    }
}
```

- [Module ngx\_http\_grpc\_module](http://nginx.org/en/docs/http/ngx_http_grpc_module.html#grpc_pass)

### 用户名密码

```nginx
# 安装
apt install apache2-utils -y
# 密码在 /usr/local/nginx/conf/passwd.db ,让你输入密码
htpasswd -c /usr/local/nginx/conf/passwd.db user1

# 配置使用用户名密码
location / {
    auth_basic "需要输入用户名: 密码:";
    auth_basic_user_file /usr/local/nginx/conf/passwd.db;
    proxy_pass http://1.1.1.1:80;
}

# 微信的验证文件
location ^~ /MP_verify_ {
    root /usr/local/nginx/files;
}
```

### 正则匹配

匹配字符:

- `^` : 匹配输入字符串的起始位置
- `$` : 匹配输入字符串的结束位置
- `.` : 匹配除 `\n` 之外的任何单个字符，若要匹配包括“\n”在内的任意字符，请使用诸如 `[.\n]` 之类的模式
- `\s`: 匹配任意的空格符

匹配长度:

- `*`: 任意个数
- `+`: 1 次以上
- `?`: 0 或 1 次

匹配范围

- `[c]`: 匹配单个字符 `c`
- `[a-zA-Z0-9]`: 1 个字符
- `()`: 表达式的内容. 例如 `(jpg|gif|swf)`

匹配优先级

1. `=`
2. `location 完整路径`,进行路径匹配, 但**只是记住**这个最长的路径.
3. `location ^~ 否定正则`.上面的路径如果包含 `^~` ,那么使用并停止匹配.
4. `location ~* 正则` 和 `location ~ 区分大小写正则` 顺序匹配. 匹配到了就选用.
5. `location 部分起始路径`. 没有正则匹配到, 那么开始选用第二步的匹配
6. `/` 还是没有匹配, 则用 `/` 路径

示例:

```nginx
# api-docs结尾的全部拦截
location ~ /api-docs$ {
    default_type application/json;
    return 200 '{"status":"success","result":"nginx json"}';
}
```

### 移动端检测

[Detect Mobile Browsers - Open source mobile phone detection](http://detectmobilebrowsers.com/)

```nginx
location /mobile-page {
    set $is_mobile 0;

    if ($http_user_agent ~* "(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino") {
      set $is_mobile 1;
    }

    if ($http_user_agent ~* "^(1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-)") {
      set $is_mobile 1;
    }

    # =0是pc端 =1是移动端
    if ($is_mobile = 0) {
      return 302 https://www.kentxxq.com$request_uri;
    }

    proxy_set_header Host $host;
    proxy_pass http://1.1.1.1:80;

}
```

### 返回 200

```nginx
location /string {
    default_type text/html;
    return 200 "维护中";
}

location /json {
    default_type application/json;
    return 200 '{"status":"success","result":"nginx json"}';
}

location /metrics {
    default_type text/plain;
    return 200 'metrics';
}
```

### 微信验证文件

```nginx
location /MP_verify_ {
    root /usr/local/nginx/data;
}
```

### 405 错误 - post 请求静态文件

```nginx
# 这一行加在server的第一层，不能加在location位置
error_page 405 =200 $uri;
```

### 防止嵌入 iframe

```nginx
# frame-ancestors 谁能嵌入我
# frame-src 我可以嵌入哪些站点
# 参考 https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Content-Security-Policy/frame-ancestors
# 当前站点,a.com,b.com,以及子域名
# 空格间隔,不同参数分号隔开
add_header Content-Security-Policy "frame-ancestors 'self' a.com b.com *.a.com *.b.com; frame-src 'self' a.com b.com *.a.com *.b.com";
```

###  官网非 www 跳转

```nginx
server {
    listen 80;
    server_name kentxxq.com;
    return 301 https://$server_name$request_uri;
    include /usr/local/nginx/conf/options/normal.conf;
}

server {
    http2 on;
    listen 443 ssl;
    server_name kentxxq.com;
    client_max_body_size 2048M;
    include /usr/local/nginx/conf/options/ssl_kentxxq.conf;
    access_log /usr/local/nginx/conf/hosts/logs/kentxxq.com.log k-json;
    # 302临时跳转
    return 302 https://www.kentxxq.com$request_uri;
}
```

## 守护进程

[[笔记/point/Systemd|Systemd]] 守护配置 `/etc/systemd/system/nginx.service`

```ini
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
# 会导致无法导出prof文件
# PrivateTmp=true

# 总是间隔30s重启,配合StartLimitIntervalSec实现无限重启
RestartSec=30s 
Restart=always
# 相关资源都发送term后,后发送kill
KillMode=mixed
# 最大文件打开数不限制
LimitNOFILE=infinity
# 子线程数量不限制
TasksMax=infinity

[Install]
WantedBy=multi-user.target
```

## Ingress-nginx 配置

双层 nginx,第二层的 ingress-nginx 需要配置这个

```yml
use-forwarded-headers: 'true'
```

负载均衡,默认 round_robin. 还有 ip_hash,least_conn. 可以参考 [ConfigMap - Ingress-Nginx Controller](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#load-balance)

```yml
nginx.ingress.kubernetes.io/upstream-hash-by: 'ip_hash'
```

Ingress 的 yml 文件配置示例:

```nginx
kind: Ingress
apiVersion: networking.k8s.io/v1
metadata:
  name: gateway.gateway.com
  namespace: default
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: >
      {"apiVersion":"networking.k8s.io/v1","kind":"Ingress","metadata":{"annotations":{"kubernetes.io/ingress.class":"nginx","nginx.ingress.kubernetes.io/cors-allow-headers":"uid,download,repeat,DNT,X-CustomHeader,X-LANG,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,X-Api-Key,X-Device-Id,Access-Control-Allow-Origin,authorization","nginx.ingress.kubernetes.io/cors-allow-methods":"PUT,
      GET, POST, OPTIONS,
      DELETE","nginx.ingress.kubernetes.io/cors-allow-origin":"*","nginx.ingress.kubernetes.io/enable-cors":"true"},"name":"gateway.kentxxq.com","namespace":"default"},"spec":{"ingressClassName":"nginx","rules":[{"host":"gateway.kentxxq.com","http":{"paths":[{"backend":{"service":{"name":"gateway","port":{"number":8090}}},"path":"/","pathType":"Prefix"}]}}],"tls":[{"hosts":["gateway.kentxxq.com"],"secretName":"a.kentxxq.com-secret"}]}}
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/cors-allow-headers: >-
      uid,download,repeat,DNT,X-CustomHeader,X-LANG,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,X-Api-Key,X-Device-Id,Access-Control-Allow-Origin,authorization
    nginx.ingress.kubernetes.io/cors-allow-methods: 'PUT, GET, POST, OPTIONS, DELETE'
    nginx.ingress.kubernetes.io/cors-allow-origin: '*'
    nginx.ingress.kubernetes.io/enable-cors: 'true'
    # 下面是手动添加内容，用于压测或自定义
    nginx.ingress.kubernetes.io/server-snippet: |
      location /200_ingress_nginx {
        default_type text/html;
        return 200 "200_ingress_nginx";
      }
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - gateway.kentxxq.com
      secretName: a.kentxxq.com-secret
  rules:
    - host: gateway.kentxxq.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: gateway
                port:
                  number: 8090
          - path: /200_ingress_to_nginx
            pathType: Prefix
            backend:
              service:
                name: test-nginx
                port:
                  number: 80

```

## Openrestry 转发给 kafka

### 依赖配置

以前做过这个, 但是现在觉得没有必要. 因为我对 lua 语言不熟悉, 而且觉得 nginx 做负载就好了, 不应该嵌入一些业务需求.

[GitHub - doujiang24/lua-resty-kafka: Lua kafka client driver for the Openresty based on the cosocket API](https://github.com/doujiang24/lua-resty-kafka)

```nginx
# nginx.conf
http {
    lua_package_path "/path/to/lua-resty-kafka/lib/?.lua;;";
    ...
}
```

### 转发配置

```nginx
server {
    http2 on;
    listen      443 ssl;
    server_name  a.kentxxq.com;
    access_log  /data/weblog/nginx/logs/a.kentxxq.com.access.log  main;
    lua_need_request_body on;
    include  /usr/local/openresty/nginx/conf/option/ssl_kentxxq.com.conf;
    location /lua {
        default_type  'text/html';
        content_by_lua    'ngx.say("hello  world！")';
    }

    location /api/livereportorgan/playbackRecord {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        default_type  'application/json';
        content_by_lua    '
                local cjson = require "cjson"
                local client = require "resty.kafka.client"
                local producer = require "resty.kafka.producer"
                local uuid = require "resty.uuid"
                local broker_list = {
                    { host = "ip1", port = 9092 },
                    { host = "ip2", port = 9092 },
                    { host = "ip3", port = 9092 },
                }
                local message = {}
                message["uri"]=ngx.var.uri
                message["args"]=ngx.var.args
                message["host"]=ngx.var.host
                message["request_body"]=ngx.var.request_body
                message["remote_addr"] = ngx.var.http_x_forwarded_for
                message["remote_user"] = ngx.var.remote_user
                message["time_local"] = ngx.var.time_iso8601
                message["status"] = ngx.var.status
                message["body_bytes_sent"] = ngx.var.body_bytes_sent
                message["http_referer"] = ngx.var.http_referer
                message["http_user_agent"] = ngx.var.http_user_agent
                message["http_x_forwarded_for"] = ngx.var.http_x_forwarded_for
                message["upstream_response_time"] = ngx.var.upstream_response_time
                message["request_time"] = ngx.var.request_time
                message["http_token"] = ngx.var.http_token
                message["terminalType"] = ngx.var.http_terminalType
                message["header"] = ngx.var.header
                message["uuid"] = uuid.generate()
                -- 转换json为字符串
                local message = cjson.encode(message);
                -- 定义kafka异步生产者

                -- this is async producer_type and bp will be reused in the whole nginx worker
                local bp = producer:new(broker_list, { producer_type = "sync" })

                local ok, err = bp:send("playback_duration_notice_org", nil, message)
                if not ok then
                        local response = {}
                        response["code"]="1"
                        response["message"]=err
                        response["data"]="true"
                        local response = cjson.encode(response);
                        ngx.say(response)
                        return
                end
                local delayData = {delay = 60}
                local response = {code = "0", message = "success", data = delayData}
                local response = cjson.encode(response);
                ngx.say(response)
        ';

    }

}

server {
        listen 80;
        server_name  a.kentxxq.com;
        return 301 https://$server_name$request_uri;
}
```

## 相关内容

- 使用 [[笔记/ACME|ACME]] 免费 ssl 证书
