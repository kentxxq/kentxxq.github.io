---
title: obsidian的发布方案
tags:
  - obsidian
  - hugo
  - blog
date: 2023-06-21
lastmod: 2023-06-30
categories:
  - blog
description: "这里是我在确定使用 [[笔记/point/obsidian|obsidian]] 记录笔记以后. 对比选择我的博客发布方案.之前我的博客和笔记内容是割裂的. 一直使用 vscode 编写博客, 然后 [[笔记/point/hugo|hugo]] 发布. 而现在我想重新组合我的工作流."
---

## 简介

这里是我在确定使用 [[笔记/point/obsidian|obsidian]] 记录笔记以后. 对比选择我的博客发布方案.

之前我的博客和笔记内容是割裂的. 一直使用 vscode 编写博客, 然后 [[笔记/point/hugo|hugo]] 发布. 而现在我想重新组合我的工作流.

## 发布方案

### 现状

先说结果,我选的 [HEIGE-PCloud/DoIt: A clean, elegant and advanced blog theme for Hugo.](https://github.com/HEIGE-PCloud/DoIt).没有哪种方案是十全十美的, 于是我先确定了优先级.

- `seo`: 既然是发布系统. 那么发布出去最重要的就是 seo 优化了.
- `评论`: 交流, 反馈都会直接帮助到内容, 重要性排名第二.

### 方案对比

| 对比项                     | hugo-quartz                                             | hugo-doit                              | 官方 publish |
| -------------------------- | ------------------------------------------------------- | -------------------------------------- | ------------ |
| `#todo标签`                | 无法过滤解析 🚫                                         | 无法过滤解析 🚫                        | 支持 ✅      |
| 支持预览页面               | 支持 wikilink 和普通 link, 但效果一般 ⚠️                | 不支持 🚫                              | 支持 ✅      |
| 需要做的改动               | [obsidian 发布到 quartz](obsidian发布hugo-quartz.md) ℹ️ | 移动 static 文件夹并配置 staticDirc ℹ️ | 不需要 ✅    |
| markdown 正常 link 到 head | 只能定位到 page⚠️                                       | 通过 goldmark-wiki 支持 ⚠️             | 支持 ✅      |
| seo                        | 6 分                                                    | 10 分                                  | 10 分        |
| 评论                       | 🚫                                                      | ✅                                     | 🚫           |

在确定了使用 doit 后,其中最让我纠结的就是语法问题.

1. 禁用 wikilink 语法 - 相对于根目录. 需要在主题内修改 md 链接的渲染. 检测到 md 结尾就绕过原有逻辑,去除 md 结尾, 加上 /posts/ 前缀.
2. 禁用 wikilink 语法 - 相对于当前文件, 需要开启 uglyURLs, 同时将 md 改成 html
3. 采用 wikilink 语法, 在我编写笔记的时候好用. 但是发布需要渲染成 uglyURLs. 且要改源码编译 hugo 加入 goldmark-wikilink. 同时改动 wikilink 的渲染逻辑

分析:

2 比 1 要好, 不是绕过原有逻辑, 而是在原有逻辑后加入判断. 同时有兼容性好. 任意 markdown 编辑器都通用

3 比较麻烦, 同时如果

#todo/笔记
