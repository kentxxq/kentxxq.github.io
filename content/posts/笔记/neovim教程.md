---
title: neovim教程
tags:
  - neovim
  - blog
date: 2023-08-11
lastmod: 2026-08-18
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
# 最好默认有代理了,因为需要取境外拉取内容
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
# 最好默认有代理了,因为需要取境外拉取内容
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

## 问题处理

### 报错 lazy 无法找到

报错 `module 'lazy' not found`.

因为需要拉取外网内容, 所以需要代理. 配置好代理后删除 lazy 目录重新进入即可.

```shell
rm -rf ~/.local/share/nvim/lazy

删除 LOCALDATA/nvim-data/lazy
```

## 参考

#todo/笔记

- 对比 [GitHub - folke/lazy.nvim: 💤 A modern plugin manager for Neovim](https://github.com/folke/lazy.nvim) 和 packer. Vim

可能用得上的配置

```vim
" 以双引号开头的是注释
" 不与 Vi 兼容（采用 Vim 自己的操作命令）
set nocompatible
" 打开语法高亮
syntax on
" 底部显示当前模式
set showmode
" 命令模式下显示键入的指令
set showcmd
" 支持鼠标 
set mouse=a
" 设置字符编码
set encoding=utf-8  
" 启动256色
set t_Co=256
" 开启文件检测，使用对应规则
filetype indent on


" 下一行与上一行保持缩进
set autoindent
" tab的空格数
set tabstop=4
" 加减缩进
" <<减缩进，>>加缩进，==去除所有缩进
set shiftwidth=4
" tab转空格
set expandtab

" 显示行号
set number
" 显示当前行号，其他是对应行号
" set relativenumber
" 行宽
set textwidth=80
" 自动折行
set wrap
" 指定符号比如空格什么的才折行
set linebreak
" 显示状态栏
set laststatus=2
" 括号自动高亮匹配
set showmatch
" 高亮显示搜索的匹配结果
set hlsearch
" 每输入一个字就跳到匹配位置
set incsearch
" 搜索忽略大小写
set ignorecase
" 智能匹配，开启上面的话小写可以匹配大写，大写不匹配小写
set smartcase

" 检查英语拼写
" set spell spelllang=en_us
" 不备份，默认会有个~结尾备份文件
set nobackup
" 不创建系统崩溃时候的恢复文件
set noswapfile
" 即使退出也会有undo~的可撤销文件，让你可以撤销上次的操作
set undofile

" 打开多个文件的时候自动切换目录
set autochdir
" 报错不发出声音
" set noerrorbells
" 报错闪烁
" set visualbell

" 显示行位空格
" set listchars=tab:»■,trail:■
" set list

" 第一次tab补全，第二次选择
" set wildmenu
" set wildmode=longest:list,full

" 自动重新加载
set autoread
" 正则魔术
" set magic
" 修改终端标题
" set title
```
