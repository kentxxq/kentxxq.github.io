---
title: clash配置
tags:
  - blog
  - clash
date: 2023-07-12
lastmod: 2023-07-14
keywords:
  - clash
  - 配置文件
  - proxy-providers
  - proxy-groups
  - rules
  - rule-providers
  - nginx代理
  - https
  - 安全
categories:
  - blog
description: "记录 [[笔记/point/clash|clash]] 的配置, 以及是如何使用的.一个文件就能搞定的东西, 就不折腾其他的方法了.为什么不用第三方订阅转换? 因为担心隐私.为什么不自建订阅转换? 因为觉得麻烦, 懒得维护."
---

## 简介

记录 [[笔记/point/clash|clash]] 的配置, 以及是如何使用的.一个文件就能搞定的东西, 就不折腾其他的方法了.

- 为什么不用第三方订阅转换? 因为担心隐私.
- 为什么不自建订阅转换? 因为觉得麻烦, 懒得维护.

## 写配置文件

### 绕过系统代理

参考链接 [绕过系统代理 | Clash for Windows](https://docs.cfw.lbyczf.com/contents/bypass.html#%E8%AE%BE%E7%BD%AE%E6%96%B9%E5%BC%8F)

`Settings` => `System Proxy` => `Bypass Domain/IPNet`

```yml
bypass:
  - localhost
  - 127.*
  - 10.*
  - 172.16.*
  - 172.17.*
  - 172.18.*
  - 172.19.*
  - 172.20.*
  - 172.21.*
  - 172.22.*
  - 172.23.*
  - 172.24.*
  - 172.25.*
  - 172.26.*
  - 172.27.*
  - 172.28.*
  - 172.29.*
  - 172.30.*
  - 172.31.*
  - 192.168.*
  - <local>
```

### 配置文件讲解

```yml
# http代理端口
# http代理的用户名密码
# authentication:
#   - "user1:pass1"
port: 7890
socks-port: 7891
redir-port: 7892
mixed-port: 7893
# 允许局域网访问
allow-lan: true
mode: Rule
log-level: info
ipv6: false
hosts:
external-controller: 0.0.0.0:9090
clash-for-android:
  append-system-dns: false
profile:
  tracing: true
# dns配置,避免被dns污染
dns:
  enable: true
  listen: 127.0.0.1:8853
  default-nameserver:
    - 223.5.5.5
    - 1.0.0.1
  ipv6: false
  # 使用伪造ip
  enhanced-mode: fake-ip
  # 时间服务器如果使用伪造ip,可能导致时区错误?
  # 音乐服务器如果使用伪造ip,可能版权问题?
  fake-ip-filter:
    - "*.lan"
    - stun.*.*.*
    - stun.*.*
    - time.windows.com
    - time.nist.gov
    - time.apple.com
    - time.asia.apple.com
    - "*.ntp.org.cn"
    - "*.openwrt.pool.ntp.org"
    - time1.cloud.tencent.com
    - time.ustc.edu.cn
    - pool.ntp.org
    - ntp.ubuntu.com
    - ntp.aliyun.com
    - ntp1.aliyun.com
    - ntp2.aliyun.com
    - ntp3.aliyun.com
    - ntp4.aliyun.com
    - ntp5.aliyun.com
    - ntp6.aliyun.com
    - ntp7.aliyun.com
    - time1.aliyun.com
    - time2.aliyun.com
    - time3.aliyun.com
    - time4.aliyun.com
    - time5.aliyun.com
    - time6.aliyun.com
    - time7.aliyun.com
    - "*.time.edu.cn"
    - time1.apple.com
    - time2.apple.com
    - time3.apple.com
    - time4.apple.com
    - time5.apple.com
    - time6.apple.com
    - time7.apple.com
    - time1.google.com
    - time2.google.com
    - time3.google.com
    - time4.google.com
    - music.163.com
    - "*.music.163.com"
    - "*.126.net"
    - musicapi.taihe.com
    - music.taihe.com
    - songsearch.kugou.com
    - trackercdn.kugou.com
    - "*.kuwo.cn"
    - api-jooxtt.sanook.com
    - api.joox.com
    - joox.com
    - y.qq.com
    - "*.y.qq.com"
    - streamoc.music.tc.qq.com
    - mobileoc.music.tc.qq.com
    - isure.stream.qqmusic.qq.com
    - dl.stream.qqmusic.qq.com
    - aqqmusic.tc.qq.com
    - amobile.music.tc.qq.com
    - "*.xiami.com"
    - "*.music.migu.cn"
    - music.migu.cn
    - "*.msftconnecttest.com"
    - "*.msftncsi.com"
    - localhost.ptlogin2.qq.com
    - "*.*.*.srv.nintendo.net"
    - "*.*.stun.playstation.net"
    - xbox.*.*.microsoft.com
    - "*.ipv6.microsoft.com"
    - "*.*.xboxlive.com"
    - speedtest.cros.wr.pvp.net
  nameserver:
    - https://223.6.6.6/dns-query
    - https://rubyfish.cn/dns-query
    - https://dns.pub/dns-query
  fallback:
    - https://dns.rubyfish.cn/dns-query
    - https://public.dns.iij.jp/dns-query
    - tls://8.8.4.4
  fallback-filter:
    geoip: true
    ipcidr:
      - 240.0.0.0/4
      - 0.0.0.0/32
      - 127.0.0.1/32
    domain:
      - +.google.com
      - +.facebook.com
      - +.twitter.com
      - +.youtube.com
      - +.xn--ngstr-lra8j.com
      - +.google.cn
      - +.googleapis.cn
      - +.googleapis.com
      - +.gvt1.com

# 节点信息配置
# 从你的订阅地址下载节点信息,过滤掉不包含香港的节点
proxy-providers:
  AMY-HongKong:
    type: http
    path: ./ProxySet/HongKong.yaml
    url: "你的订阅地址"
    interval: 3600
    filter: "香港"
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300
  AMY-US:
    type: http
    path: ./ProxySet/US.yaml
    url: "你的订阅地址"
    interval: 3600
    filter: "美国"
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300
  AMY-Taiwan:
    type: http
    path: ./ProxySet/Taiwan.yaml
    url: "你的订阅地址"
    interval: 3600
    filter: "台湾"
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300
  AMY-Japan:
    type: http
    path: ./ProxySet/Japan.yaml
    url: "你的订阅地址"
    interval: 3600
    filter: "日本"
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300
  AMY-Singapore:
    type: http
    path: ./ProxySet/Singapore.yaml
    url: "你的订阅地址"
    interval: 3600
    filter: "新加坡"
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300

# 策略组配置
# type字段
# relay代表链式,不支持UDP. 例如流量先经过机场,到达自建节点.出口ip在自建节点,因此ip不变
# url-test测速选择
# select手动选择
# fallback请求失败了才会切换
# load-balance负载均衡,ip可能一直变.
# tolerance字段,宽容毫秒数.如果少于100ms,就不切换节点
# interval字段,5*60秒尝试切换一次
proxy-groups:
  - name: 香港-auto
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 600
    tolerance: 100 # 宽容,新节点速度快老节点少于100ms,就不改.
    use:
      - AMY-HongKong
  - name: 美国-auto
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 600
    tolerance: 150
    use:
      - AMY-US
  - name: 所有-auto
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 600
    use:
      - AMY-HongKong
      - AMY-US
      - AMY-Singapore
      - AMY-Japan
      - AMY-Taiwan

# 从github拿到规则集,用的时候注意behavior,一般readme文件会有写behavior的值
# behavior的含义参考 https://github.com/Dreamacro/clash/issues/1165#issuecomment-753739205
rule-providers:
  ChinaMax:
    type: http
    behavior: classical
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/ChinaMax/ChinaMax.yaml"
    path: ./RuleSet/ChinaMax.yaml
    interval: 86400
  OpenAI:
    type: http
    behavior: domain
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/OpenAI/OpenAI.yaml"
    path: ./RuleSet/OpenAI.yaml
    interval: 86400

# 自定义规则
# 1自定义,2规则集,3国内,4兜底
rules:
  - DOMAIN-SUFFIX,at.alicdn.com,香港-auto
  - DOMAIN-SUFFIX,bet365.com,香港-auto
  - DOMAIN-SUFFIX,ip-api.com,美国-auto
  - DOMAIN-SUFFIX,devblogs.microsoft.com,香港-auto
  - RULE-SET,OpenAI,美国-auto
  - RULE-SET,ChinaMax,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,所有-auto
```

## 安装

### 服务搭建

[[笔记/point/linux|linux]] 下的安装流程:

```shell
mkdir clash
cd clash
# 下载clash https://github.com/Dreamacro/clash/releases/tag/premium
wget https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2023.06.30.gz

# 配置
gunzip clash-linux-amd64-2023.06.30.gz
mv clash-linux-amd64-2023.06.30 clash
chmod +x clash

# 下载geo数据库
https://github.com/Loyalsoldier/geoip/releases/download/202307060123/Country.mmdb

# 贴入配置,建议加上用户名密码
vim config.yaml
```

### 守护进程

[[笔记/point/supervisor|supervisor]] 配置

```toml
[program:clash]
directory = /root/clash
command = /root/clash/clash -d /root/clash

# 启动进程数目默认为1
numprocs = 1
# 如果supervisord是root启动的 设置此用户可以管理该program
user = root
# 程序运行的优先级 默认999
priority = 996

# 随着supervisord 自启动
autostart = true
# 子进程挂掉后无条件自动重启
autorestart = true
# 子进程启动多少秒之后 状态为running 表示运行成功
startsecs = 20
# 进程启动失败 最大尝试次数 超过将把状态置为FAIL
startretries = 3

# 标准输出的文件路径
stdout_logfile = /tmp/clash-supervisor.log
# 日志文件最大大小
stdout_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stdout_logfile_backups = 3
# 错误输出的文件路径
stderr_logfile = /tmp/clash-supervisor.log
# 日志文件最大大小
stderr_logfile_maxbytes=20MB
# 日志文件保持数量 默认为10 设置为0 表示不限制
stderr_logfile_backups = 3
```

### 反向 nginx 代理

因为找了半天, 都没发现 clash 怎么配置 https, 所以通过 nginx 套一层 [[笔记/point/ssl|ssl]] 来保证安全性.

下面的配置通过 tcp 17890 端口代理出去.

```nginx
stream {
    upstream clash {
        hash   $remote_addr consistent;
        server 127.0.0.1:7890;
    }

    server {
        listen 17890 ssl;
        ssl_certificate /etc/nginx/ssl/kentxxq.cer;
        ssl_certificate_key /etc/nginx/ssl/kentxxq.key;
        proxy_connect_timeout   30s;
        proxy_timeout 300s;
        proxy_pass  clash;
    }
}
```

使用方法

```shell
export all_proxy=https://user1:pass1@a.kentxxq.com:17890; 
```

## 参考地址

- [Clash分流策略 | 配置文件 | 订阅防覆盖 | 硬核教程](https://a-nomad.com/clash)
- [Clash规则大全](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Clash)
