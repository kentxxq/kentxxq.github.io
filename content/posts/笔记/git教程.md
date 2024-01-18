---
title: git教程
tags:
  - git
  - blog
date: 2023-06-21
lastmod: 2024-01-17
categories:
  - blog
description: "这里用来记录一些我可能用到的 [[笔记/point/git|git]] 命令. 每次去网上搜集都很麻烦, 还需要验证. 而这里的命令都经过了我的验证.."
---

## 简介

这里用来记录一些我可能用到的 [[笔记/point/git|git]] 命令. 每次去网上搜集都很麻烦, 还需要验证. 而这里的命令都经过了我的验证..

## 配置

### config 配置

`~/.ssh/config` 文件可以处理多种问题。

- 多个密钥，不同密钥服务于不同仓库/用户
- github 的连接问题 `ssh connect to host github.com port 22 connection timed out` ，[github官方也有对此说明](https://docs.github.com/en/authentication/troubleshooting-ssh/using-ssh-over-the-https-port)

下面是一个示例

```
Host qs_codeup
HostName codeup.aliyun.com
IdentityFile ~/.ssh/2_rsa
PreferredAuthentications publickey
User kentxxq

Host github.com
HostName ssh.github.com
Port 443
IdentityFile ~/.ssh/id_rsa
PreferredAuthentications publickey
User kentxxq
```

- 两个配置文件，对应你的 2 个账号
- Port 参数可以让你从默认的 22 端口，改成连接 443 端口
- 使用了不同的密钥

### 相关内容

- [[笔记/git-openssh的免密|在windows上使用ssh-agent，让git免密ssh拉取]]

## 操作

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

# 克隆大文件失败
git config --global core.compression 0
git config --global http.postBuffer 500M
git config --global http.maxRequestBuffer 100M
```

### 仓库 remote

```shell
# 添加remote
git remote add gitea https://ken.kentxxq.com/admin1/learn-actions.git
# 修改origin地址
git remote set-url origin https://github.com/kentxxq/hugo.git
# 删除
git remote remove origin2

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
git commit -am "init"
# 删除原有的main
git branch -D main
# 重命名分支
git branch -m main
# 强制推送
git push -f origin main
```
