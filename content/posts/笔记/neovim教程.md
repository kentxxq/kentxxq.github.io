---
title: neovim教程
tags:
  - neovim
  - blog
date: 2023-08-11
lastmod: 2023-08-11
categories:
  - blog
description: "我在 [[笔记/point/linux|linux]] 下编辑文件都会使用 [[笔记/neovim教程|neovim教程]] .记录一些配置和功能."
---

## 简介

我在 [[笔记/point/linux|linux]] 下编辑文件都会使用 [[笔记/neovim教程|neovim教程]] .记录一些配置和功能.

## 内容

### 基础配置

```shell
# 安装和进入创建配置文件
apt install neovim -y
echo "alias vim='nvim'" >> ~/.bashrc
echo "alias vimrc='nvim ~/.config/nvim/init.vim'" >> ~/.bashrc
source ~/.bashrc
mkdir -p ~/.config/nvim
cd ~/.config/nvim
```

配置文件 `vim ~/.config/nvim/init.vim`

```shell
# 显示行数
set number
# 制表符转换为空格
set expandtab
set tabstop=4
set shiftwidth=4
```
