---
title: git教程
tags:
  - git
  - blog
date: 2023-06-21
lastmod: 2025-04-02
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

### 指定 key

```shell
git clone git@codeup.aliyun.com:oiasjdoajsdo/仓库名.git --config core.sshCommand="ssh -i ~/.ssh/你的私有key"
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


# 重置
git reset --hard HEAD
```

### 清理敏感信息

1. 找到包含敏感信息的 commit `git log -S "敏感信息" --oneline`
2. 写一个文本文件 `replace.txt`, 写上需要替换的敏感信息

    ```txt
    敏感信息1==>REPLACE_ME
    敏感信息2==>REPLACE_ME
    ```

3. 开始替换 `git filter-repo --replace-text /path/to/replace.txt --force --partial`
4. 因为默认会删掉 remote, 所以重新添加 remote `git remote add origin git@your.git`
5. 强推 `git push origin main --force`


- 参考文档
    - [Removing sensitive data from a repository - GitHub Docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
    - [Git Clean, Git Remove file from commit - Cheatsheet - GitGuardian Blog](https://blog.gitguardian.com/rewriting-git-history-cheatsheet/)

## git 工作流

常见模式

- github-flow：一个主分支。hotfix 和 feature 合并过来就 ok。主分支发布。问题是我合并特性到了 master，发布到开发环境测试。这时候生产有 bug，我要修复。我不能简单从 master 拉出分支来修复。
- git-flow：dev 和 master 是主分支。存在一个分支发布多个环境的情况，或者说需要通过 tag 方式来发布。而我通常用不同分支发布到不同环境。因此不用这种。

我使用的，其实是在 github-flow 上加了环境分支：

- dev 是主分支
- 4 个环境的长期分支，每个环境对应流水线发布。`dev=>test=>pre=>prod`
- feature：不一定立即合并，因为不一定上线。上线完成以后再删除。只会合并到 dev
- 小步快跑，避免代码在某环境节点停留时间长的情况。中间存在功能删减的情况，也要遵循从 dev 开始的流程。
- hotfix 可以从 prod 拉取。然后快速修复回到 prod。然后合并到 dev 后删除。

另外一种方式:

- 在特性分支上开发新功能，同步机器之间的代码
- 合并到 main 自动触发流水线，验证测试环境
- 手动 tag，发版线上

github 工作流使用

- [Site Unreachable](https://www.youtube.com/watch?v=uj8hjLyEBmU)
- `git rebase main` 可以让你的改动是基于最新的代码, 如果操作这一步有冲突, 就解决冲突
- `git push -f origin my-feature` 因为我们 rebase 了, 所以必须要用 -f 强制更新
- feature 合并到 main, 使用 pull request 去合并请求
- `main` 采用 `squash and merge`, 这样你的分支很乱, 但是会被整合到一起
- [十分钟学会常用git撤销操作，全面掌握git的时光机 - YouTube](https://www.youtube.com/watch?v=ol7CMoJuAvI)  #todo/笔记
- [1. 引言 | 自己动手写 Git](https://wyag-zh.hanyujie.xyz/docs/1.-%E5%BC%95%E8%A8%80.html)
