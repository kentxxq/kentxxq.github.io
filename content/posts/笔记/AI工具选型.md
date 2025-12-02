---
title: AI工具选型
tags:
  - blog
  - AI
date: 2025-10-30
lastmod: 2025-11-20
categories:
  - blog
description:
---

## 简介

AI 已经在编码的时候必不可少，记录一下选型/使用

## 工作生活兼顾

**chatgpt 日常，国内豆包国内资讯**

- 需求
	- 海外和国内独立。因为国内外咨询主要来源不一样。国内新闻可能更好，国外技术类知识更好
	- 支持个性化配置
	- 多平台
- 豆包
	- 有头条 + 抖音资料库
	- 缺少个性化配置
- 千问
	- 开源模型能力强
	- 没有自己的资料库。
- 元宝
	- 有公众号做资料库
	- 自己的模型能力感觉不好，用的 deepseek 模型
- chatgpt
	- 默认选择，没有什么坑
	- 没有自己的资料库，但是海外资源不太依赖资料库
- gemini
	- youtube，google 搜索作为资料库
	- 能力不稳定

## AI 编码

**使用 cursor**

- 选择 ide，不要 cli。
	- 因为我需要 tab ，哪怕是日常文件编辑。
	- 不希望频繁切换窗口
	- 更喜欢点击操作/交互
- cursor 贵一点，但如果不用 claude code 模型够用
- [antigravity](https://antigravity.google/docs/) google 出品
- windsurf
	- 人员被 google 收编，现有技术团队已经发生大变化
	- 便宜一些，编码能力应该和 cursor 接近（毕竟模型可以一致）
- 下面没有 claude code，价格更便宜一些
	- 阿里 qoder 不能自己选模型，输出会不稳定？
	- 字节 trae 可选模型。
		- 2025-11-19 发现模型更新很慢。cursor 秒当天更新 gemini 3
