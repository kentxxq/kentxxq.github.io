---
title: golang的使用
tags:
  - blog
  - golang
date: 2023-06-26
lastmod: 2024-06-07
categories:
  - blog
description: "[[笔记/point/golang|golang]] 用的很少, 记录一下相关的安装, 配置, 构建."
---

## 简介

[[笔记/point/golang|golang]] 用的很少, 记录一下相关的安装, 配置, 构建.

## 操作手册

### 安装 golang

去 [这里下载](https://go.dev/dl/) 最新的 tar 包, 拿 `go1.20.6.linux-amd64.tar.gz` 举例

```shell
# 解压到/usr/local/
tar -C /usr/local/ -xzf go1.20.6.linux-amd64.tar.gz

# 文件内容
root@poc:/usr/local/go# ls -l /usr/local/go
total 68
drwxr-xr-x  2 root root  4096 Jun  2 01:02 api
drwxr-xr-x  2 root root  4096 Jun  2 01:04 bin
-rw-r--r--  1 root root    52 Jun  2 01:01 codereview.cfg
-rw-r--r--  1 root root  1339 Jun  2 01:01 CONTRIBUTING.md
drwxr-xr-x  2 root root  4096 Jun  2 01:02 doc
drwxr-xr-x  3 root root  4096 Jun  2 01:02 lib
-rw-r--r--  1 root root  1479 Jun  2 01:01 LICENSE
drwxr-xr-x 11 root root  4096 Jun  2 01:02 misc
-rw-r--r--  1 root root  1303 Jun  2 01:01 PATENTS
drwxr-xr-x  4 root root  4096 Jun  2 01:04 pkg
-rw-r--r--  1 root root  1455 Jun  2 01:01 README.md
-rw-r--r--  1 root root   419 Jun  2 01:01 SECURITY.md
drwxr-xr-x 49 root root  4096 Jun  2 01:02 src
drwxr-xr-x 26 root root 12288 Jun  2 01:02 test
-rw-r--r--  1 root root     8 Jun  2 01:01 VERSION

# 加入 ~/.bashrc,每次生效
export PATH=$PATH:/usr/local/go/bin:/root/go/bin/
# 此次终端生效
source ~/.bashrc

# 强烈建议配置代理
go env -w GOPROXY=https://goproxy.cn,direct
# 这个也行 https://proxy.golang.com.cn,direct

# 验证效果
go version
go version go1.20.6 windows/amd64
```

### 配置环境变量

```powershell
# 查看变量
go env

# 配置GOPROXY变量,让go使用代理源加速
go env -w GOPROXY=https://goproxy.cn,direct

# 常用构建配置
# 完整版参考 https://go.dev/doc/install/source#environment
$GOOS $GOARCH
windows amd64
linux amd64
linux arm64
darwin amd64
darwin amd64
```

## 相关工具

- 代码的问题检查 [Quick Start | golangci-lint](https://golangci-lint.run/welcome/quick-start/)
