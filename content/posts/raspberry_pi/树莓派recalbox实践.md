---
title:  树莓派recalbox实践
date:   2021-03-21 14:36:00 +0800
categories: ["笔记"]
tags: ["raspberry pi"]
keywords: ["raspberry pi","recalbox","kodi","直播源","nes"]
description: "买了树莓派4b的4gb版本，就是因为哪怕是要吃灰了，我也可以把家里那个垃圾电视盒子给替换掉。那个电视盒子其实只是是一个运营商送的垃圾盒子，通过电视猫之类的app来看电视，还特别多的广告。所以有了今天先把这个吃灰救星给弄好。这次实践的目的是让这个盒子一定能跑起来，所以后续哪怕出现问题，我也会不定时更新，解决问题"
---


> 买了树莓派4b的4gb版本，就是因为哪怕是要吃灰了，我也可以把家里那个垃圾电视盒子给替换掉。那个电视盒子其实只是是一个运营商送的垃圾盒子，通过电视猫之类的app来看电视，还特别多的广告。所以有了今天先把这个吃灰救星给弄好。这次实践的目的是让这个盒子一定能跑起来，所以后续哪怕出现问题，我也会不定时更新，解决问题


## 前情提要

键盘或手柄的按键映射请[参照最新的文档](https://recalbox.gitbook.io/documentation/basic-manual/getting-started/controller-configuration#using-a-keyboard)。我主要以操作步骤为主，只会对极个别操作进行按键说明。


## recalbox

### recalbox简介

这个没什么难的，只要用imager刷入系统就可以了。然后会自动进入操作界面。

recalbox是一个游戏模拟器的合集+kodi媒体中心！是的，都集成到了一起是我选用它的主要原因。

### 基础设置

1. **中文显示**:`主菜单=>系统设置=>语言=>确认选中语言`
2. **ip地址查看**:`主菜单=>网络设置=>ip地址`
3. **ssh连接**:`ssh root@ip地址`,密码`recalboxroot`。但是有一点需要注意，recalbox可以看作是一个**独立的linux发行版**。这意味着你**无法使用yum或者apt**，也**无法安装npm和deb包**！

### web界面

**系统管理界面**: `用浏览器访问ip`，默认就是访问80端口。![recalbox管理界面](/images/raspberry_pi/recalbox管理界面.png)

其中的控制器模拟界面，对于测试了解手柄非常有用。![recalbox控制界面](/images/raspberry_pi/recalbox控制界面.png)



### recalbox游戏

这里我就讲一下大致的步骤吧，下载游戏的网站我也随便[贴一个](http://www.rendiyu.com/emu/fc/)，试过了没问题
1. 下载一个游戏rom包，例如`马里奥.nes`。**这个文件名最后会变成recalbox里面的游戏名**！！
2. 在[web界面](http://172.18.76.201/roms/nes)上传这个文件，重启es服务![recalbox控制界面](/images/raspberry_pi/recalbox游戏rom上传.png)
3. nes是nintendo entertainment system的简写，找到这个模拟器，就可以看到游戏了![recalbox游戏界面1](/images/raspberry_pi/recalbox游戏界面1.jpg)![recalbox游戏界面2](/images/raspberry_pi/recalbox游戏界面2.jpg)


## kodi配置

`主菜单=>kodi媒体中心`,系统会重启。**kodi和recalbox的键盘映射不一定相同**！

### kodi中文设置

1. `设置齿轮=>interface=>Skin=>Font=>Arial based`
2. 同界面下，`Regional=>Language=>简体中文`

### kodi启用插件

**启用插件**:`插件=>我的插件=>PVR客户端=>PVR IPTV Simple Client=>启用`

### 使用直播源

1. 去github上面[下载](https://github.com/imDazui/Tvlist-awesome-m3u-m3u8#%E8%A7%86%E9%A2%91%E6%95%99%E7%A8%8B)需要的电视直播源文件。
2. 默认recalbox通过`SMB协议共享`出来了我们需要的文件夹，我们可以直接访问进去。在`share/kodi`下面新建m3u8文件夹，然后把下载好的直播源文件放进去。
3. 在插件iptv界面进入设置，选择本地文件m3u。
4. 点击kodi开关，退出。然后重新进入kodi

进入电视就可以看是选台看电视了！

## todo

### 直播源工具
有很多的直播源质量不高，主要愿意是直播源有地域之分。你在北方不错的直播源可能到了南方就用不了。所以准备写一个插件来解决这个问题。

目标：抓取知名的直播源，进行测试。生成m3u文件。然后一直用这个源即可。程序预计是一条命令部署在recalbox主机上。

