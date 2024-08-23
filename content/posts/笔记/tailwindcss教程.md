---
title: tailwindcss教程
tags:
  - blog
  - 前端
date: 2024-07-30
lastmod: 2024-08-23
categories:
  - blog
description: 
---

## 简介

`tailwindcss` 是一个 css 原子化工具, 其实就是提供规范/便捷的类名. 包含布局

## 常用类名

### 大小

- `w-{size}`: 元素宽度，例如 `w-1/2` 表示元素宽度为父容器宽度的一半
- `h-{size}`：设置元素高度，例如 h-16 表示元素高度为 16 像素
- `min-h-screen`: `min-height: 100vh`
- `min-h-full`: `min-height: 100%`
- `min-w-{size}`：设置元素最小宽度，例如 `min-w-0` 表示元素最小宽度为 0。
- `max-w-{size}`：设置元素最大宽度，例如 `max-w-md` 表示元素最大宽度为中等屏幕大小。

常用大小

- xs 极小
- sm 小
- md 中等
- lg 大
- xl 超大
- 2xl xxl 更大

### 图片

- `scale缩放`
    - `scale-75`: `transform: scaleX(0.75)`
    - `scale-x-110`: `transform: scaleX(1.1);`
- `rotate旋转`
    - `rotate-45`: 顺时针/向右转动 45 度
