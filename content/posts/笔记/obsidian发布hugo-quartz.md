---
title: obsidian发布hugo-quartz
tags:
  - blog
  - hugo
  - obsidian
  - githubPages
date: 2023-06-20
lastmod: 2023-07-01
categories:
  - blog
description: "这里是用 [[笔记/point/obsidian|obsidian]] 发布到 [[point/hugo|hugo]] 的 quartz 主题详细操作步骤."
---

## 简介

这里是用 [[笔记/point/obsidian|obsidian]] 发布到 [[笔记/point/hugo|hugo]] 的 quartz 主题详细操作步骤.

`quartz` 主题优点如下:

- 支持双链语法
- 有双链图

## 操作步骤

### fork 代码库

1. 访问 hugo 模板仓库 [jackyzha0/quartz: 🌱 host your own second brain and digital garden for free (github.com)](https://github.com/jackyzha0/quartz)
2. fork 仓库 ![[附件/fork-quartz仓库.png]]
3. [[笔记/point/git|git]] 克隆到本地 `git clone https://github.com/YOUR-USERNAME/quartz`

### 初始化动作

- 移除 `content` 内的所有内容
- 编辑 `data/config.yaml` 目录下

  ```yml
  name: kentxxq
  enableRecentNotes: true
  GitHubLink: https://github.com/kentxxq/quartz
  description: "kentxxq's digital garden"
  page_title: "🪴 kentxxq's digital garden"
  links:
    - link_name: Blog
      link: https://www.kentxxq.com
    - link_name: GitHub
      link: https://github.com/kentxxq
  ```

- 编辑 `config.toml`

  ```toml
  baseURL = "https://blog.kentxxq.com/"
  ignoreFiles = [
      "/content/templates/*",
      "/content/private/*",
      "/content/附件/*.md",
  ]
  ```

- 注释掉 `.github/workflows/docker-publish.yaml` 文件
- `.gitignore` 过滤 private 文件夹

  ```
  content/private
  ```

- 修改 `layouts/partials/date-fmt.html` 里的日志格式

  ```html
  {{if .Date}} {{.Date.Format "2006-01-02"}} {{else if .Lastmod}} {{.Lastmod.Format "2006-01-02"}}
  {{else}} Unknown {{end}}
  ```

- 修改 `.github/workflows/deploy.yaml` 文件

  ```yml
  name: Deploy to GitHub Pages
  on:
    push:
      branches:
        - hugo
  jobs:
    deploy:
      runs-on: ubuntu-20.04
      steps:
        - uses: actions/checkout@v2
          with:
            fetch-depth: 0 # Fetch all history for .GitInfo and .Lastmod
        - name: Build Link Index
          uses: jackyzha0/hugo-obsidian@v2.20
          with:
            index: true
            input: content
            output: assets/indices
            root: .
        - name: Setup Hugo
          uses: peaceiris/actions-hugo@v2
          with:
            hugo-version: "0.96.0"
            extended: true
        - name: Build
          run: hugo --minify
        - name: Deploy
          uses: peaceiris/actions-gh-pages@v3
          with:
            github_token: ${{ secrets.GITHUB_TOKEN }}
            publish_dir: ./public
            publish_branch: master # deploying branch
            cname: blog.kentxxq.com # 先用blog来做测试
  ```

### 配置 githubPage

> 到你的 quartz 仓库调整配置
>
> 进入 `Settings > Action > General > Workflow Permissions`  并选中  `Read and Write Permissions` ![[附件/配置secrets.GITHUB_TOKEN的权限.png]]

### 使用说明

- `vault` 应该创建在 content 下面
- `_index.md` 是 quartz 的首页
- 设置 - 编辑器 - 显示 - 显示 frontmatter, 方便我们迅速查看调整 tag, 标题之类的内容
- 做一个模板,方便你以后用

  ```yml
  ---
  title: "{{title}}"
  tags:
    - blog
  ---
  ```

### 推送代码后

1. 配置自定义域名解析,例如 `blog.kentxxq.com` 使用 cname 解析到 `kentxxq.github.io`
2. 进入 `Settings > Pages > Custom domain > blog.kentxxq.com`
3. 开启 https 证书 `Enforce HTTPS`
