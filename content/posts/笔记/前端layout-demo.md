---
title: 前端layout-demo
tags:
  - blog
  - 前端
date: 2023-11-11
lastmod: 2024-05-23
categories:
  - blog
description: "`layout-demo` 是一个练习布局, 样式, 动画等内容的项目. "
---

## 简介

`layout-demo` 是一个练习布局, 样式, 动画等内容的项目.

## 语法

### 元素类型

- 块级元素：
    - 独占一行. 从上到下排列
    - 宽度: 默认撑满父元素
    - 高度: 内容撑开
    - 可以设置宽高
    - `div`，`p`，`h1`, `ul`, `ol`, `li`, `table`, `form`
- inline 行内元素：
    - 不独占一行. 太长了会自己换行
    - 宽度: 内容撑开
    - 高度: 内容撑开
    - `a`,`strong`
    - 不能设置宽高
    - 特定的 inline-block 可以设置宽高. 例如 `img`,`input`,`button`
- 可以通过 display 修改

### display 布局展现形式

- `display:block` 是一个块级元素。开始新的一行，撑满容器。例如 `p`，`form`，`header`，`footer`
- `display:inline` 是行内元素。包裹内容但不打乱布局。`a` 就是一个行内元素，用来展示链接
- `display:none` 不删除元素的情况下隐藏，不会占用空间。`visibility:hidden` 会占用空间
- `display:flex` 用于指定自己内部元素布局，参考 [[笔记/前端layout-demo#flex 布局|flex 布局]]

案例：

- 每个元素都有默认的 display，常见的改动就是 `li` 元素改成 `inline`，制作水平菜单
- 一个 div 容器内有 2 个 div，左边 20%，右边 80%。需要 `display: flex` 来让它排列

### 长度宽度

```css
/* 相对父元素10%,内部布局的时候用 */
width: 10%;
/* 窗口10分之一,响应式的时候会用 */
width: 10vh;
/* 相对于root字体,字体如果是16px,那么这里就是 16*2.2 像素 */
width: 2.2rem
width: auto;

/* 替代下面 */
width: xxx px;
```

### position 定位

- `static` 代表不会被特殊定位
- `fixed` 固定定位，定位到右下角

    ```css
    .fixed {
      position: fixed;
      /* 右下角定位 */
      bottom: 0;
      right: 0;
      width: 200px;
      background-color: white;
    }
    ```

- `relative` 相对定位，相对上一个 div 元素位置

    ```css
    .relative2 {
      position: relative;
      top: -20px; /* 向上移动20px */
      left: 20px; /* 左边隔开20px */
      background-color: white;
      width: 500px;
    }
    ```

- `absolute` 绝对定位，最近的父元素 `position` 不是 `static` ，那么根据这个元素来定位. 否则根据 `body` 定位

> [参考资料](https://zh.learnlayout.com/position)

### 元素选择器

- `#id` id 选择器
- `.class` 类选择器
- 关系选择器 : `div p` dev 后代, `div>p` div 的子代, `div,p`
- 伪类 : `a:link` 可以控制行为: 你点击 a 标签之前蓝色, 点击之后紫色.

### margin 外边距

- `marigin: 5%` 上下左右都是 5%
- `margin: 1 2 3 4;` 上 1，右 2，下 3，左 4
- `margin: 0 auto;` 上下 0，左右自动居中

### 样式美化

- 行高 `line-height`
- 字体属性 `font-size`
- 背景颜色 `background`
- 颜色 `color`
- 圆角边框 `border-radius: 1em;`
- 阴影 `text-shadow`, `box-shadow`，[93 Beautiful CSS box-shadow examples - CSS Scan](https://getcssscan.com/css-box-shadow-examples)

### css 互相引用

- `@import './base.css';`

### float 浮动

在一个段落的里面，插入一个图片，[效果参考](https://zh.learnlayout.com/float)

```css
img {
  float: right;
  margin: 0 0 1em 1em;
}
```

#### clear 控制 float 浮动

`clear` 属性被用于控制浮动。

- 当 box 浮动了，后面的元素会跑到 box 这里来

    ```css
    .box {
      float: left;
      width: 200px;
      height: 100px;
      margin: 1em;
    }
    ```

- 而把 clear 样式加到后面的元素上，可以避免这个问题

    ```css
    .after-box {
      clear: left;
    }
    ```

> [浮动图例](https://zh.learnlayout.com/clear)

#### 宽度不够自动下移

宽度不够, 自动移动到下方. 避免水平滚动条

```css
.main {
    float: right;
    width: 70%;
}

.leftBar {
    float: left;
    width: 25%;
}
```

## 实际运用

### 居中

#### 定位 +transform 计算

- 定位: 使用 `absolute` 绝对定位 (相对于父元素定位). `top` 和 `left` 距离上面和左边 50%
- 计算:  `translate` 被向左和向上移动了自身宽度和高度的一半
- `.app` 不写宽度的话, 就会使用 `content` 这个字符串的宽度

```vue
<template>
    <div class="layout">
        <p>定位 +transform 计算</p>
        <div class="box1">
            <div class="content1">content</div>
        </div>
    </div>
</template>

<style scoped>
.box1 {
    position: relative;
    width: 10rem;
    height: 10rem;
    background-color: skyblue;
}

.content1 {
    background-color: greenyellow;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
</style>
```

#### flex 布局

```html
<template>
    <div class="layout">
        <p>flex</p>
        <div class="box2">
            <div class="content2">content</div>
        </div>
    </div>
</template>

<style scoped>
.box2 {
    width: 10rem;
    height: 10rem;
    background-color: skyblue;
    display: flex;
    /* 水平居中 */
    align-items: center;
    /* 垂直居中 */
    justify-content: center;
}

.content2 {
    background-color: greenyellow;
}
</style>
```

容器内的元素会使用下面默认参数排列：

- 默认 `flex-direction: row` 从左到右
- 默认 `flex-wrap: nowrap` 不换行. 可以设置成 `warp` 换行
- 可以设置 `gap: 1rem;` 换行以后间隔一些元素
- 默认 `justify-content: flex-start` 水平左对齐.
- 默认 `align-items: flex-start` 垂直顶部对齐、


> [Flex 布局教程：语法篇 - 阮一峰的网络日志](https://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)

#### margin + text-align 垂直居中

```html
<template>
    <div class="layout">
        <p>定宽垂直居中</p>
        <div class="box3">
            <div class="content3">content</div>
        </div>
    </div>
</template>

<style scoped>
.box3 {
    width: 10rem;
    height: 10rem;
    background-color: skyblue;
}

.content3 {
    background-color: greenyellow;
    /* 自己必须要有宽度 */
    width: 5rem;
    /* content3这个div居中 */
    margin: 0 auto;
    /* 让里面的文字也居中 */
    text-align: center;
}
</style>
```

#### 总结

行内元素水平居中. 行内元素

- 行内元素可设置：`text-align: center`
- flex 布局设置父元素：`display: flex; justify-content: center`

块级元素水平居中

- 自己有确定的宽度时, 才能用: `margin: 0 auto;`
- 绝对定位 +left:50%+margin: 负自身一半

块级元素垂直居中

- `position: absolute` 设置 left、top、margin-left、margin-top (定高)
- `transform: translate (x, y)`
- `flex` (不定高，不定宽)

`table` 等等方式都不常用, 或者说不推荐使用. 所以我就不写了.

可以参考 [面试官：元素水平垂直居中的方法有哪些？如果元素不定宽高呢？ · Issue #102 · febobo/web-interview · GitHub](https://github.com/febobo/web-interview/issues/102)
