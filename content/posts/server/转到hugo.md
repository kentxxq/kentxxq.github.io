---
title:  转到hugo后的架构
date:   2018-12-23 00:00:00 +0800
categories: ["笔记"]
tags: ["server"]
keywords: ["hugo","架构","jekyll","github","微软","gitlab"]
description: "趁着从jekyll转hugo，也重新来规划一下自己的个人网站以及代码部署架构"
---

> 趁着从jekyll转hugo，也重新来规划一下自己的个人网站以及代码部署架构。

## 转到hugo

之前有写过一篇笔记对比。但是使用的是`jekyll`。为什么切换成`hugo`呢？说一下`jekyll`主要缺点  

1. 需要ruby的环境，本地编译生成静态网站。麻烦  
2. 因为以后都会用下去，所以以后多了，难免会比较慢，快一点  
3. 可以更方便的切换主题。改动量更小  
4. archetypes很好用，很方便  

后面的改动，具体参考开发以及运维的流程吧

## 访问架构

1. 第一层用nginx来代理，同时它也用来分发请求
2. 第二层直接可以跳转到github/blog/个人项目

## 代码结构

全部存放在`github`私人仓库  

1. 服务器使用centos，完成所需服务的配置。例如ss，bbr，docker之类的
2. 部署nginx好服务
3. 放好触发代码部署的钩子
4. 第一次手动触发钩子。所有的服务就启动好了


## 20190110 更新

> github被微软收购以后，居然免费了？！不过分担心盈利问题了以后，就是不一样。。所以我又花了2个多小时切换回github..
1. github更快
2. 不用在gitlab和github中跳转了。因为github的资源是最多的
