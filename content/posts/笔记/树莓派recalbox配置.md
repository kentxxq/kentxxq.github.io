---
title: 树莓派recalbox配置
tags:
  - blog
  - 树莓派
date: 2021-03-21
lastmod: 2023-07-11
categories:
  - blog
description: "recalbox 是一个游戏模拟器的合集 +kodi 媒体中心！是的，都集成到了一起是我选用它的主要原因。下面的内容都是在 [[笔记/point/树莓派|树莓派]] 上操作的."
---

## 简介

recalbox 是一个游戏模拟器的合集 +kodi 媒体中心！是的，都集成到了一起是我选用它的主要原因。下面的内容都是在 [[笔记/point/树莓派|树莓派]] 上操作的.

## 配置内容

### 基础设置

1. **中文显示**:`主菜单=>系统设置=>语言=>确认选中语言`
2. **ip 地址查看**:`主菜单=>网络设置=>ip地址`
3. **ssh 连接**: `ssh root@ip地址`,密码 `recalboxroot`。但是有一点需要注意，recalbox 可以看作是一个**独立的 linux 发行版**。这意味着你**无法使用 yum 或者 apt**，也**无法安装 npm 和 deb 包**！

### Web 配置

**系统管理界面**: `用浏览器访问ip`，默认就是访问 80 端口。![[附件/recalbox的web管理界面.png]]

其中的控制器模拟界面，对于测试了解手柄非常有用。![[附件/recalbox手柄测试.png]]

### recalbox 游戏

这里我就讲一下大致的步骤吧，下载游戏的网站我也随便 [贴一个](http://www.rendiyu.com/emu/fc/)，试过了没问题

1. 下载一个游戏 rom 包，例如 `马里奥.nes`。**这个文件名最后会变成 recalbox 里面的游戏名**！！
2. 在 [web界面](http://172.18.76.201/roms/nes) 上传这个文件，重启 es 服务!![[附件/recalbox上传rom.png]]
3. nes 是 nintendo entertainment system 的简写，找到这个模拟器，就可以看到游戏了 !![[附件/recalbox游戏选择界面.png]] !![[附件/recalbox游戏界面.png]]

### 开机自启

```shell
vim /etc/init.d/S99ddns-go

#/bin/bash
/etc/init.d/kentxxq/ddns-go

# 授予执行权限
chmod +x /etc/init.d/S99ddns-go
```

### kodi 配置

`主菜单=>kodi媒体中心`,系统会重启。**kodi 和 recalbox 的键盘映射不一定相同**！

#### kodi 中文设置

1. `设置齿轮=>interface=>Skin=>Font=>Arial based`
2. 同界面下，`Regional=>Language=>简体中文`

#### kodi 启用插件

**启用插件**: `插件=>我的插件=>PVR客户端=>PVR IPTV Simple Client=>启用`

#### 使用直播源

1. 去 github 上面 [下载](https://github.com/imDazui/Tvlist-awesome-m3u-m3u8#%E8%A7%86%E9%A2%91%E6%95%99%E7%A8%8B) 需要的电视直播源文件。
2. 默认 recalbox 通过 `SMB协议共享` 出来了我们需要的文件夹，我们可以直接访问进去。在 `share/kodi` 下面新建 m3u8 文件夹，然后把下载好的直播源文件放进去。
3. 在插件 iptv 界面进入设置，选择本地文件 m3u。
4. 点击 kodi 开关，退出。然后重新进入 kodi

进入电视就可以看是选台看电视了！

## 疑难杂症

### 操作系统架构

recalbox7.1.1 是 armv7l 架构。

arm64 是 64 位，默认的话就是 arm32。所以 recalbox7.1.1 是 32 位.

armv7 应该是可以运行 armv6 程序的，同理 armv8。

arm 默认都是小端存储。armv7l 就是后面的 l 就是小端的意思。

### 无法 chmod 执行权限

```bash
# 重新挂载即可
mount -o remount rw /
# 然后拷贝到/下面
cp x /x
chmod +x x
./x
```

### 图像显示溢出

```bash
# 当前我的版本是recalbox8: 去除黑边不一定有效，但是对图像溢出是有用的。
# 我在调整了很多次黑边距离，没有效果。虽然黑边不大，不太影响。 

# 重新挂载/boot分区
mount -o remount,rw /boot

# 编辑配置文件
su root
/boot/config.txt

disable_overscan=0
overscan_left=24
overscan_right=24
overscan_top=24
overscan_bottom=24
overscan_scale=1

# 重启生效
reboot
```
