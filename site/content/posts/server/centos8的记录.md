---
title:  centos8的记录
date:   2019-12-31 16:36:00 +0800
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","yum","bbr","ss"]
description: "centos7从我刚开始接触linux就开始用。所以在我使用的时候，老是不明白为什么会有人喜欢centos6。centos真是万年才更新一次大版本，导致许多的新特性不能使用。而我经常喜欢追热点。。所以这一次我要用上最新的centos8"
---


> centos7从我刚开始接触linux就开始用。所以在我使用的时候，老是不明白为什么会有人喜欢centos6。centos真是万年才更新一次大版本，导致许多的新特性不能使用。而我经常喜欢追热点。。所以这一次我要用上最新的centos8。


心路历程
===

在我听到rhel8的时候，就开始关注centos8。于是了解到centos总是要晚很多才会发布。而我的服务器因为墙的原因，不过半年我就要换。所以超级想找机会换centos8。

在整个rhel的产品线中，有一些非常有用的小知识。

Fedora是最前沿。非常贴近最新的linux内核主线。体验最新的技术选它肯定没错。并且有大量的红帽工程师处理问题，稳定性和问题修复相当于有了商业支持。我觉得非常适合喜欢rhel系列的用户作为桌面端。

rhel是收费的。在经过上游的一系列排错以后，会选取一个最稳定，特性最实用的版本。用来长期支持。购买了授权以后，会拥有无微不至的关怀。技术人员可以为你从源码级别修复你的疑难杂症。

centos则可以理解为rhel的开源版本。重点是免费。


centos8新特性
===

包管理yum和dnf
---

每个linux都有对应的包管理工具。而yum也因为rhel为人熟知。而我之前了解Fedora的过程中，也知道了centos7之后的包管理工具肯定会被dnf所替代。

```bash
[root@sgp ~]# which yum
/usr/bin/yum
[root@sgp ~]# ll /usr/bin/yum
lrwxrwxrwx. 1 root root 5 May 14  2019 /usr/bin/yum -> dnf-3
[root@sgp ~]# 
```

可以看到命令没有变，但是已经指向了dnf。所以下面说一下特点。

1. 之前应该是用python2写的，现在[开源在github](https://github.com/rpm-software-management/dnf/)上，用的python3。毕竟python2马上淘汰了，python3是未来。优化也更多。
2. 性能方面说是更快了。其实任何项目重构以后我都认为架构会更合适，性能都会有优化。
3. 可以删除正在使用的内核，升级内核更为方便了。

总体来说全方位都变强了。这也是为什么dnf会完全取代yum的原因。


内核升级
---

内核升级到了4.18，这也是我为什么要换成centos8的原因。

我的vps是在新加坡的。海外节点网络很是不稳定。bbr特性非常适合我。但是bbr需要内核版本4.9以上才行，所以打知道阿里云有了centOS8，我就打定主意要换。

开启bbr

```bash
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
# 生效
sysctl -p
# 验证
lsmod | grep bbr
```

内置python升级
---

历来python都是linux上不可或缺的一部分。几乎所有的标准版安装，都会带上它。

而之前都是python2，同时因为有大量的脚本和工具使用python2开发的。所以一直以来都是在缓慢推进演变过程。

而现在已经到时候了。许多的linux都升级到了python3。python2眼看就要被停止支持。所以升级也是理所当然的。

自带的是python3命令，3.6.8版本。算是很新的版本了。由于我一直都是使用python3，所以以后在服务器做一些测试调整，就不需要再通过pyenv等等工具来进行版本切换了。


总结
===

其他方面centOS8还有大量的更新，但都是一些让你体会不明显的改动。比如说更加完好的c/c++标准支持。因为centOS7这么多年走来，通过docker等等技术已经解决得差不多了。

好久没有写日志了。前几天看了一个视频，说的是边缘。现在开始觉得，如果一个地方投入相同的精力，却可以拿到更多的回报。那么我应该去重新考量，而不是一条路走到黑。