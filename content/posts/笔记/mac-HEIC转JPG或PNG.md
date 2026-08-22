---
title: mac-HEIC转JPG或PNG
tags:
  - blog
  - macos
date: 2023-07-01
lastmod: 2023-07-01
categories:
  - blog
description: "用 iPhone 拍出来的照片，传到 [[macos|mac]] 上显示结尾是 HEIC 的图片文件。在 markdown 中不支持，同样在 [[hugo]] 的 web 页面里也不支持。所以找了一下方法，发现 automator 这个功能可以一劳永逸的实现。之前一直没有用过。所以记录一下"
---

## 简介

用 iPhone 拍出来的照片，传到 [[笔记/point/macos|macos]] 上显示结尾是 HEIC 的图片文件。在 markdown 中不支持，同样在 [[笔记/point/hugo|hugo]] 的 web 页面里也不支持。所以找了一下方法，发现 automator 这个功能可以一劳永逸的实现。之前一直没有用过。所以记录一下

## 操作手册

1. Command+Space(空格)，输入 automator,进入后点击新建文稿。![[附件/macos-自动操作.png]]
2. 选择快速操作
3. 把左边的步骤拖动到右边，调整后的页面如下 ![[附件/macos-HEIC转JPG.png]]
4. 左上角文件 ->存储 ->保存名字 HEIC 转 JPEG 即可
5. 在访达中使用即可 ![[附件/macos-图片转换操作.png]]
6. 快去看看你的桌面上出现了什么！
