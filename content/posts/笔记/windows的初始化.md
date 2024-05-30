---
title: windows的初始化
tags:
  - blog
  - windows
date: 2023-06-29
lastmod: 2024-05-24
categories:
  - blog
description: "[[笔记/point/windows|windows]] 现在是我主要使用的桌面平台. 因为我挑选并使用了大量的软件工具, 而且经常会跨多设备工作. 所以这里我记录下来, 也给大家做一个参考."
---

## 简介

[[笔记/point/windows|windows]] 现在是我主要使用的桌面平台. 因为我挑选并使用了大量的软件工具, 而且经常会跨多设备工作. 所以这里我记录下来, 也给大家做一个参考.

与 [[笔记/linux的初始化|linux的初始化]] 目的类似.

## 分区配置

1 块盘就 1 个分区. 2 块盘就是 2 个独立分区. 但是间隔放大. 第二个分区为 K 分区, 这样可以中间加盘使用 (家里和公司多个电脑, 方便使用相同的盘符名称)

- 软件安装: 默认 `C:\Program Files 和 C:\Program Files (x86)` 即可.
- 重装: 不格盘重装. 文件完全不会被动.
- 个人资料: 创建一个 `vhdx` 来保存.
- 开发: devDrive`vhdx` 功能用起来. 配置安全中心的异步扫描, 安全 + 性能更好.
- 游戏: 独立目录, 然后用 `subst` 挂到到独立的分区.
- 虚拟机使用 `subst` 即可.

为什么会有第二块硬盘? 肯定是因为需要更大的空间. 既然空间大, 那就都放这里. 系统盘只放软件和长久使用后产生的垃圾. 减少重装的可能性.

