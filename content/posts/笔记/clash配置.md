---
title: clash配置
tags:
  - blog
  - clash
date: 2023-07-12
lastmod: 2025-07-22
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

## 快速配置

### 配置模板 - 复制保存成 yml

```yml
# 默认走代理

# 原版文档 https://clash-meta.gitbook.io/
# mihomo文档 https://wiki.metacubex.one/
# mihomo完整配置 https://github.com/MetaCubeX/mihomo/blob/Meta/docs/config.yaml
# stash文档 https://stash.wiki/
port: 7890
socks-port: 7891
redir-port: 7892
mixed-port: 7893
# authentication:
#   - "usr1:pass1"
allow-lan: true
mode: rule
log-level: info
ipv6: false
# hosts:
external-controller: 0.0.0.0:9090
clash-for-android:
  append-system-dns: false
profile:
  tracing: true
# 嗅探
sniffer:
  sniff:
    TLS: { ports: [0-65535], override-destination: true }
    HTTP: { ports: [0-65535], override-destination: true }
    QUIC: { ports: [0-65535], override-destination: true }
  enable: true
  parse-pure-ip: true
  force-dns-mapping: true
  skip-domain:
    - "Mijia Cloud"
    - "dlg.io.mi.com"
    - "+.apple.com"
# https://wiki.metacubex.one/config/dns/
dns:
  enable: true
  ipv6: false # 都说可能会影响体验,关掉
  prefer-h3: true
  listen: 0.0.0.0:53
  # default-nameserver 是用来解析 nameserver 和 fallback 里面的域名的
  # 必须是ip, 可以是加密dns
  default-nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - 8.8.8.8
    - 1.1.1.1
  # 解析流程 https://wiki.metacubex.one/config/dns/diagram/
  # 0级 先在这里解析
  nameserver-policy:
    "geosite:cn,private,apple":
      - https://223.5.5.5/dns-query#h3=true
      - https://dns.alidns.com/dns-query
      - https://doh.pub/dns-query
  # 2级 这里是默认解析配置
  nameserver:
    - https://223.5.5.5/dns-query#h3=true
    - https://dns.alidns.com/dns-query
    - https://dns.pub/dns-query
    - https://8.8.8.8/dns-query
    - https://1.1.1.1/dns-query
  # 2025年3月10日 特殊的会议期间,下面2个dns都连接超时,无法访问.导致访问速度很慢. 所以建议不配置
  # 1级 这里是特定解析配置. 如果这里匹配了, 这里优先级比nameserver高
  # fallback 用来配置特定域名的dns解析使用fallback的dns服务器
  # clash原版内核依赖这个功能分流, 但是clash meta可以不用 https://hk.v2ex.com/t/1015534
  # fallback:
  #   - https://8.8.8.8/dns-query
  #   - https://1.1.1.1/dns-query
  # fallback-filter:
  #   geoip: true         #为真时，不匹配为geoip规则的使用fallback返回结果
  #   geoip-code: CN      #geoip匹配区域设定
  #   ipcidr:             #列表中的ip使用fallback返回解析结果
  #     - 240.0.0.0/4
  #     - 0.0.0.0/32
  #     - 127.0.0.1/32
  #   domain:             #列表中的域名使用fallback返回解析结果
  #     - +.google.com
  #     - +.facebook.com
  #     - +.twitter.com
  #     - +.youtube.com
  #     - +.xn--ngstr-lra8j.com
  #     - +.google.cn
  #     - +.googleapis.cn
  #     - +.googleapis.com
  #     - +.gvt1.com
  # 给域名一个内网地址fake-ip,连接完全通过自定义的方式和外部对接. 最大程度避免dns污染攻击 https://clash.wiki/configuration/dns.html
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  # 下面这些地址不会下发fake-ip
  fake-ip-filter:
    - "*.lan"
    - "*.localdomain"
    - "*.example"
    - "*.invalid"
    - "*.localhost"
    - "*.test"
    - "*.local"
    - "*.home.arpa"
    - time.*.com
    - time.*.gov
    - time.*.edu.cn
    - time.*.apple.com
    - time1.*.com
    - time2.*.com
    - time3.*.com
    - time4.*.com
    - time5.*.com
    - time6.*.com
    - time7.*.com
    - ntp.*.com
    - ntp1.*.com
    - ntp2.*.com
    - ntp3.*.com
    - ntp4.*.com
    - ntp5.*.com
    - ntp6.*.com
    - ntp7.*.com
    - "*.time.edu.cn"
    - "*.ntp.org.cn"
    - +.pool.ntp.org
    - time1.cloud.tencent.com
    - stun.*.*
    - stun.*.*.*
    - swscan.apple.com
    - mesu.apple.com
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
    - y.qq.com
    - "*.y.qq.com"
    - streamoc.music.tc.qq.com
    - mobileoc.music.tc.qq.com
    - isure.stream.qqmusic.qq.com
    - dl.stream.qqmusic.qq.com
    - aqqmusic.tc.qq.com
    - amobile.music.tc.qq.com
    - "*.msftconnecttest.com"
    - "*.msftncsi.com"
    - "*.xiami.com"
    - "*.music.migu.cn"
    - music.migu.cn
    - +.wotgame.cn
    - +.wggames.cn
    - +.wowsgame.cn
    - +.wargaming.net
    - "*.*.*.srv.nintendo.net"
    - "*.*.stun.playstation.net"
    - xbox.*.*.microsoft.com
    - "*.*.xboxlive.com"
    - "*.ipv6.microsoft.com"
    - teredo.*.*.*
    - teredo.*.*
    - speedtest.cros.wr.pvp.net
    - +.jjvip8.com
    - www.douyu.com
    - activityapi.huya.com
    - activityapi.huya.com.w.cdngslb.com
    - www.bilibili.com
    - api.bilibili.com
    - a.w.bilicdn1.com
    # QQ快速登录检测失败
    - localhost.ptlogin2.qq.com
    - localhost.sec.qq.com
    # 微信快速登录检测失败
    - localhost.work.weixin.qq.com
# 节点信息配置
# 从你的订阅地址下载节点信息,过滤掉不包含香港的节点
proxy-providers:
  AMY-HongKong:
    type: http
    path: ./ProxySet/HongKong.yaml
    url: "订阅地址"
    interval: 3600
    filter: "香港"
    health-check:
      enable: true
      url: https://www.google.com/favicon.ico
      interval: 300
  AMY-US:
    type: http
    path: ./ProxySet/US.yaml
    url: "订阅地址"
    interval: 3600
    filter: "美国"
    health-check:
      enable: true
      url: https://www.google.com/favicon.ico
      interval: 300
  AMY-Taiwan:
    type: http
    path: ./ProxySet/Taiwan.yaml
    url: "订阅地址"
    interval: 3600
    filter: "台湾"
    health-check:
      enable: true
      url: https://www.google.com/favicon.ico
      interval: 300
  AMY-Japan:
    type: http
    path: ./ProxySet/Japan.yaml
    url: "订阅地址"
    interval: 3600
    filter: "日本"
    health-check:
      enable: true
      url: https://www.google.com/favicon.ico
      interval: 300
  AMY-Singapore:
    type: http
    path: ./ProxySet/Singapore.yaml
    url: "订阅地址"
    interval: 3600
    filter: "新加坡"
    health-check:
      enable: true
      url: https://www.google.com/favicon.ico
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
    url: https://www.google.com/favicon.ico
    interval: 60
    tolerance: 100
    use:
      - AMY-HongKong
  - name: 美国-auto
    type: url-test
    url: https://www.google.com/favicon.ico
    interval: 60
    tolerance: 100
    use:
      - AMY-US
  - name: no-hk-fallback
    type: fallback
    url: https://www.google.com/favicon.ico
    interval: 60
    use:
      - AMY-Japan
      - AMY-Singapore
      - AMY-Taiwan
      - AMY-US
  - name: 所有-fallback
    type: fallback
    url: https://www.google.com/favicon.ico
    interval: 60
    use:
      - AMY-HongKong
      - AMY-US
      - AMY-Singapore
      - AMY-Japan
      - AMY-Taiwan
  - name: 所有-select
    type: select
    url: https://www.google.com/favicon.ico
    interval: 60
    use:
      - AMY-HongKong
      - AMY-US
      - AMY-Singapore
      - AMY-Japan
      - AMY-Taiwan

# 从github拿到规则集,用的时候注意behavior,一般readme文件会有写behavior的值
# behavior的含义参考 https://github.com/Dreamacro/clash/issues/1165#issuecomment-753739205
rule-providers:
  # NeedProxy:
  #   type: http
  #   behavior: classical
  #   url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Proxy/Proxy_Classical.yaml"
  #   path: ./RuleSet/NeedProxy.yaml
  #   interval: 86400
  Github:
    type: http
    behavior: classical
    url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/GitHub/GitHub.yaml"
    path: ./RuleSet/Github.yaml
    interval: 86400
  youtube:
    type: http
    behavior: classical
    url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/YouTube/YouTube.yaml"
    path: ./RuleSet/YouTube.yaml
    interval: 86400
  China:
    type: http
    behavior: classical
    url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/China/China.yaml"
    path: ./RuleSet/China.yaml
    interval: 86400
  # ChinaMax:
  #   type: http
  #   behavior: classical
  #   url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/ChinaMax/ChinaMax_Classical.yaml"
  #   path: ./RuleSet/ChinaMax.yaml
  #   interval: 86400
  OpenAI:
    type: http
    behavior: classical
    url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/OpenAI/OpenAI.yaml"
    path: ./RuleSet/OpenAI.yaml
    interval: 86400
  Google:
    type: http
    behavior: classical
    url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Google/Google.yaml"
    path: ./RuleSet/Google.yaml
    interval: 86400
  Douyin:
    type: http
    behavior: classical
    url: "https://gh-proxy.com/https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/DouYin/DouYin.yaml"
    path: ./RuleSet/Douyin.yaml
    interval: 86400
  amy-classical-DIRECT:
    type: http
    behavior: classical
    url: "https://gh-proxy.com/https://raw.githubusercontent.com/kentxxq/public-config/main/clash/amy-classical-DIRECT.yaml"
    path: ./RuleSet/amy-classical-DIRECT.yaml
    interval: 86400

# 自定义规则
# 1自定义,2规则集,3国内,4兜底
rules:
  # 阿里云部分内容
  - DOMAIN-SUFFIX,at.alicdn.com,所有-fallback
  # 阿里云数据库
  - DOMAIN-SUFFIX,aliyuncs.com,DIRECT
  # qq
  - DOMAIN-SUFFIX,qq.com,DIRECT
  # pikpak网盘
  - DOMAIN-SUFFIX,mypikpak.com,所有-fallback
  # c#网站
  - DOMAIN-SUFFIX,fuget.org,所有-fallback
  # 菠菜
  - DOMAIN-SUFFIX,bet365.com,所有-fallback
  # ip查询
  - DOMAIN-SUFFIX,ip-api.com,no-hk-fallback
  # 算法学习
  - DOMAIN-SUFFIX,hello-algo.com,no-hk-fallback
  # wireshark抓包下载
  - DOMAIN-SUFFIX,wireshark.org,所有-fallback
  # dockerhub用到了
  - DOMAIN-SUFFIX,cloudfront.net,所有-fallback
  # nodejs项目vben用到了
  - DOMAIN-SUFFIX,vben.vvbin.cn,所有-fallback
  # sourceforge.net下载
  - DOMAIN-SUFFIX,sourceforge.net,所有-fallback
  # ide
  - DOMAIN-SUFFIX,jetbrains.com,所有-fallback
  # 其他
  - DOMAIN-SUFFIX,v2ex.com,所有-fallback
  - DOMAIN-SUFFIX,gh-proxy.com,DIRECT
  - DOMAIN-SUFFIX,smtp.gmail.com,DIRECT
  # windows更新
  - DOMAIN-SUFFIX,windowsupdate.com,DIRECT
  - DOMAIN-SUFFIX,npmmirror.com,DIRECT
  # - DOMAIN-SUFFIX,kentxxq.com,DIRECT
  - DOMAIN-SUFFIX,chinnshi.com,DIRECT
  - DOMAIN-SUFFIX,imshini.com,DIRECT
  - DOMAIN-SUFFIX,shimeow.com,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  # 规则集
  - RULE-SET,Douyin,DIRECT
  - RULE-SET,Github,所有-fallback
  - RULE-SET,youtube,所有-fallback
  - RULE-SET,Google,no-hk-fallback
  - RULE-SET,OpenAI,no-hk-fallback
  # amy
  - RULE-SET,amy-classical-DIRECT,DIRECT
  # - RULE-SET,NeedProxy,所有-fallback
  # - RULE-SET,ChinaMax,DIRECT
  - RULE-SET,China,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,所有-fallback
  # - MATCH,DIRECT

```

