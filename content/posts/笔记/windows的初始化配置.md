---
title: windows的初始化配置
tags:
  - blog
  - windows
date: 2023-06-29
lastmod: 2023-09-15
categories:
  - blog
description: "[[笔记/point/windows|windows]] 现在是我主要使用的桌面平台. 因为我挑选并使用了大量的软件工具, 而且经常会跨多设备工作. 所以这里我记录下来, 也给大家做一个参考."
---

## 简介

[[笔记/point/windows|windows]] 现在是我主要使用的桌面平台. 因为我挑选并使用了大量的软件工具, 而且经常会跨多设备工作. 所以这里我记录下来, 也给大家做一个参考.

与 [[笔记/linux的初始化配置|linux的初始化配置]] 目的类似.

## 配置内容

| 对象 | 选择                       | 说明                                                                    | 参考                                                                                                                                                                                                                                                            |
| ---- | -------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 字体 | `Caskaydia Cove Nerd Font` | 首先 `Cascadia Code` 是一个等宽字体, 而 `Nerd Font` 为其加入了大量图标. | [GitHub - ryanoasis/nerd-fonts: Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts: Hack, Source Code Pro, more. Glyph collections: Font Awesome, Material Design Icons, Octicons, & more](https://github.com/ryanoasis/nerd-fonts) |

#todo/笔记 开启 windows 沙箱

## 软件安装

### 软件列表

- 看图 [GitHub - d2phap/ImageGlass: 🏞 A lightweight, versatile image viewer](https://github.com/d2phap/ImageGlass)
- 终端 [Tabby - a terminal for a more modern age](https://tabby.sh/)
- 编码 [Visual Studio Code - Code Editing. Redefined](https://code.visualstudio.com/)
- 打开超大文本 [EmEditor (Text Editor) – Best Text Editor, Code Editor, CSV Editor, Large File Viewer for Windows (Free versions available)](https://www.emeditor.com/)
- [[笔记/point/clash|clash]]
- [Apifox - API 文档、调试、Mock、测试一体化协作平台 - 接口文档工具，接口自动化测试工具，接口Mock工具，API文档工具，API Mock工具，API自动化测试工具](https://apifox.com/)
- [钉钉，让进步发生](https://www.dingtalk.com/)
- [微信，是一个生活方式](https://weixin.qq.com/)
- [企业微信](https://work.weixin.qq.com/)
- JB 全家桶 [JetBrains Toolbox App: Manage Your Tools with Ease](https://www.jetbrains.com/toolbox-app/)
- [QQ音乐-千万正版音乐海量无损曲库新歌热歌天天畅听的高品质音乐平台！](https://y.qq.com/)
- [网易云音乐](https://music.163.com/?gclid=CjwKCAjwxOymBhAFEiwAnodBLLwob9NFiF-JZDAbX8uwl9kLGGhZD1engdzR6GXZkzvYAcfkt8iRChoC-1oQAvD_BwE)
- [OneDrive](https://www.microsoft.com/en-us/microsoft-365/onedrive/online-cloud-storage)
- [阿里云盘](https://www.aliyundrive.com/drive)
- [WPS-需要关掉网盘,图片关联](https://www.wps.cn/)
- 抓包 [Wireshark · Go Deep](https://www.wireshark.org/)
- 远程 [向日葵远程控制软件\_远程控制电脑手机\_远程桌面连接\_远程办公|游戏|运维-贝锐向日葵官网](https://sunlogin.oray.com/)
- 自动切换主题颜色 [GitHub - AutoDarkMode/Windows-Auto-Night-Mode: Automatically switches between the dark and light theme of Windows 10 and Windows 11](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode)
- [GitHub - zhongyang219/TrafficMonitor: 这是一个用于显示当前网速、CPU及内存利用率的桌面悬浮窗软件，并支持任务栏显示，支持更换皮肤。](https://github.com/zhongyang219/TrafficMonitor)
- 本地执行 github-actions [GitHub - nektos/act: Run your GitHub Actions locally 🚀](https://github.com/nektos/act)
- 查看图片的额外信息 [ExifTool by Phil Harvey](https://exiftool.org/)
- [PowerShell/PowerShell](https://github.com/PowerShell/PowerShell/releases)
- [Docker](https://www.docker.com/products/docker-desktop/)
- 播放器, 配合配置文件 [Global Potplayer](https://potplayer.daum.net/)
  选项=》基本=》保存到 ini 文件=》备份/恢复配置
- 画图 [draw.io](https://www.drawio.com/)
- [迅雷-构建全球最大的去中心化存储与传输网络](https://www.xunlei.com/)
- 微软官方的进程查看工具 [Process Explorer - Sysinternals | Microsoft Learn](https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer)
- 截图工具, 配合配置文件 [Snipaste](https://www.snipaste.com/)
- [Listen 1 音乐播放器](https://listen1.github.io/listen1/?gclid=CjwKCAjwxOymBhAFEiwAnodBLAdmIaAAK6kr4MTMA8lYBt2q40_lBfJyAW1AQYoL_TXqBHvkv8ay1hoCtLMQAvD_BwE)
- 文件夹锁 [GitHub - Albert-W/Folder-locker: It a tiny tool to lock your folder without compression.](https://github.com/Albert-W/Folder-locker)
- 压缩/解压 [GitHub - M2Team/NanaZip: The 7-Zip derivative intended for the modern Windows experience](https://github.com/M2Team/NanaZip)
- 滴答清单

### 特殊软件

#### Utools

[uTools官网 - 新一代效率工具平台](https://www.u.tools/) 的内置插件

- 谷歌翻译, 配置全局关键字 `ctrl+q`
- OCR 文字识别
- Hosts 切换
- Ctools
- 随机密码
- 文件、文件夹定位
- Linux 命令文档
- Json 编辑器
- Sql 格式化
- 本地搜索
配置:
- 中键去掉无用内容, 保留 - 置顶窗口
- Listen 1 快速启动
- Wsl 2 distronmananger 快速启动

## 相关内容

- [[笔记/windows系统激活|windows系统激活]]
