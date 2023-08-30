---
title: obsidian插件与配置
tags:
  - blog
  - obsidian
date: 2023-06-19
lastmod: 2023-08-27
categories:
  - blog
description: "这篇文章主要记录我使用 [[笔记/point/obsidian|obsidian]] 的配置和插件.方便自己记录, 也可以让你了解我做了什么让 [[笔记/point/obsidian|obsidian]] 变得更好用."
---

## 简介

这篇文章主要记录我使用 [[笔记/point/obsidian|obsidian]] 的配置和插件.

方便自己记录, 也可以让你了解我做了什么让 [[笔记/point/obsidian|obsidian]] 变得更好用.

## 主要配置

### 编辑器

![[附件/ob-编辑器配置.png]]

### 文件与链接

![[附件/ob-文件与链接配置.png]]

## 插件

### 使用中的插件

| 插件名称                             | 插件作用                 | 总结说明                                       |
| ------------------------------------ | ------------------------ | ---------------------------------------------- |
| Advanced Tables                      | 快速写 markdown 的 table | 非常好用                                       |
| excalidraw                           | 画图的                   | 可以自动生成 svg，并且同步画图改动，兼容性很高 |
| Find orphaned files and broken links | 清理文件                 | 整理出无效链接和孤儿文件                       |
| tag warpper                          | 加强处理 tag             | 批量重命名                                     |
| Linter                               | 格式化笔记               | 选项很多，需要折腾                             |
| Webpage HTML Export                  | 导出 html                | 兼容性非常好                                   |
| auto-link-title                      | 自动填写网页标题         | 挺好的，可以统一                               |
| easy-typing                          | 输入时格式化             | 帮我在英文标点后加上空格                       |
| image-toolkit                        | 点击放大图片             | 蛮好的                                         |
| emoji-toolbar                        | 插入 emoji               | 蛮好的                                         |
| Templater                            | 模板                     | 方便创建日期和文件名模板                       |

### 放弃了的插件

| 插件名称       | 插件作用 | 总结说明                                                                            |
| -------------- | -------- | ----------------------------------------------------------------------------------- |
| Diagrams       | 画图     | 在 ob 没 excalidraw 好用，没导出 svg 这样的定制化功能                               |
| Digital Garden | 发布站点 | tag 效果不好、和 frontmatter 似乎冲突比较多、代码不是很活跃                         |
| Remotely Save  | 同步备份 | 全程使用 alist 的 webdav+ 阿里云盘。偶尔无法同步删除，无法删除 `.obsidian` 里的文件 |
| livesync 同步  | 同步     | 需要搭建服务器端、其实没有备份功能                                                  |

### 可能尝试的插件

| 插件名称        | 插件作用     | 总结说明                                |
| --------------- | ------------ | --------------------------------------- |
| sliding panes   | 横向卷动     | 打开多个标签页，然后配合触摸板横向浏览  |
| obisidian links | 链接类型转换 | wikilink, markdown-link, 删除 link 等等 |

- [[obsidian同步方案对比]] #todo/笔记
- Remote save 设置手动同步? 或者 obsidian 文件夹自己同步?!
- [GitHub - acheong08/rev-obsidian-sync-plugin](https://github.com/acheong08/rev-obsidian-sync-plugin)
