---
title: git教程
tags:
  - git
  - blog
date: 2023-06-21
lastmod: 2023-07-26
categories:
  - blog
description: "这里用来记录一些我可能用到的 [[笔记/point/git|git]] 命令. 每次去网上搜集都很麻烦, 还需要验证. 而这里的命令都经过了我的验证.."
---

## 简介

这里用来记录一些我可能用到的 [[笔记/point/git|git]] 命令. 每次去网上搜集都很麻烦, 还需要验证. 而这里的命令都经过了我的验证..

## 具体操作

### 规范 commit

- `feat`: 新功能 (feature)
- `update`: 在 feat 内的修改
- `fix`: 修补 bug
- `docs`: 文档 (documentation)
- `style`: 格式（不影响代码运行的变动)  
- `refactor`: 重构 (即不是新增功能，也不是修改 bug 的代码变动)
- `perf`: 性能优化 (performance)
- `test`: 增加测试
- `thore`: 构建过程或辅助工具的变动

### 克隆与加速

```shell
# clone 特定tag或release
git clone -b v111 xxx.git
# 深度为1的clone
git clone --depth 1 xxx.git

# 代理克隆
git clone https://ghproxy.com/https://github.com/kentxxq/hugo.git
# 私有仓库配合token使用.
git clone https://user:your_token@ghproxy.com/https://ghproxy.com/https://github.com/kentxxq/hugo.git
# 修改origin地址
git remote set-url origin https://github.com/kentxxq/hugo.git
# 验证效果
git remote -v
```

### 推送

```shell
# 所有
git push

git tag 1.0.0
# 指定tag
git push origin <tag_name>

# 所有tag,不推荐
git push --tags
```

### 清空记录

```shell
# 新分支
git checkout --orphan  new_branch
# 添加到暂存区
git add -A
# 提交
git commit -am "文章更新"
# 删除原有的master
git branch -D master
# 重命名分支
git branch -m master
# 强制推送
git push -f origin master
```
