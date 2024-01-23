---
title: uni-app快速上手
tags:
  - blog
  - 前端
date: 2024-01-20
lastmod: 2024-01-20
categories:
  - blog
description: 
---

## 简介

记录 uni-app 的快速上手

## 工具

vscode 插件

- `uni-create-view` 帮助创建页面
- `uni-helper的组件包` 帮助代码提示
- `uniapp小程序拓展` 帮助悬停查看文档

安装类型 `pnpm i -D @types/wechat-miniprogram @uni-helper/uni-app-types`

配置 `tsconfig.json`。确保使用了 ts 类型，配置了 `vueCompilerOptions` 的 `nativeTags` 下面 4 个内容

```json
{
  {
    "types": ["@dcloudio/types","@types/wechat-miniprogram","@uni-helper/uni-app-types"]
  },
  "vueCompilerOptions": {
    "nativeTags": ["block", "component", "template", "slot"]
  }
}
```
