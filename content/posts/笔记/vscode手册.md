---
title: vscode手册
tags:
  - blog
  - vscode
date: 2023-08-30
lastmod: 2025-12-02
categories:
  - blog
description: 
---

## 简介

这里记录 [[笔记/point/vscode|vscode]] 的配置和技巧

## 技巧

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

## 插件

- 通用
	- 文件处理
		- `.env` 文件高亮 [DotENV](https://marketplace.visualstudio.com/items?itemName=mikestead.dotenv) 
		- toml 文件 https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml
		- shell 格式化 [shell-format](https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format)
		- yaml  https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml
		- xml https://marketplace.visualstudio.com/items?itemName=DotJoshJohnson.xml
		- vscode-pdf https://marketplace.visualstudio.com/items?itemName=tomoki1207.pdf
		- nginx https://marketplace.visualstudio.com/items?itemName=ahmadalli.vscode-nginx-conf
		- gitignore  https://marketplace.visualstudio.com/items?itemName=codezombiech.gitignore
		- docker
			- https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker
			- https://marketplace.visualstudio.com/items?itemName=docker.docker
	- 文件夹对比 [compare folders](https://marketplace.visualstudio.com/items?itemName=moshfeu.compare-folders)
	- 文件大小 https://marketplace.visualstudio.com/items?itemName=mkxml.vscode-filesize
	- todo https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree
	- task https://marketplace.visualstudio.com/items?itemName=task.vscode-task
	- slidev 用 md 做 ppt https://marketplace.visualstudio.com/items?itemName=antfu.slidev
	- k8s https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools
	- github-actions https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-github-actions
	- remote 系列
		- remote-ssh https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
		- remote-repo https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-repositories
	- 代码截图 https://marketplace.visualstudio.com/items?itemName=jeff-hykin.polacode-2019
	- 文件路径 https://marketplace.visualstudio.com/items?itemName=ionutvmi.path-autocomplete
	- 图片展示 https://marketplace.visualstudio.com/items?itemName=kisstkondoros.vscode-gutter-preview
	- 项目切换 https://marketplace.visualstudio.com/items?itemName=alefragnani.project-manager
	- 查看二进制 https://marketplace.visualstudio.com/items?itemName=ms-vscode.hexeditor
- 前端
	- live-server  https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer
	- tailwindcss 工具 https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss
	- `i18n插件` [I18n-ally](https://marketplace.visualstudio.com/items?itemName=Lokalise.i18n-ally) 
	- 让 TS 识别 `*.vue` 文件 [Vue (Official) ](https://marketplace.visualstudio.com/items?itemName=Vue.volar)
	- css 颜色展示 [color highlight](https://marketplace.visualstudio.com/items?itemName=naumovs.color-highlight)
	- flex 布局展示 https://marketplace.visualstudio.com/items?itemName=dzhavat.css-flexbox-cheatsheet
	- iconify 图标 https://marketplace.visualstudio.com/items?itemName=antfu.iconify
	- 几乎所有 UI 库的代码提示 [common-intellisense](https://github.com/common-intellisense/common-intellisense)
	- 格式化
		- 文件格式化 [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
		- js 代码质量检查 [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) 
		- css 代码质量检查 [Stylelint](https://marketplace.visualstudio.com/items?itemName=stylelint.vscode-stylelint) 
		- oxc 替代 prettier 和 eslint 插件，暂还不支持 css，但通常使用 tailwind 即可 https://marketplace.visualstudio.com/items?itemName=oxc.oxc-vscode
- 后端
	- EditorConfig 配置文件 https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig
	- 各个语言 go，python，dotnet
- 其他
	- 有趣的注释 https://marketplace.visualstudio.com/items?itemName=ZYLAB.fun-comment

## 配置文件

```json
{
    "[typescript]": {
        "editor.codeActionsOnSave": {
            "source.organizeImports": "always"
        }
    },
    "editor.defaultFormatter": "oxc.oxc-vscode",
    "editor.formatOnPaste": true,
    "editor.formatOnSave": true,
    "explorer.confirmDelete": false,
    "files.associations": {
        "*.json": "jsonc"
    },
    "files.autoSave": "afterDelay",
    "git.autofetch": true,
    "git.confirmSync": false,
    "javascript.updateImportsOnFileMove.enabled": "always",
    "liveServer.settings.donotShowInfoMsg": true,
    "oxc.fmt.experimental": true,
    "python.venvPath": ".venv",
    "typescript.updateImportsOnFileMove.enabled": "always"
}

```
