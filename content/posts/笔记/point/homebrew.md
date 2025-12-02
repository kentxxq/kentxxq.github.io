---
title: homebrew
tags:
  - point
  - mac
date: 2025-11-22
lastmod: 2025-11-22
categories:
  - point
---

## 命令

```shell
# 更新
brew update

# 升级
brew upgrade

# 清理缓存
rm -rf "$(brew --cache)"


# 包管理
brew install node
# 这个不会自动加到环境变量
brew install node@24
# 手动 link 到环境变量 
brew link --force --overwrite node@24
```
