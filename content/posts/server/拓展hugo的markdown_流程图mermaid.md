---
hiddenFromHomePage: false
title:  拓展hugo的markdown_流程图mermaid
date:   2019-03-30 21:59:00+08:00
categories: ["笔记"]
tags: ["hugo","markdown"]
keywords: ["hugo","markdown","mermaid","拓展","shortcodes"]
description: "有一段时间用有道云笔记来做笔记。里面有一个非常喜欢的功能就是流程图。让阅读文章的时候，体验更加的友好。同时我在看自己的站点过程中，觉得不够美观。更多的使用图表类似的功能，会让表达更加直观。所以今天就来动手做一下"
---


> 有一段时间用有道云笔记来做笔记。里面有一个非常喜欢的功能就是流程图。
>
> 同时我在看自己的站点过程中，觉得不够美观。更多的使用图表类似的功能，会让表达更加直观。所以今天就来动手做一下。


## hugo的渲染

### 使用markdown

主要采用`markdown`文件进行文章的编写，它的方案如下:  

1. md文件的解析，是用的[blackfriday](https://github.com/russross/blackfriday)
2. 除了已有的自带拓展，提供shortcodes来进行功能的拓展

### shortcodes的演示

使用`{{</* youtube 8HnLRrQ3RS4 */>}}`的简短编写，即可完成如下youtube视频的展示。

想要自动播放的话，使用`{{</* youtube id="8HnLRrQ3RS4" autoplay="true" */>}}"`即可。

{{< youtube 8HnLRrQ3RS4 >}}

## 为markdown拓展流程图

### 关于mermaid

[mermaid](https://github.com/knsv/mermaid)是一个js库，用来渲染流程图用的。2w多的star，看了一下文档，觉得博客是肯定够了的。

**如果真的要求特别高，那不如用专业软件做出来，导出图片更好。**

### 拓展步骤

1. 在你使用的主题中，找到`yoursite/themes/themes_name/layouts`文件夹，如果没有`shortcodes`文件夹，就自己新建一个
2. 把`mermaid的script标签`贴到`yoursite/themes/themes_name/layouts/partials/footer.html`的`footer外部`
```html
<!--head部分添加-->
<script src="https://cdn.bootcss.com/mermaid/8.0.0-rc.8/mermaid.min.js"></script>
```

在`shortcodes`目录下新建`mermaid.html`文件
```html
<!--mermaid.html-->
<div class="mermaid" align="{{ if .Get "align" }}
                                {{ .Get "align" }}
                            {{ else }} 
                                center
                            {{ end }}"> 
    {{ safeHTML .Inner }}
</div>
```

### ojbk，测试一下

```html
{{</* mermaid */>}}
sequenceDiagram
    participant Alice
    participant Bob
    Alice->John: Hello John, how are you?
    loop Healthcheck
        John->John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>prevail...
    John-->Alice: Great!
    John->Bob: How about you?
    Bob-->John: Jolly good!
{{</* /mermaid */>}}
```

---

{{<mermaid>}}
sequenceDiagram
    participant Alice
    participant Bob
    Alice->John: Hello John, how are you?
    loop Healthcheck
        John->John: Fight against hypochondria
    end
    Note right of John: Rational thoughts <br/>prevail...
    John-->Alice: Great!
    John->Bob: How about you?
    Bob-->John: Jolly good!
{{</mermaid>}}

## 文档参考

[mermaid文档](https://mermaidjs.github.io/)

[hugo文档](https://gohugo.io/documentation/)