---
title: vscode技巧
tags:
  - blog
  - vscode
date: 2023-08-30
lastmod: 2024-05-23
categories:
  - blog
description: 
---

## 简介

这里记录 [[笔记/point/vscode|vscode]] 的配置和技巧.

## 内容

### 格式化

因为安装了 [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) 保存时自动格式化代码.

不格式化保存: `F1=>format=>不格式化保存`

### 代码片段 snippets

在 `.vscode` 文件夹创建文件 `vue3.code-snippets`

```json
{
    "Vue模板": {
        "scope": "vue",
        "prefix": "vvv",
        "body": [
            "<template>",
            "\t<div>",
            "\t\tdata",
            "\t</div>",
            "</template>\n",
            "<script setup lang='ts'>",
            "defineOptions({",
            "\tname: '$1'",
            "})",
            "</script>\n",
            "<style scoped>\n",
            "</style>"
        ],
        "description": "Vue模板"
    }
}
```

- 当你输入 `vvv`, 就会自动出现模板
- 默认光标会出现在 `$1` 的位置, 你可以继续添加 `$2`
- 填写完 `$1` 后使用 `tab` 键, 会跳转到 `$2`
