---
title: proxychains
tags:
  - point
  - proxychains
date: 2023-08-14
lastmod: 2023-08-14
categories:
  - point
---

`proxychains` 是 [[笔记/point/linux|linux]] 下一个优秀的代理工具, 通常需要配合 [[笔记/point/clash|clash]] 使用.

## 使用

```shell
# 安装
apt install proxychains -y
# 连接到clash的本地7891端口
vim /etc/proxychains.conf
# ProxyList format
#       type  host  port [user pass]
#       (values separated by 'tab' or 'blank')
#
#
#        Examples:
#
#               socks5  192.168.67.78   1080    lamer   secret
#               http    192.168.89.3    8080    justu   hidden
#               socks4  192.168.1.49    1080
#               http    192.168.39.93   8080    
#               
#
#       proxy types: http, socks4, socks5
#        ( auth types supported: "basic"-http  "user/pass"-socks )
#
[ProxyList]
socks5  127.0.0.1 7891

# 进入一个代理bash
proxychains bash
```
