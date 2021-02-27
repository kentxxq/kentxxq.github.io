---
title:  关于hugo的SEO优化
date:   2021-02-27 15:46:00 +0800
categories: ["笔记"]
tags: ["hugo"]
keywords: ["hugo","SEO","优化","结构化数据","kentxxq"]
description: "看了一下历史记录，差不多有好几个月没有写过博客了。。这次就写一下这两天的博客SEO优化设置吧"
---


> 看了一下历史记录，差不多有好几个月没有写过博客了。。这次就写一下这两天的博客SEO优化设置吧


### 先说情况

SEO我其实只会在乎GOOGLE的搜索排名，百度的竞价以及使用不友好，实在懒得去搞。  
而且我觉得技术方面的SEO，国内的博客园、简书等等权重太高了。各种转载+一句话(链接)博客真的是太多了。

### 具体步骤

1. **持续的更新博客**。现在搜索kentxxq关键字，会发现我的博客已经被谷歌省略了。。可能是因为我很多文章都有大致类似的段落结构+很久没有更新新内容导致的。。
2. **结构化数据**又称富媒体。目的是为了让你的文章对爬虫友好。有时候谷歌搜索，会发现一些博客有具体的段落详情。下面就是一个例子。![结构化数据](/images/server/结构化数据示例1.png)  
可以看到下面有一些小链接标签，可以帮助用户快速跳转到指定位置。
同时还有东西。这里推荐使用[谷歌的富媒体搜索结果测试](https://search.google.com/test/rich-results)。  
问题来了，为什么我没有弄这个快速链接呢，是因为这是谷歌自动生成的。可以参考[如何将我的网页标记为精选摘要](https://developers.google.com/search/docs/advanced/appearance/featured-snippets?visit_id=637500114156437621-3767625005&rd=1#how-can-i-mark-my-page-as-a-featured-snippet)。其实还是要你把网站内容做好，相关度做上去才行。
3. **提交sitemap**。网上有很多的教程示例，可以参考[我的sitemap](https://kentxxq.com/sitemap.xml)

### 如何验证

打开我的这个[博客页面](https://kentxxq.com/contents/netcore%E7%9A%84%E5%88%9D%E6%AD%A5%E4%BA%86%E8%A7%A3)  
1. 你的页面应该有一些基础信息。通常网站都会有![基础信息](/images/server/结构化数据示例2.png)
2. 你的页面应该有完整的`application/ld+json`![ld+json](/images/server/结构化数据示例3.png)  
而其中我觉得最重要的就是需要有发布时间和修改时间！虽然在sitemap里面有lastmod时间，但保险起见，单个页面应该也需要。![ld+json](/images/server/结构化数据示例4.png) 