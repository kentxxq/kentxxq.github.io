---
title: 安装MinGW-w64
tags:
  - blog
  - MinGW-w64
date: 2023-06-26
lastmod: 2023-07-11
categories:
  - blog
description: "快速安装 [[笔记/point/MinGW-w64|MinGW-w64]] 的方法."
---

## 简介

快速安装 [[笔记/point/MinGW-w64|MinGW-w64]] 的方法.

## 操作手册

1. 访问 [WinLibs - GCC+MinGW-w64 compiler for Windows](https://winlibs.com/#download-release)
2. 下载 `MSVCRT runtime` ![[附件/MinGW-w64-MSVCRT-runtime下载选项.png]]
3. 解压后添加到 `系统环境变量` 中 ![[附件/MinGW-w64系统环境变量.png]]
4. 测试验证

   ```powershell
   > gcc --version
   gcc.exe (MinGW-W64 x86_64-msvcrt-posix-seh, built by Brecht Sanders) 13.1.0
   Copyright (C) 2023 Free Software Foundation, Inc.
   This is free software; see the source for copying conditions.  There is NO
   warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

   > make --version
   GNU Make 3.81
   Copyright (C) 2006  Free Software Foundation, Inc.
   This is free software; see the source for copying conditions.
   There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A
   PARTICULAR PURPOSE.
   This program built for i386-pc-mingw32
   ```
