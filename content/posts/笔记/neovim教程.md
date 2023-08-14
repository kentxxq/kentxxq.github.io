---
title: neovim教程
tags:
  - neovim
  - blog
date: 2023-08-11
lastmod: 2023-08-14
categories:
  - blog
description: "我在 [[笔记/point/linux|linux]] 下编辑文件都会使用 [[笔记/neovim教程|neovim教程]] .记录一些配置和功能."
---

## 简介

我在 [[笔记/point/linux|linux]] 下编辑文件都会使用 [[笔记/neovim教程|neovim教程]] .记录一些配置和功能.

## 内容

### 安装

#### Windows

1. 安装 `clang`,参考微软文档 [Clang/LLVM support](https://learn.microsoft.com/en-us/cpp/build/clang-support-msbuild?view=msvc-170#install-1) 进入 `visual studio install` 安装好 `clang`,然后进入系统开始菜单的 `x64 Native Tools Command Prompt` 命令行终端, `clang -v` 查看**安装的位置. 加入到系统变量中**
2. 安装 `winget install Neovim.Neovim`
3. 执行下面的 [[笔记/point/shell|shell]]

```shell
# 去除现有内容
rm $env:LOCALAPPDATA/nvim
rm $env:LOCALAPPDATA/nvim-data

# 克隆配置
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA/nvim
# 删除git,后面可以加上自己的git
rm $env:LOCALAPPDATA/nvim/.git
# 启动!!
# 最好默认有翻墙了,因为需要取境外拉取内容
nvim
```

#### Linux

1. 下载 [nvim-linux64.tar.gz](https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz),并加入到环境变量 `Path` 中. `echo "PATH=\$PATH:/root/nvim-linux64/bin" >> ~/.bashrc`
2. 安装依赖 `apt install libfuse2 build-essential -y`
3. 执行下面 [[笔记/point/shell|shell]]

```shell
# 去除现有内容
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}

# 克隆配置
# git clone https://ghproxy.com/https://github.com/LazyVim/starter ~/.config/nvim
git clone https://github.com/LazyVim/starter ~/.config/nvim
# 删除git,后面可以加上自己的git
rm -rf ~/.config/nvim/.git
# 启动!!
# 最好默认有翻墙了,因为需要取境外拉取内容
nvim
```

### 配置文件

- [[笔记/point/windows|windows]] 配置文件路径 `~/AppData/Local/nvim`
- [[笔记/point/linux|linux]] 配置文件路径 `~/.config/nvim`

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
    vim.opt.number=true
# 制表符转换为空格
set expandtab
# tab长度4个空格
set tabstop=4
# 进行缩进的时候,缩进长度
set shiftwidth=4
```

#todo/笔记

- 参考 [【全程讲解】Neovim从零配置成属于你的个人编辑器\_哔哩哔哩\_bilibili](https://www.bilibili.com/video/BV1Td4y1578E/?vd_source=3f8a7a9cfa796e140d94e90eb3af4c90)
- 对比 [GitHub - folke/lazy.nvim: 💤 A modern plugin manager for Neovim](https://github.com/folke/lazy.nvim) 和 packer. Vim

## 问题处理

### 报错 lazy 无法找到

报错 `module 'lazy' not found`.

因为需要拉取外网内容, 所以需要 [[笔记/point/clash|clash]] 等代理配置. 配置好代理后删除 lazy 目录重新进入即可.

```shell
rm -rf ~/.local/share/nvim/lazy

删除 LOCALDATA/nvim-data/lazy
```
