---
title: js
aliases:
  - JavaScript
  - nodejs
tags:
  - point
  - js
date: 2023-07-06
lastmod: 2023-12-29
categories:
  - point
---

`JavaScript` 是一门动态编程语言.

要点:

- 异步
- 社区非常庞大
- 浏览器 web 上统一标准

## 命令

### 镜像源

```shell
npm config set registry https://registry.npmmirror.com

yarn config set registry https://registry.npmmirror.com/

# 加速二进制文件下载
npm i --registry=https://registry.npmmirror.com --disturl=https://npmmirror.com/dist
```

### 配置缓存

[npm缓存配置](https://docs.npmjs.com/cli/v6/commands/npm-cache) 默认路径 `~/.npm on Posix` 或者 `%AppData%/npm-cache on Windows`

```shell
# 配置缓存路径
npm config set cache q:\cache\js
# 或者
setx /M npm_config_cache q:\cache\js
# 验证命令. 包会存放在配置的路径,而不是默认路径
npm install -g typescript
```
