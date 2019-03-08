---
title:  linux各个发行版本对比
date:   2019-03-08 10:00:00 +0800
categories: ["笔记"]
tags: ["centos","linux"]
keywords: ["centos","debian","arch","cockpit","桌面","驱动","vps","内核","兼容"]
description: "纠结过很久这个问题，结论最终是选择centos。写一篇日志，如果以后改变了选择，那肯定是因为随着系统的迭代，优缺点出现了不同"
draft: true
---


> 纠结过很久这个问题，结论最终是选择centos。写一篇日志，如果以后改变了选择，那肯定是因为随着系统的迭代，优缺点出现了不同。

各大主流发行版
===
[debian/Ubuntu](https://www.debian.org)系列
---
非常棒的发行版。用户量很大，更新也很及时。优点如下：  
1. 包管理工具采用`apt`，包数量很多，非常方便。
2. 分`unstable`，`testing`，`stable`版本。**unstable版本不稳定**，但是紧跟内核。**testing漏洞补丁一般是最慢**，但是毕竟稳定不少。**stable新特性最慢**，但是坚如磐石。
3. 对开发人员`友好`，很多的工具都在debian进行ci测试。

`Ubuntu`是`debian`的下游，说是很友好。但是**漏洞修补慢，unstable的包很不稳定**。实在不知道为什么不用`debian`。就为了一个官方版本的网易云音乐吗？


[centos/RHEL/Fedora](https://www.centos.org/)系列
---
我见过用户量最大，文档最齐全(这里也包括博客等文档)的发行版。优点如下:  
1. RHEL是最大的商业linux公司支持的。内核贡献度第一。技术实力强，`稳`。
2. 文档最齐全，解决问题参考方案特别多。
3. 企业用户量大，如果公司有钱，出问题一个电话给你商业支持。

**没钱**就用`centos`稳。**有钱人**就用`RHEL`，出问题有人接锅。   
个人开发，追求内核更新速度，想**体验最新特性**用`Fedora`。  

[arch](https://www.archlinux.org/)系列
---
爱折腾技术的极端分子。优点如下:  
1. 永远`滚动更新`。
2. 追求精益求精，什么都自己来，包括自己编译。不要任何一点冗余。
3. 官方文档是典范。甚至可以当linux的参考教程来用。


linux各版本的取舍
===
抛开需求，谈取舍是完全没有意义的。所以我的选择过程，可以给读者作参考。
1. 个人苦短，我用`python`。所以我就不会用`arch`系列....等哪天财务自由再说吧
2. 用linux最重要的就是，解决问题。不然为什么不用`win10`呢？所以我做了不同系统的尝试

我遇到的问题
===
尝试debian的原因
---
1. vps里想要`bbr`特性，`内核`要上到4.9，总觉得centos自己升级内核，没debian的默认好。
2. 使用testing或者unstale，类似`滚动更新`，`一劳永逸`啊！
3. `apt`的包多啊，比如ss-libev直接一下就能搜到。centos还要去加`copr源`，跟进也不够及时
4. 以后linux来办公，那服务器和工作站就同样环境了呀，centos可能不好看

死心的原因
---
**可能也是因为我太懒了，折腾不出来**
1. 按照官方教程，`cockpit`在centos上完全正常。debian上登陆以后空白，出现一个send_async(好像是这个)的错误。找了一下资料，无果...
2. centos安装图形化界面+`tightvnc`，官方一步一步走，ok。debiban需要配置xstartup。这个`xtartup`脚本我折腾了好久，结果只能出来一个gnome经典界面，没有特效。。 另外一个xtartup配置出来了`xfce`的界面。。 效果不理想
3. 我在用centos的几年里，没有遇到过依赖问题。可能是我只用到了皮毛。但是debian却在2天内让我遇到了。可能是包更新的速度，有的快，有的慢导致的，很头疼。
4. 驱动问题。centos因为维护时间长，变化不大。只要安装好了显卡驱动，一次就能跑好多年。而如果用了debian，我看了一些文档，说nvidia的驱动都要改动内核还是什么的。很有可能哪次更新内核，就会挂。 这一点只是我的担心，没有实际操作过
5. 如果我使用桌面版本，`fedora`似乎更新，桌面使用更加友好。`pipenv`这样的工具，在官方github上对fedora也有特别照顾。同时redhat的许多工程师，都是在致力于fedora的bug修复，稳定性我也觉得不会比debian的差到哪去。  

个人原因
---
我一直以来都是接触的`centos`,所以更加熟悉它。  
服务器大量都是centos系列，如果我客户端使用fedora，对以后centos服务器升级，也是有帮助的。这和我的工作内容有关。  



读者可能遇到的问题
===
qq
---
推荐用chrome浏览器运行安卓版本qq就好了。或者参考[docker-qq](https://github.com/bestwu/docker-qq)

听歌
---
推荐[listen1](https://github.com/listen1/listen1_desktop)，跨音乐平台收藏听歌！

office
---
[wps](http://www.wps.cn/)有linux版本了。
