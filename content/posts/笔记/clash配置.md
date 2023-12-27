---
title: clash配置
tags:
  - blog
  - clash
date: 2023-07-12
lastmod: 2023-12-27
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
port: 7890
socks-port: 7891
redir-port: 7892
mixed-port: 7893
# authentication:
#   - "usr1:pass1"
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
dns:
  enable: true
  listen: 127.0.0.1:8853
  default-nameserver:
    - 223.5.5.5
    - 1.0.0.1
  ipv6: false
  enhanced-mode: fake-ip
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
    tolerance: 100
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
    type: select
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
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/ChinaMax/ChinaMax_Classical.yaml"
    path: ./RuleSet/ChinaMax.yaml
    interval: 86400
  OpenAI:
    type: http
    behavior: classical
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/OpenAI/OpenAI.yaml"
    path: ./RuleSet/OpenAI.yaml
    interval: 86400
  Microsoft:
    type: http
    behavior: classical
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/Microsoft/Microsoft.yaml"
    path: ./RuleSet/Microsoft.yaml
    interval: 86400
  GitLab:
    type: http
    behavior: classical
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/GitLab/GitLab.yaml"
    path: ./RuleSet/GitLab.yaml
    interval: 86400
  GitHub:
    type: http
    behavior: classical
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/GitHub/GitHub.yaml"
    path: ./RuleSet/GitHub.yaml
    interval: 86400
  Google:
    type: http
    behavior: classical
    url: "https://ghproxy.com/https://github.com/blackmatrix7/ios_rule_script/blob/master/rule/Clash/GitHub/GitHub.yaml"
    path: ./RuleSet/Google.yaml
    interval: 86400

# 自定义规则
# 1自定义,2规则集,3国内,4兜底
rules:
  - DOMAIN-SUFFIX,at.alicdn.com,香港-auto
  - DOMAIN-SUFFIX,bet365.com,香港-auto
  - DOMAIN-SUFFIX,ip-api.com,美国-auto
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  - RULE-SET,Google,香港-auto
  - RULE-SET,GitHub,香港-auto
  - RULE-SET,GitLab,香港-auto
  - RULE-SET,Microsoft,香港-auto
  - RULE-SET,OpenAI,美国-auto
  - RULE-SET,ChinaMax,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,所有-auto
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

#todo/笔记 来个示意图, 同时把守护进程换了

### 服务搭建

> [!warning]
> clash 相关资源已经被删, 建议去 https://github.com/MetaCubeX/mihomo 下载替代下面的路径

[[笔记/point/linux|linux]] 下的安装流程:

```shell
mkdir clash ; cd clash
# 下载clash
wget https://github.com/Dreamacro/clash/releases/download/premium/clash-linux-amd64-2023.06.30.gz

# 配置
gunzip clash-linux-amd64-2023.06.30.gz
mv clash-linux-amd64-2023.06.30 clash
chmod +x clash

# 下载geo数据库
wget https://github.com/Loyalsoldier/geoip/releases/download/202307060123/Country.mmdb

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
ExecStart=/root/clash/clash -d /root/clash
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
  - 172.29.*``
  - 172.30.*
  - 172.31.*
  - 192.168.*
  - <local>
```

### 绕过 windows 应用

类似于 [[笔记/point/windows|windows]] 的应用商店, 邮箱等应用开启代理后会无法访问.

可以通过 `UWP Loopback` 跳过.

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

- [hysteria内核](https://github.com/apernet/hysteria)
- [Xray-core是v2ray-core的超集](https://github.com/XTLS/Xray-core) 内核
- [sing-box](https://github.com/SagerNet/sing-box) 内核
- clash 内核
    - [Clash.Meta](https://github.com/MetaCubeX/Clash.Meta/tree/Alpha) 内核
    - [clash-verge](https://github.com/zzzgydi/clash-verge) 客户端
    - [clashN](https://github.com/2dust/clashN) 客户端
    - [v2rayN](https://github.com/2dust/v2rayN) 客户端
    - `ClashForWindows` 被删了, 但还有汉化版存在
        - [Releases · Z-Siqi/Clash-for-Windows_Chinese (github.com)](https://github.com/Z-Siqi/Clash-for-Windows_Chinese)
        - [BoyceLig/Clash_Chinese_Patch: Clash For Windows 汉化补丁和汉化脚本 (github.com)](https://github.com/BoyceLig/Clash_Chinese_Patch)
- 安卓
    - [Surfboard - Apps on Google Play](https://play.google.com/store/apps/details?id=com.getsurfboard&hl=en_US)
    - clashforandroid
- ios 工具
    - QuantumultX (圈 X) 强大工具
    - Loon 新工具, 对标 QuantumultX
    - Stash ,兼容 clash
    - Surge 最老牌, ios+mac
    - Shadowrocket 大众化 + 便宜
    - Spectre 免费
    - 相关讨论
        - https://www.v2ex.com/t/989650
- 服务商
    - [佩奇小站 - AmyTelecom](https://www.amysecure.com/clientarea.php?action=productdetails&id=14674)
    - [魅影小站 - Ark](https://ark.to/user)
    - 唯云四杰好像是有口碑的
    - [一个机场收录站点](https://dh.duangks.com/)
- [Clash分流策略 | 配置文件 | 订阅防覆盖 | 硬核教程](https://a-nomad.com/clash)
- [Clash规则大全](https://github.com/blackmatrix7/ios_rule_script/tree/master/rule/Clash)
- [GFW是如何工作的](https://gfw.report/publications/usenixsecurity23/zh/)
 

### 代理站点

- [[笔记/docker镜像源|docker镜像源]]
- [github 代理](https://mirror.ghproxy.com)