- `skew旋转` [Skew - Tailwind CSS](https://tailwindcss.com/docs/skew)
- `origin旋转源`, 配合 `rotate-45` 适用. [Transform Origin - Tailwind CSS](https://tailwindcss.com/docs/transform-origin)
    - `origin-top-right` 右上.  类似圆规. 以图片的右上方为中心, 旋转图片 45 度.
    - `origin-bottom-left` 左下

### 文本

- `text-{color}` 文本颜色
- `text-{size}` 文本大小
    - `text-sm` 小号字体
    - `text-base` 默认字体
    - `text-lg` 大号字体
    - `text-xl` 更大, `2xl`, `3xl`
- `text-wrap` 换行
    - `text-nowrap` 不换行
    - `text-pretty` 避免在新的一行只展示很少的字 (两个单词)
- `break-all` 强制换行, 避免超出容器边界
- `line-clamp-*` 太长了显示省略号, `line-clamp-1` 意思是保留一行. 需要配合 `break-all` 使用

### 字体

[Font Family - Tailwind CSS](https://tailwindcss.com/docs/font-family)

- `font-sans`
- `font-serif`
- `font-mono`

[Font Weight - Tailwind CSS](https://tailwindcss.com/docs/font-weight)

- `font-light` 细
- `font-normal` 正常
- `font-medium` 中等
- `font-bold` 加粗 **常用**

### 列表

- `list-decimal` 数字
- `list-disc` 黑点
- `list-none` 无样式

### 间隔

- `padding`
    - `p-0`: `padding: 0px;`
    - `px-0`: `padding-left: 0px; padding-right: 0px;`
    - `px-0`: `padding-top: 0px; padding-bottom: 0px;`
- `margin`
    - `m-auto`, `mx-auto` , `my-auto`
    - `m-0`: `margin: 0px;`
    - `mx-0`: `margin-left: 0px; margin-right: 0px;`
    - `mx-0`: `margin-top: 0px; margin-bottom: 0px;`
- `space-x-4` 把内部多个 card 卡片的间隔加大
- `space-y-4` 把列表的上下间隔加大

### 背景

- `bg-{color}`：设置背景颜色，例如 `bg-gray-300` 表示使用灰色背景。
- `bg-{image}`：设置背景图片，例如 `bg-cover` 表示使用覆盖整个元素的背景图片。
- `bg-{position}`：设置背景位置，例如 `bg-center` 表示将背景图像居中对齐。
- `bg-{size}`：设置背景尺寸，例如 `bg-auto` 表示使用原始背景图像大小。

### 边框/轮廓/阴影

- `border-{color}`：设置边框颜色，例如 `border-red-500` 表示使用红色边框。
- `border-{size}`：设置边框大小，例如 `border-2` 表示边框宽度为 2 像素。
- `border-{side}`：设置边框位置，例如 `border-l` 表示只在元素左侧添加边框。
- `rounded-{size}`：设置圆角大小，例如 `rounded-full` 表示使用完全圆角。
- `box-shadow` 设置阴影
    - `shadow-sm`
    - `shadow-md`
    - `shadow-lg` **常用**
    - `shadow-xl`

### 模糊

- `blur-*` [Blur - Tailwind CSS](https://tailwindcss.com/docs/blur)
    - `blur-none` 不模糊
    - `blur-sm`: `filter: blur(4px);` **常用**
    - `blur`: `filter: blur(8px);`
    - `...`

### 透明 - 按钮是否可点击

[Opacity - Tailwind CSS](https://tailwindcss.com/docs/opacity)

- `opacity-*`
    - `opacity-100`: 不透明
    - `opacity-50`: 按钮不可用的时候, 用这个

### 动画

- `hover:scale-110` 移动上去就会放大
- `transition` 添加默认的动画效果
    - `duration-100` 动画持续 100 ms
    - `delay-100` 延迟 100 ms 触发
    - `ease-in` 动画逐渐加速
    - `ease-out` 动画逐渐减速
    - `ease-in-out` 平滑开始, 平滑结束

### 布局

`container`: 自带响应式. 不同宽度屏幕上, 会变窄. 通常搭配 `mx-auto` 做居中

```html
<div class="container mx-auto">
  <h1 class="text-3xl font-bold">Hello, World!</h1>
  <p class="mt-4">This is a responsive container.</p>
</div>
```

`flex` 是重头戏 [Flex Basis - Tailwind CSS](https://tailwindcss.com/docs/flex-basis)

- `flex-basis`

    ```html
    <div class="flex flex-row">
      <div class="basis-1/4">01</div>
      <div class="basis-1/4">02</div>
      <div class="basis-1/2">03</div>
    </div>
    ```

- 方向
    - `flex-row`: 从左到右
    - `flex-col`: 从上到下
- 换行
    - `flex-nowrap`
    - `flex-wrap`
- 空间分配 `flex-*`, 是 `flex-grow`, `flex-shrink` 和 `flex-basis` 的简写
    - `flex-grow: 0` 默认 0 不放大占用剩余空间
        - 如果多个项目都是 `flex-grow: 1`, 那么就会平分剩余空间.
        - 设置成 2 的空间会是 1 的一倍
    - `flex-shrink: 1` 默认 1 表示大家等比缩放. 如果有一个元素不想缩放, 就设置成 0
    - `flex-basis: auto` 在分配多余空间之前，项目占据的主轴空间.
        - 默认 auto 表示元素本来占用的空间大小
    - [ 搭配使用, 官方有图例](https://tailwindcss.com/docs/flex)
        - `flex-none`: `flex: none;` 禁止放大缩小. 导航栏右侧的登录按钮, 如果不加上这个, 页面缩小后会换行. 而我们不需要换行
        - `flex-1`: `flex: 1 1 0%;` 自动缩放, 忽略初始大小. 适用于元素没有设置 width ,完全自动缩放的时候.  **常用**
        - `flex-auto`: `flex: 1 1 auto;` 自动缩放. 适用于元素有 width, 按照元素已有的 width 比例计算
        - `flex-initial`: `flex: 0 1 auto;` 只准缩小, 不准放大. 按照元素已有的 width 比例计算

## 实践

### 渐变色

[Background Clip - Tailwind CSS](https://tailwindcss.com/docs/background-clip)

```html
<div class="text-5xl font-extrabold ...">
  <span class="bg-clip-text text-transparent bg-gradient-to-r from-pink-500 to-violet-500">
    Hello world
  </span>
</div>
```

- `text-transparent` 文本透明. 这样可以展示出背景颜色.
- `bg-clip-text` 把背景颜色剪辑成文本的样子. 这样就只会在文本区域显示背景色
- `bg-gradient-to-r` 从左到右渐变
- `from-pink-500 to-violet-500` 颜色的起点和终点