### 配置模板 - 修改必要信息

修改订阅信息:

```yml
proxy-providers:
  AMY-HongKong:
    type: http
    path: ./ProxySet/HongKong.yaml
    url: "你的订阅地址"
    interval: 3600
    # 你的香港节点包含"香港"两个字,就填香港.包含"HK",就填"HK"
    filter: "香港"
    health-check:
      enable: true
      url: http://www.gstatic.com/generate_204
      interval: 300
```

注意 [Stash](https://stash.wiki/)

- dns 不兼容 `nameserver-policy`
- 修改 http3 使用方式 `http3://223.5.5.5/dns-query`

```yaml
# 不兼容的注释掉
# nameserver-policy:
#   "geosite:cn,private,apple":
#     - https://223.5.5.5/dns-query#h3=true
#     - https://dns.alidns.com/dns-query
#     - https://doh.pub/dns-query

# 使用stash支持的http3格式
nameserver:
  # - https://223.5.5.5/dns-query#h3=true
  - http3://223.5.5.5/dns-query
  - https://dns.alidns.com/dns-query
  - https://dns.pub/dns-query
  - https://8.8.8.8/dns-query
  - https://1.1.1.1/dns-query
```

如果有自己特定的规则, 例如特定 ip, 特定网站需要走代理节点. 可以添加自定义规则:

- `DOMAIN-SUFFIX`：域名后缀匹配
- `DOMAIN`：域名匹配
- `DOMAIN-KEYWORD`：域名关键字匹配
- `IP-CIDR`：IP 段匹配
- `SRC-IP-CIDR`：源 IP 段匹配
- `GEOIP`：GEOIP 数据库（国家代码）匹配
- `DST-PORT`：目标端口匹配
- `SRC-PORT`：源端口匹配
- `PROCESS-NAME`：源进程名匹配
- `RULE-SET`：Rule Provider 规则匹配
- `MATCH`：全匹配

### 导入配置文件

#### clash-verge

- 通过 `ClashVerge=>配置=>新建`, 类型 `local`,选择配置文件导入即可
- 也可以使用类型 `remote`, 不过这里会用到我的 [[笔记/TestServer工具|TestServer工具]].

#### clash-for-windows

- `clash界面=>Profiles=>Import选择你的yml文件`
- 也可以使用类型 `remote`, 不过这里会用到我的 [[笔记/TestServer工具|TestServer工具]].

## linux 下的 clash 安装

### 服务搭建

[[笔记/point/linux|linux]] 下的安装流程:

```shell
mkdir clash ; cd clash
# 下载clash
wget https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-amd64-alpha-7b38261.gz

# 配置
gunzip mihomo-linux-amd64-alpha-7b38261.gz
mv mihomo-linux-amd64-alpha-7b38261 mihomo
chmod +x clash

# 下载需要用到的文件到/root/clash
wget https://github.com/Loyalsoldier/geoip/releases/download/202307060123/Country.mmdb
wget https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat
wget https://github.com/xishang0128/geoip/releases/download/latest/GeoLite2-ASN.mmdb

# 贴入配置,建议加上用户名密码
vim config.yaml
```

### 守护进程

[[笔记/point/Systemd|Systemd]] 配置文件 `/etc/systemd/system/clash.service`

```toml
[Unit]
Description=clash
# 启动区间30s内,尝试启动3次
StartLimitIntervalSec=30
StartLimitBurst=3

[Service]
# 环境变量 $MY_ENV1
# Environment=MY_ENV1=value1
# Environment="MY_ENV2=value2"
# 环境变量文件,文件内容"MY_ENV3=value3" $MY_ENV3
# EnvironmentFile=/path/to/environment/file1

WorkingDirectory=/root/clash
ExecStart=/root/clash/mihomo -d /root/clash
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
Alias=clash.service
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
# linux
export all_proxy=https://user1:pass1@a.kentxxq.com:17890; 
# windows
set all_proxy=https://user1:pass1@a.kentxxq.com:17890; 
```

## API

### 调整配置

[参考网址](https://clash.gitbook.io/doc/restful-api/config)

```shell
# 查看当前配置
curl -X GET http://127.0.0.1:9090/configs

# 切换成全局
curl -X PATCH http://127.0.0.1:9090/configs -d '{"mode":"GLOBAL"}'

# 查看可用，一般有一个global
curl -X GET http://127.0.0.1:9090/proxies

# 查看global的配置，一般它的type是selector。而api只支持切换selector
curl -X GET http://127.0.0.1:9090/proxies/GLOBAL

# 切换到global里面的美国a节点
curl -v -X PUT 'http://127.0.0.1:9090/proxies/GLOBAL'  -H "Content-Type: application/json" --data-raw '{"name": "美国 A"}'
```

## ClashForWindows 应用配置

### 过期说明

虽然 `ClashForWindows` 已经被删, 但是网上还是有一些 fork/中文包版本存在.

因此此章节内容仍然具备可操作性. 同时也可以帮助理解 `UWP Loopback`, `bypass` 等相关概念.

### 绕过系统代理

- 功能说明: 配置后开启系统代理, 可以在操作系统的网络配置界面找到 (win 11 设置=>网络和 internet=>代理=>手动设置代理=>编辑)
 - clash 配置:  `Settings` => `System Proxy` => `Bypass Domain/IPNet`

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
      - 172.29.*``
      - 172.30.*
      - 172.31.*
      - 192.168.*
      - <local>
    ```

### 绕过 windows 应用

开启代理后 [[笔记/point/windows|windows]] 的应用商店, 邮箱等应用网络无法访问.

这时候可以通过 `UWP Loopback` 跳过.

![[附件/clash的UWP操作图.png]]

### 覆盖现有配置内容

[配置文件预处理](https://docs.cfw.lbyczf.com/contents/parser.html#%E7%AE%80%E4%BE%BF%E6%96%B9%E6%B3%95-yaml) 适用于**不想修改配置文件, 特定于当前机器的特殊配置**

|键|值类型|操作|
|---|---|---|
|append-rules|数组|数组合并至原配置 `rules` 数组**后**|
|prepend-rules|数组|数组合并至原配置 `rules` 数组**前**|
|append-proxies|数组|数组合并至原配置 `proxies` 数组**后**|
|prepend-proxies|数组|数组合并至原配置 `proxies` 数组**前**|
|append-proxy-groups|数组|数组合并至原配置 `proxy-groups` 数组**后**|
|prepend-proxy-groups|数组|数组合并至原配置 `proxy-groups` 数组**前**|
|mix-proxy-providers|对象|对象合并至原配置 `proxy-providers` 中|
|mix-rule-providers|对象|对象合并至原配置 `rule-providers` 中|
|mix-object|对象|对象合并至原配置最外层中|
|commands|数组|在上面操作完成后执行简单命令操作配置文件|

`Settings=>Profiles=>Parsers=>edit` 进入

```yml
parsers:
  - url: https://example.com/profile.yaml
    yaml:
      prepend-rules:
        - DOMAIN,test.com,DIRECT # rules最前面增加一个规则
      append-proxies:
        - name: test # proxies最后面增加一个服务
          type: http
          server: 123.123.123.123
          port: 456
```

## 测试

#todo/笔记 快速验证代理走的什么网络!

## 疑难杂症

### 配合 gost 内网转发

```yaml
- name: 名称-socks5
  type: socks5
  server: ip
  port: 端口
  username: 用户名
  password: 密码
- name: 名称-http
  type: http
  server: ip
  port: 端口
  username: 用户名
  password: 密码
```

匹配规则

```yaml
- IP-CIDR,172.16.0.1/16,qskj,no-resolve
```

### 企业微信不兼容

- 主动配置企业微信使用 socket 代理 `127.0.0.1:7890`
- 也可以尝试

    ```yaml
    prepend-rules:
    - PROCESS-NAME, WXWork.exe, DIRECT
    ```

### 安卓 app 不兼容代理

即使配置了合适的分流规则, 京东, bilibili, 知乎等 app 兼容性还是有问题.

- **推荐**配置应用分流. 允许服务跳过白名单/黑名单模式. 让指定应用绕过代理.
- 在 clash 中，关闭 <为 vpn service 附加 http 代理> 对我来说**效果不好**

相关内容:

- 安卓的 vpn 是 `vpnservice` 实例. 白名单/黑名单是安卓 api, 因此并不是在 app 内进行分流判断, 更省电. [安卓文档地址](https://developer.android.com/develop/connectivity/vpn?hl=zh-cn#java)
- [Android 版 Clash 的“系统代理”选项是什么意思 - V2EX](https://www.v2ex.com/t/926870)
- [京东故意降低 vpn 用户体验 - V2EX](https://v2ex.com/t/933158)

## 相关资源

### 代理工具

- [🐬海豚测速](https://www.haitunt.org/)
- [KaringX/clashmi: Clash Mihomo for iOS/Android](https://github.com/KaringX/clashmi)
- [hysteria内核](https://github.com/apernet/hysteria)
- [Xray-core是v2ray-core的超集](https://github.com/XTLS/Xray-core) 内核
- [sing-box](https://github.com/SagerNet/sing-box) 内核
- clash 内核 [友情链接](https://clash-verge-rev.github.io/friendship.html)
    - [Clash.Meta](https://github.com/MetaCubeX/Clash.Meta/tree/Alpha) 内核
    - [GitHub - clash-verge-rev/clash-verge-rev: Continuation of Clash Verge - A Clash Meta GUI based on Tauri (Windows, MacOS, Linux)](https://github.com/clash-verge-rev/clash-verge-rev)
    - [clash-verge](https://github.com/zzzgydi/clash-verge) 客户端
    - [clashN](https://github.com/2dust/clashN) 客户端
    - [v2rayN](https://github.com/2dust/v2rayN) 客户端
    - [mihomo-party](https://github.com/mihomo-party-org/mihomo-party)
    - `ClashForWindows` 被删了, 但还有汉化版存在
        - [Releases · Z-Siqi/Clash-for-Windows_Chinese (github.com)](https://github.com/Z-Siqi/Clash-for-Windows_Chinese)
        - [BoyceLig/Clash_Chinese_Patch: Clash For Windows 汉化补丁和汉化脚本 (github.com)](https://github.com/BoyceLig/Clash_Chinese_Patch)
- 安卓
    - [Surfboard - Apps on Google Play](https://play.google.com/store/apps/details?id=com.getsurfboard&hl=en_US)
    - clashforandroid
- ios 工具
    - QuantumultX (圈 X) 强大工具, 全平台包含 mac
    - Loon 新工具, 对标 QuantumultX
    - Stash ,兼容 clash.
    - Surge 最老牌, ios+mac
    - Shadowrocket 大众化 + 便宜
    - Spectre 免费
    - sing-box 免费
    - 相关讨论
        - https://www.v2ex.com/t/989650
        - https://www.v2ex.com/t/1121952
- 服务商
    - 策略
        - 主机场为大厂, 稳定/性能有保障
        - 备用选相对小厂, 不和主机厂相同线路!  不限时间按量购买, 或者 1 元机场 , 或者 jms 这种企业级支持
            - jms 有多重线路
            - 自建通常就是用 CN2 线路的独立 VPS
        - 需要考虑的特点
            - 设备在线数限制
            - 专线>公网中转>直连
            - 支持 `ipv6`
            - 不限时流量计费 [2025年按流量付费的机场推荐 | 适合作备用机场 - Kerry的学习笔记](https://kerrynotes.com/best-vpn-pay-by-traffic/)
            - emby 等流媒体共享
            - 流量结转
    - 不限制客户端数量
        - [佩奇小站 - AmyTelecom](https://www.amysecure.com/clientarea.php?action=productdetails&id=14674) 被攻击
        - [狗狗加速](https://xn--yfrp36ea9901a.com/) clash-verge-dev 的赞助商, 支持 appleid 登录
        - [大哥云](https://aff01.dgy02.com/#/login)
        - [FlowerCloud - 花云](https://huacloud.dev/) , [花云帮助中心](https://help.huacloud.dev/) , 有 0.2 倍率, 大于 imm, 差于 amy
        - [YToo - 国际加速个人版](https://stentvessel.shop/pricing/individual)
        - [龙猫云机场-最具性价比IPLC专线机场](https://lmva-duyb01.cc/login) 被攻击
        - [AIFUN](https://afun.la/) 被攻击
        - [一云梯-最具性价比IPLC专线机场](https://1ytcom01.1yunti.net/login)
        - [CTC](https://www.jinglongyu.com/#/login) 还有 ctc 02 被攻击
        - [青云梯机场-最具性价比IPLC专线机场](https://qytcc01a.qingyunti.pro/login)
        - [WestData - 西部数据 - 西数](https://wd-cloud.net/)
        - [FlyingBird 飞鸟](https://fbva-dur01.pro/auth/register) usdt 不稳?
        - [ssr](https://ace-taffy.com/auth/register) 被攻击
        - [闪狐云-BGP入口+IPLC专线出口，稳定，延迟低](https://w06.ffwebb01.cc/login)
        - [DlerCloud - 树洞](https://dlercloud.com/datacenter), 支持按量计费，似乎没有被 ddos 波及，口碑好. 墙洞，奶昔 affman 前女友频道管理员 - 雪王
        - [LinkCube](https://www.linkcube.org/cart.php)
        - [CYLINK](https://2cy.io/auth/register) 和 [DOGESS(原n3ro, 易主多次)](https://dddoge.xyz/auth/login) 应该是一家
        - [魔戒 按量计费](https://mojie.ws/#/register) , 分站[八戒](https://bajie.pw/#/register) 被攻击
        - [泰山](https://taishan.pro) 有按量
    - 限制客户端数量/同时在线数
        - [ByWave ](https://t.me/s/bywavego) 10 个在线
        - [阿拉丁](https://tutorial.aladdinnet.cc/) 15 个 ip/30 元/月 emby/等账号
        - [ark-魅影小站](https://ark.to/user)
        - [库洛米 Kuromis](https://www.kuromis.com/)
        - [imm](https://immtele.com/cart.php)
        - 魅影极速,少数派,飞机云,疾风云,CreamData,泡芙云,蓝帆云,速云梯,奶瓶,尔湾云,优信云, [BoostNet](https://boostnet2.com/#/register?code=Pj4Wrfai)
        - [tag 机场](https://tagxx.vip) 限制 10 个 , 有 emby , 家宽, 维云, 有被攻击
        - [mesl](https://cdn9.meslcloud.com/) 6 个, 有新疆节点, 有被攻击
    - 信息源参考
        - [一个机场收录站点](https://dh.duangks.com/)
        - [机场跑路追踪](https://github.com/limbopro/Paolujichang/issues)
        - [机场推荐（2025年7月16日更新） - 毒奶 - 欢迎使用代理访问本站。](https://limbopro.com/865.html)
        - [2025机场推荐与机场评测SSR/V2ray/Trojan订阅 - 机场推荐与机场评测](https://jichangtuijian.com/ssr-v2ray%E4%B8%93%E7%BA%BF%E6%9C%BA%E5%9C%BA%E6%8E%A8%E8%8D%90.html)
        - [GitHub - aiboboxx/clashfree: clash节点、免费clash节点、免费节点、免费梯子、clash科学上网、clash翻墙、clash订阅链接、clash for Windows、clash教程、免费公益节点、最新clash免费节点订阅地址、clash免费节点每日更新](https://github.com/aiboboxx/clashfree)
    - 一元机场
        - [http://两元店.com/](http://xn--5hqx9equq.com/)  
        - [http://一元机场.com](http://xn--4gq62f52gdss.com/)  
        - [http://五毛机场.com/](http://xn--dlqs4sc0nope.com/)  
        - [http://二角五.xyz/](http://xn--4kqqa1166b.xyz/)  
        - [http://三分机场.xyz/](http://xn--ehq00hgtfdmt.xyz/)  
        - [http://免费机场.com/](http://xn--94q57lcvpw50b.com/)  
        - [http://性价比机场.com/](http://xn--6nq44r2uh9rhj7f.com/)  
        - [http://低价机场.com/](http://xn--6nq0hk9tdjr.com/)  
        - [http://翻墙机场.net/](http://xn--mest5a943ag8x.net/)
- [Clash分流策略 | 配置文件 | 订阅防覆盖 | 硬核教程](https://a-nomad.com/clash)
- [Clash规则大全](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Clash)
- GFW
    - [GFW是如何工作的](https://gfw.report/publications/usenixsecurity23/zh/)
    - [墙居然有连接数配额 - V2EX](https://www.v2ex.com/t/1144752)
 
