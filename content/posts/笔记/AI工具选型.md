---
title: AI工具选型
tags:
  - blog
  - AI
date: 2025-10-30
lastmod: 2026-04-28
categories:
  - blog
description:
---

## 简介

[[AI]] 已经在编码的时候必不可少，记录一下选型/使用。

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
	- 资料库是淘宝，支付宝
- 元宝
	- 有公众号做资料库
	- 自己的模型能力感觉不好，用的 deepseek 模型
- chatgpt
	- 默认选择，没有什么坑
	- 没有自己的资料库，但是海外资源不太依赖资料库
- gemini
	- youtube，google 搜索作为资料库

## AI 编码

### 模型

- Gemini **前端专家**，ui + 图生代码
	- 原生多模态
	- 超长上下文
	- 审美在线
- Claude Opus 均衡常用，**日常主力**
	- skills，rules 等工具调用的执行很不错
	- 前后端均可，规划/架构不错
	- 太复杂 bug 容易拧不清
- Codex **修 bug**
	- 严谨，单点问题处理很强
	- 数学家，算法也很厉害
	- 思考时间很长，很慢
- 随手工具
	- **脚本**都会需要重新 review 一次，差距不大
	- **补全**能力都其实差不多

### 工具 IDE

github copilot 先用到 6 月份，比较顺手。如果发现价格会很贵，尝试中转站使用 cc 或 codex

- 选择 ide，不要 cli。
	- 因为我需要 tab ，哪怕是日常文件编辑。
	- 不希望频繁切换窗口
	- 更喜欢点击操作/交互
- 切换成本很低，20 分钟足够
	- 安装插件
	- 复制配置文件过去
	- 全局 rule + 项目 rule
- 便宜方案/低复杂度任务
	- 云商 token 计划 [套餐概览--火山方舟-火山引擎](https://www.volcengine.com/docs/82379/1925114?lang=zh)
	- 模型商方案 deepseek/kimi/glm/minimax/mimo
	- 第三方方案 opencode 方案
- github copilot
	- workflow/prompt 支持指定模型，快捷使用模型快速执行
	- [不同套餐的模型列表](https://github.com/features/copilot/plans#compare)
	- [模型价格 - 倍率](https://docs.github.com/en/copilot/reference/ai-models/supported-models)
- gemini
	- [gemini cli 配额](https://developers.google.com/gemini-code-assist/resources/quotas?hl=zh-cn)
- codex [Pricing – Codex | OpenAI Developers](https://developers.openai.com/codex/pricing)
	- 听说效果非常棒
	- 除了 5 小时限额，还有周限额
	- 响应速度对比 cc 要慢
	- plus 20 美金。加入多个 team，咸鱼 team 偶尔有 10 元/月。开通 pro
- cursor
	- 价格贵
	- 模型多。但也因为不是第一方，所以第一时间可能没得用。比如 codex-5.2 的 api 不会随着模型立即发布
	- 用户量大
	- tab 好用
- [antigravity](https://antigravity.google/docs/)
	- google 出品
	- 家庭组可以共享，注册小号可能要手机号验证，信用卡年龄认证。[可以尝试用 youtube 注册谷歌账号 - LINUX DO](https://linux.do/t/topic/1963769/3)
	- 5 小时重置，但是有周限额
	- 模型 gemini + claude
	- 原 windsurf 成员，效果也是有保证的
- cc
	- cc 封号严重，只能走中转
- windsurf
	- 人员被 google 收编，现有技术团队已经发生大变化
	- 便宜一些，编码能力应该和 cursor 接近（毕竟模型可以一致）
- 其他情况
	- 阿里 qoder 不能自己选模型，输出会不稳定？
	- 字节 trae 可选模型，但没有 claude 模型。2025-11-19 没有 codex 模型，发现模型更新很慢，而 cursor 秒当天更新 gemini 3

### AI 辅助工具

- 终端工具？
	- cc 的终端工具 cmux，opencove，TermCanvas
	- token 统计工具，通常需要长时间运行...
		- [https://github.com/mm7894215/TokenTracker](https://github.com/mm7894215/TokenTracker) token 追踪
- 远程 vibe
	- vibe-tunnel
	- https://jules.google/docs/environment/
	- happy
	- https://github.com/xxnuo/VibeGo
	- claude code  - remote control 功能
	- antigravity
		- https://apps.apple.com/us/app/mobile-ide-for-antigravity-ai/id6759795486
		- https://open-vsx.org/extension/uladluch/antigravity-mobile-connector

### 中转站

比价

- [AI 模型价格对比 - CheapAI](https://www.getcheapai.com/zh-cn)
- 似乎知名
	- 七牛/官网价 [SUFY - Free CDN Solutions & Scalable Object Storage for Your Business](https://sufy.com/zh-CN/services/ai-inference/models)
	- 1 比 1 人民币/美金 [PackyCode - AI-Powered Code Assistant](https://codex.packycode.com/)
	- [AICodeMirror](https://www.aicodemirror.com/)，懒猫微服推荐

科普/工具

- [cc-switch](https://github.com/farion1231/cc-switch) 让你快速在中转站切换
- [AI 中转站黑话大全整理，带你一次性了解中转站逻辑，别用中转站，用的不明不白 - V2EX](https://www.v2ex.com/t/1196011)
