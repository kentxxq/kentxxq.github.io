---
title: git-openssh的免密
tags:
  - openssh
  - git
  - ssh-agent
  - blog
date: 2023-06-21
lastmod: 2025-11-06
categories:
  - blog
description: "我的使用 [[笔记/point/git|git]] 操作代码. 而 git 的通信会用到 [[笔记/point/openssh|openssh]].openssh 为了保证安全. 提供了私钥和公钥. 其中私钥可以密码加密, 保证安全性. 所以我就加密了.导致了什么问题呢?每次我用到 git 的时候, 都提示我输入密码. 所以我今天就来配置 [[笔记/point/ssh-agent|ssh-agent]]."
---

## 简介

我的使用 [[笔记/point/git|git]] 操作代码. 而 git 的通信会用到 [[笔记/point/openssh|openssh]].

openssh 为了保证安全. 提供了私钥和公钥. 其中私钥可以密码加密, 保证安全性. 所以我就加密了.导致了什么问题呢?

每次我用到 git 的时候, 都提示我输入密码. 所以我今天就来配置 [[笔记/point/ssh-agent|ssh-agent]].

> 关键命令就是 ssh-add

## 操作流程

1. 启动 windows 的 `服务` =>启动 ssh 服务 ![[附件/自动启动ssh-agent服务.png]]
2. 添加秘钥

   ```powershell
   ssh-add C:\Users\你的用户名\.ssh\id_rsa
   # 输入密码后回车
   Enter passphrase for C:\Users\你的用户名\.ssh\id_rsa:
   Identity added: C:\Users\你的用户名\.ssh\id_rsa (kentxxq)

   # 验证效果
   ssh-add -l
   3072 SHA256:xxxxxxxxxxxxxxxxxxxxxxxoooooo kentxxq (RSA)
   ```

3. **进入终端**,编辑 `notepad $profile` 配置文件

   ```powershell
   # 加入下面这一行
   $env:GIT_SSH="C:\Windows\System32\OpenSSH\ssh.exe"
   ```

4. 终端有效果, 但 `vscode` 等等软件没有生效? 按照这个老哥的做法, 改全局变量吧 [Git: Support git with private key password · Issue #13680 · microsoft/vscode · GitHub](https://github.com/microsoft/vscode/issues/13680#issuecomment-1202087713) ![[附件/GIT_SSH全局变量.png]]
5. **重新打开终端**, 这里有一些 [[笔记/git教程|git教程]] 可以给你测试验证
