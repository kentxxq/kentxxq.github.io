---
title:  gitea_搭建超简单的git代码管理服务
date:   2019-03-19 17:35:00 +0800
categories: ["笔记"]
tags: ["gogs","git"]
keywords: ["gogs","go","git","代码管理服务","gitea"]
description: "一直管理着公司的svn。但是我的个人代码和项目都是用的git，代码也全部托管在github。之前就听说过gogs了。今天心想，要是以后公司用git管理，我应该就会选择gogs"
---


> 一直管理着公司的svn。但是我的个人代码和项目都是用的git，代码也全部托管在github。之前就听说过gogs了。今天心想，要是以后公司用git管理，我应该就会选择gitea。

## 如何选择git托管服务器

现在我接触过的，也就只有`gitlab`，`gogs`，`gitea`。其他的我都觉得打不过gitlab。  
当然,不谈场景就来选择，这是最错误的做法。  

### 大公司场景

推荐使用`gitlab`:  

1. 拥有超多的用户，没什么坑。保证持续稳定的运行。即使出现故障也容易找到解决方案。
2. 功能齐全，ci/cd等等功能一应俱全。大公司一般都用到ci/cd等等工具保证流程化运转。

gitlab其实在速度，部署便捷性等等方面没有优势。但是性能不够，机器来凑。

### 小型公司场景

推荐`gogs`或`gitea`:  

1. go语言编写，性能比ruby好。同样的，也对机器性能要求低。
2. 部署，迁移过程非常方便。

一个代码服务器。10个开发人员，一天可能就200次提交？一个树莓派就搞定了的事情。


## 对比`gogs`和`gitea` 

gitea是gogs的一个分支。但是分支很早(大概2016年)，已经有了很大的区别。  

为什么我使用gitea呢？**虽然我听歌爱听原曲，系统爱用原生，但是我使用gitea**。特性如下:  

1. 更多的特性以及功能(比如仓库内代码搜索)。
2. 更加齐全的文档(比如docker的安装配置)。
3. 更加积极的开发(20190319日-贡献者更多)。
4. 如果上面3点都对你没什么帮助。那你就gogs啊。


## docker安装

作为一个docker的忠实拥簇，写一下docker的使用  

```bash
# 拉去镜像
docker pull gitea/gitea:latest
# 创建数据存放目录
sudo mkdir -p /var/lib/gitea
# 运行docker，完成部署
sudo docker run -d --rm --name=gitea -p 10022:22 -p 10080:3000 -v /var/lib/gitea:/data gitea/gitea:latest

# 解释
# 10022端口可以进行远程登陆
# 10080端口可以进行web访问，并且提供git服务
# /var/lib/gitea为本地的数据目录 对应到容器中的/data
```


> 在写这篇文章的时候，我非常得纠结。我其实是有选择困难的。在linux中，我对比debian和centos等等系列，最后我说服了自己选择centos。而这一次，我选择gitea。