那么游戏和虚拟机的 `subst` 直接放到这里. 同时 `vhdx` 也都放这里. 甚至可以做第一块盘内 `vhdx` 或 `subst` 的备份盘.

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
- 压缩/解压 [NanaZip](https://github.com/M2Team/NanaZip) . 如果 github 报毒. 可以去 microsoft store 下载
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

## winget 记录

```powershell
winget list
名称                            ID                                                                版本                    可用           源
-----------------------------------------------------------------------------------------------------------------------------------------------
Poe-CHATGPT                     07dcc971b42bcacc813c32e0d2d97d63                                  1.0
XTerminal 1.3.59                0e1444f2-e736-59a6-8826-a4f04175d221                              1.3.59
Bitwarden                       Bitwarden.Bitwarden                                               2023.10.0                              winget
BlazorAll.Native                1A7F8FDD-86D4-4635-BCC5-277046190E74_9zz4h110yvjzm                1.0.0.1
阿里云盘                        Alibaba.aDrive                                                    4.9.14                                 winget
NanaZip                         M2Team.NanaZip                                                    2.0.450.0                              winget
OneCommander                    44576milosp.OneCommander_p0rg76fmnrgsm                            3.54.1.0
Files                           49306atecsolution.FilesUWP_et10x9a9vyk8t                          3.0.1.0
Tabby 1.0.201                   Eugeny.Tabby                                                      1.0.201                                winget
Visual Studio Community 2022    Microsoft.VisualStudio.2022.Community                             17.7.5                  17.7.6         winget
kentxxq.Templates.Blazor.Native 882634F4-0C13-45FB-8AE9-87BDDBAFAF14_9zz4h110yvjzm                1.0.0.1
英特尔® 显卡控制中心            AppUp.IntelGraphicsExperience_8j3eq9eme6ctt                       1.100.5185.0
Microsoft Clipchamp             Clipchamp.Clipchamp_yxz26nhyzhsrt                                 2.8.1.0
大白菜超级U盘装机工具           DaBaiCai                                                          6.0.2212.3
Docker Desktop                  Docker.DockerDesktop                                              4.19.0                  4.25.0         winget
Everything 1.4.1.1022 (x64)     voidtools.Everything                                              1.4.1.1022              1.4.1.1024     winget
FileZilla 3.63.2.1              FileZilla Client                                                  3.63.2.1
Git                             Git.Git                                                           2.42.0.2                               winget
Google Chrome                   Google.Chrome                                                     119.0.6045.106          119.0.6045.124 winget
Xshell 7                        InstallShield_{2C5F58B0-1BF6-4BD3-A665-C1B5206BDC17}              7.0.0122
Xftp 7                          InstallShield_{359A9566-381F-4D9B-8ABE-2D922940149F}              7.0.0119
Fleet                           JetBrains Toolbox (Fleet) 19c6d2aa-cffe-4484-bab1-bfbdc7ae7aaa    1.26.104 Public Preview
GoLand                          JetBrains Toolbox (Goland) bac7d59c-20cf-4069-a5c0-c7c19bb751c5   2023.2.4
IntelliJ IDEA Ultimate          JetBrains Toolbox (IDEA-U) d7b52051-8ca5-4296-a413-67e04668273c   2023.2.4
Rider                           JetBrains Toolbox (Rider) b97d17ed-def7-42ee-b3a6-5619ca008aa2    2023.2.3
DataGrip                        JetBrains Toolbox (datagrip) 94917958-ac57-4eb6-ae60-45970f74ab7b 2023.2.3
dotPeek Portable                JetBrains Toolbox (dotPeek) c20ff58e-ecb7-4c5d-ae51-edb7eb5ed034  2023.2.3
WPS Office (12.1.0.15712)       Kingsoft Office                                                   12.1.0.15712
GnuWin32: Make-3.81             GnuWin32.Make                                                     3.81                                   winget
Microsoft Edge                  Microsoft.Edge                                                    119.0.2151.44                          winget
Microsoft Edge Dev              Microsoft.Edge.Dev                                                120.0.2186.2                           winget
Microsoft Edge Update           Microsoft Edge Update                                             1.3.181.5
Microsoft Edge WebView2 Runtime Microsoft.EdgeWebView2Runtime                                     119.0.2151.44                          winget
Cortana                         Microsoft.549981C3F5F10_8wekyb3d8bbwe                             4.2308.1005.0
AV1 Video Extension             Microsoft.AV1VideoExtension_8wekyb3d8bbwe                         1.1.61781.0
MSN 天气                        Microsoft.BingWeather_8wekyb3d8bbwe                               4.53.52331.0
应用安装程序                    Microsoft.DesktopAppInstaller_8wekyb3d8bbwe                       1.21.2771.0
Xbox                            Microsoft.GamingApp_8wekyb3d8bbwe                                 2309.1001.3.0
获取帮助                        Microsoft.GetHelp_8wekyb3d8bbwe                                   10.2308.12552.0
Microsoft 使用技巧              Microsoft.Getstarted_8wekyb3d8bbwe                                1.3.42522.0
HEIF Image Extensions           Microsoft.HEIFImageExtension_8wekyb3d8bbwe                        1.0.62561.0
来自设备制造商的 HEVC 视频扩展  Microsoft.HEVCVideoExtension_8wekyb3d8bbwe                        2.0.61931.0
中文(简体)本地体验包            Microsoft.LanguageExperiencePackzh-CN_8wekyb3d8bbwe               22621.39.181.0
Microsoft Edge Dev              Microsoft.MicrosoftEdge.Dev_8wekyb3d8bbwe                         120.0.2186.2
Microsoft Edge                  Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe                      119.0.2151.44
Microsoft 365 (Office)          Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe                        18.2306.1061.0
Solitaire & Casual Games        Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe              4.18.11019.0
Microsoft 便笺                  Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe                      4.0.4602.0
OneDrive                        Microsoft.OneDriveSync_8wekyb3d8bbwe                              23209.1008.2.0
画图                            Microsoft.Paint_8wekyb3d8bbwe                                     11.2309.28.0
Microsoft 人脉                  Microsoft.People_8wekyb3d8bbwe                                    10.2202.33.0
Power Automate                  Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe                      1.0.884.0
Raw Image Extension             Microsoft.RawImageExtension_8wekyb3d8bbwe                         2.1.62561.0
截图工具                        Microsoft.ScreenSketch_8wekyb3d8bbwe                              11.2309.16.0
Windows 安全中心                Microsoft.SecHealthUI_8wekyb3d8bbwe                               1000.25873.9001.0
Microsoft Store 体验主机        Microsoft.StorePurchaseApp_8wekyb3d8bbwe                          22307.1401.9.0
Microsoft To Do                 Microsoft.Todos_8wekyb3d8bbwe                                     2.108.62932.0
VP9 Video Extensions            Microsoft.VP9VideoExtensions_8wekyb3d8bbwe                        1.0.61591.0
Web 媒体扩展                    Microsoft.WebMediaExtensions_8wekyb3d8bbwe                        1.0.61591.0
Webp Image Extensions           Microsoft.WebpImageExtension_8wekyb3d8bbwe                        1.0.62681.0
Dev Home                        Microsoft.DevHome                                                 0.600.297.0             0.601.297.0    winget
Microsoft 照片                  Microsoft.Windows.Photos_8wekyb3d8bbwe                            2023.11100.11002.0
Windows 时钟                    Microsoft.WindowsAlarms_8wekyb3d8bbwe                             11.2306.23.0
Windows 计算器                  Microsoft.WindowsCalculator_8wekyb3d8bbwe                         11.2307.4.0
Windows 相机                    Microsoft.WindowsCamera_8wekyb3d8bbwe                             2023.2309.6.0
反馈中心                        Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe                        1.2304.1243.0
Windows 地图                    Microsoft.WindowsMaps_8wekyb3d8bbwe                               1.0.57.0
Windows 记事本                  Microsoft.WindowsNotepad_8wekyb3d8bbwe                            11.2309.28.0
Windows 录音机                  Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe                      1.0.66.0
Microsoft Store                 Microsoft.WindowsStore_8wekyb3d8bbwe                              22309.1401.5.0
Windows 终端                    Microsoft.WindowsTerminal                                         1.18.2822.0                            winget
Windows Package Manager Source… Microsoft.Winget.Source_8wekyb3d8bbwe                             2023.1108.906.756
Xbox TCUI                       Microsoft.Xbox.TCUI_8wekyb3d8bbwe                                 1.24.10001.0
Xbox Game Bar Plugin            Microsoft.XboxGameOverlay_8wekyb3d8bbwe                           1.54.4001.0
Game Bar                        Microsoft.XboxGamingOverlay_8wekyb3d8bbwe                         6.123.10181.0
Xbox Identity Provider          Microsoft.XboxIdentityProvider_8wekyb3d8bbwe                      12.95.3001.0
Xbox Game Speech Window         Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe                   1.21.13002.0
手机连接                        Microsoft.YourPhone_8wekyb3d8bbwe                                 0.23092.151.0
Windows 媒体播放器              Microsoft.ZuneMusic_8wekyb3d8bbwe                                 11.2309.6.0
电影和电视                      Microsoft.ZuneVideo_8wekyb3d8bbwe                                 10.22091.10051.0
快速助手                        MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe                  2.0.22.0
WinAppRuntime.Main.1.2          MicrosoftCorporationII.WinAppRuntime.Main.1.2_8wekyb3d8bbwe       2000.802.31.0
WinAppRuntime.Singleton         MicrosoftCorporationII.WinAppRuntime.Singleton_8wekyb3d8bbwe      4000.986.611.0
适用于 Linux 的 Windows 子系统  MicrosoftCorporationII.WindowsSubsystemForLinux_8wekyb3d8bbwe     1.2.5.0
Windows Web Experience Pack     MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy               423.29700.0.0
Mozilla Firefox (x64 zh-CN)     Mozilla.Firefox                                                   118.0.2                 119.0          winget
Mozilla Maintenance Service     MozillaMaintenanceService                                         107.0.1
Nmap 7.94                       Insecure.Nmap                                                     7.94                                   winget
Npcap                           NpcapInst                                                         1.75
Oh My Posh version 12.19.0      JanDeDobbeleer.OhMyPosh                                           12.19.0                 18.23.3        winget
Microsoft OneDrive              Microsoft.OneDrive                                                23.209.1008.0002                       winget
向日葵远程控制                  Oray SunLogin RemoteClient                                        13.3.1.56398
Postman x86_64 10.17.4          Postman.Postman                                                   10.17.4                 10.19.7        winget
PotPlayer-64 bit                Daum.PotPlayer                                                    230904                  231102         winget
Tencent QQMail Plugin           QQMailPlugin                                                      Unknown
QQ音乐                          Tencent.QQMusic                                                   19.42                   19.57          winget
搜狗输入法 13.9.0正式版         Sogou.SogouInput                                                  13.9.0.8319             13.10.0.8469   winget
Steam                           Valve.Steam                                                       2.10.91.91                             winget
MyDockFinder                    Steam App 1787090                                                 Unknown
ToDesk                          Youqu.ToDesk                                                      4.6.0.3                 4.7.2.0        winget
JetBrains Toolbox               JetBrains.Toolbox                                                 2.0.5.17700                            winget
微信                            Tencent.WeChat                                                    3.9.7.29                               winget
腾讯会议                        Tencent.TencentMeeting                                            3.13.5.459              3.20.5.478     winget
微信输入法                      Tencent.WeType                                                    1.0.0.198                              winget
Wireshark 4.0.7 64-bit          WiresharkFoundation.Wireshark                                     4.0.7                   4.0.10.0       winget
ZeroTier One                    ZeroTier.ZeroTierOne                                              1.12.2                                 winget
Another Redis Desktop Manager … qishibo.AnotherRedisDesktopManager                                1.5.9                   1.6.1          winget
Lens 2023.9.191233-latest       Mirantis.Lens                                                     2023.9.191233-latest    2023.9.290703… winget
Clash for Windows 0.20.39       af61d581-bfa6-515e-bf22-56b60d25a5b3                              0.20.39
Obsidian                        Obsidian.Obsidian                                                 1.4.13                  1.4.16         winget
electerm 1.25.41                electerm.electerm                                                 1.25.41                 1.34.48        winget
Apifox 2.3.4                    Apifox.Apifox                                                     2.3.4                   2.3.25         winget
Feeder                          d840680a4e05b63ffde9fcad431df885                                  1.0
喜马拉雅                        Ximalaya.Ximalaya                                                 3.2.0                   4.0.2          winget
uTools 4.0.1                    Yuanli.uTools                                                     4.0.1                   4.2.0          winget
Feeder                          feeder.co-3D5854A2_samb8b3zyh122                                  1.0.0.0
Hoppscotch                      hoppscotch.io-410280BD_4s769wm2tjggg                              1.0.0.0
Hoppscotch                      hoppscotch.io-F91C9945_4s769wm2tjggg                              1.0.0.1
Insomnia                        Insomnia.Insomnia                                                 2023.4.0                               winget
邮件和日历                      microsoft.windowscommunicationsapps_8wekyb3d8bbwe                 16005.14326.21640.0
Poe-CHATGPT                     poe.com-1C997981_v5jfab921b2p0                                    1.0.0.1
迅雷                            thunder_is1                                                       11.4.5.2072
wpsappext1                      wpsappext1_km9wtz8rh8me0                                          1.0.0.0
wpsappext2                      wpsappext2_km9wtz8rh8me0                                          1.0.0.0
wpsappext3                      wpsappext3_km9wtz8rh8me0                                          1.0.0.0
Go Programming Language amd64 … GoLang.Go                                                         1.20.4                  1.21.4         winget
腾讯QQ                          Tencent.QQ                                                        9.7.13.29149            9.7.17.29230   winget
ImageGlass                      DuongDieuPhap.ImageGlass                                          8.10.9.27                              winget
IIS 10.0 Express                {0DCE4558-8BF6-4C7A-B293-CDDDCE047934}                            10.0.08009
xedge-tui                       {0FCC095F-F72D-4BAB-89CD-6552BA9CADD8}                            0.2.2
JetBrains ETW Host Service (x6… {15727852-5BEA-4C50-A5AD-1F931B860CC3}                            16.36.0
Windows SDK AddOn               {15941C7F-810D-41DF-8C5A-8D0490277AFB}                            10.1.0.0
滴答清单 版本 4.5.8.0           {1A434D02-8C9A-41A2-9BBE-C97A1E31ABC1}_is1                        4.5.8.0
Microsoft Visual C++ 2012 Redi… Microsoft.VCRedist.2012.x86                                       11.0.61030.0                           winget
Microsoft SQL Server 2019 Loca… {36E492B8-CB83-4DA5-A5D2-D99A8E8228A1}                            15.0.4153.1
Tailscale                       tailscale.tailscale                                               1.50.1                  1.52.1         winget
Microsoft .NET SDK 7.0.402 (x6… {3AFB00B0-F339-409C-8529-77D41736A5F2}                            7.4.223.48029
EmEditor (64-bit)               Emurasoft.EmEditor                                                22.5.2                                 winget
Oracle VM VirtualBox 7.0.10     Oracle.VirtualBox                                                 7.0.10                  7.0.12         winget
Windows Subsystem for Linux WS… {3CBDE512-7510-4F90-B1C0-7C4EB9DD7C26}                            1.0.27
Microsoft System CLR Types for… Microsoft.CLRTypesSQLServer.2019                                  15.0.2000.5                            winget
Microsoft Visual C++ 2015-2022… Microsoft.VCRedist.2015+.x86                                      14.36.32532.0           14.38.32919.0  winget
Auto Dark Mode                  Armin2208.WindowsAutoNightMode                                    > 10.4.0.35                            winget
Logitech G HUB                  Logitech.GHUB                                                     2023.9.473951                          winget
FontForge version 01-01-2023    FontForge.FontForge                                               20230101                               winget
vs_CoreEditorFonts              {56FB5923-1A95-4D55-BE78-CD42B50E67AD}                            17.6.33605
Double Commander                alexx2000.DoubleCommander                                         1.0.11                                 winget
Google Drive                    Google.GoogleDrive                                                83.0.2.0                               winget
Microsoft Visual Studio Instal… {6F320B93-EE3C-4826-85E0-ADF79F8D4C61}                            3.7.2181.36443
Microsoft Visual Studio Code (… Microsoft.VisualStudioCode                                        1.84.1                                 winget
Clash Verge                     GyDi.ClashVerge                                                   1.3.8                                  winget
Microsoft Visual C++ 2015-2022… Microsoft.VCRedist.2015+.x64                                      14.36.32532.0           14.38.32919.0  winget
Quicker                         LiErHeXun.Quicker                                                 1.39.43.0               1.40.7.0       winget
Neovim                          Neovim.Neovim                                                     0.9.0                   0.9.2          winget
Microsoft Update Health Tools   {AF47B488-9780-4AB5-A97E-762E28013CA6}                            5.71.0.0
Microsoft ODBC Driver 17 for S… {BE12E5B1-C477-48F5-981D-5C37B4390E02}                            17.7.2.1
Node.js                         OpenJS.NodeJS.LTS                                                 18.17.1                 20.9.0         winget
Microsoft Web Deploy 4.0        Microsoft.WebDeploy                                               10.0.7421                              winget
QuickLook                       QL-Win.QuickLook                                                  3.7.3.0                                winget
Microsoft Visual Studio Setup … {E281F6E2-136B-4AF0-895B-253279711697}                            3.7.2182.35401
Integrated Camera Driver        {E399A5B3-ED53-4DEA-AF04-8011E1EB1EAC}                            10.0.22000.20274
es-client                       {E44BA05D-3AF0-4CDA-8237-3FDC9AF73F33}                            2.7.0
Microsoft Build of OpenJDK wit… Microsoft.OpenJDK.11                                              11.0.16.101             11.0.21.9      winget
Windows Subsystem for Linux Up… {F8474A47-8B5D-4466-ACE3-78EAB3BF21A8}                            5.10.102.1
komorebi                        LGUG2Z.komorebi                                                   0.1.18                                 winget
ChatGPT                         lencx.ChatGPT                                                     1.0.0                   1.1.0          winget
PowerToys (Preview) x64         Microsoft.PowerToys                                               0.73.0                  0.75.1         winget
Windows Software Development K… Microsoft.WindowsSDK.10.0.22000                                   10.0.22000.832                         winget
PowerShell 7.3.9.0-x64          Microsoft.PowerShell                                              7.3.9.0                                winget
企业微信                        Tencent.WeCom                                                     4.1.10.6015                            winget
网易云音乐                      网易云音乐                                                        2.10.6.200601
钉钉                            Alibaba.DingTalk                                                  7.0.55-Release.8159101  7.1.0-Release… winget
阿里旺旺                        Alibaba.AliIM                                                     10.01.02C               10.01.03C      winget
```
