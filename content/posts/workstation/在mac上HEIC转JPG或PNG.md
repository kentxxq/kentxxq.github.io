---
title:  在mac上HEIC转JPG或PNG
date:   2019-04-15 08:59:00+08:00
categories: ["笔记"]
tags: ["mac"]
keywords: ["mac","HEIC转JPG","HEIC转PNG","图片转换"]
description: "用iPhone拍出来的照片，传到mac上显示结尾是HEIC的图片文件。在markdown中不支持，同样在hugo的web页面里也不支持。所以找了一下方法，发现automator这个功能可以一劳永逸的实现。之前一直没有用过。所以记录一下"
---

> 用iPhone拍出来的照片，传到mac上显示结尾是HEIC的图片文件。在markdown中不支持，同样在hugo的web页面里也不支持。
>
> 所以找了一下方法，发现automator这个功能可以一劳永逸的实现。之前一直没有用过。所以记录一下。

## 关于automator

如果想要了解详细的文档和资料，看下面的链接就好了。

在iOS上有workflow(捷径)，那么automator就是macOS的workflow(自动操作)。

[苹果automator的官方介绍](https://support.apple.com/zh-cn/guide/automator/welcome/mac)

## 实际操作上手

演示一波**HEIC转JPG或PNG**

1. Command+Space(空格)，输入automator,进入后点击新建文稿。
![automater](/images/workstation/自动操作.png)
2. 选择快速操作
3. 把左边的步骤拖动到右边，调整后的页面如下
![HEIC转JPEG](/images/workstation/HEIC转JPEG.png)
4. 左上角文件->存储->保存名字HEIC转JPEG即可
5. 在访达中使用即可
![图片转换操作](/images/workstation/图片转换操作.png)
6. 快去看看你的桌面上出现了什么！

## 总结

还有很多的小功能组合。感觉比iOS上好用多了，支持的功能数量不在一个量级。毕竟一个是手机，一个是电脑吧。


