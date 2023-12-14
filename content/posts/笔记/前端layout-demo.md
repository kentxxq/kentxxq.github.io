---
title: 前端layout-demo
tags:
  - blog
  - 前端
date: 2023-11-11
lastmod: 2023-12-09
categories:
  - blog
description: "`layout-demo` 是一个练习布局, 样式, 动画等内容的项目. "
---

## 简介

`layout-demo` 是一个练习布局, 样式, 动画等内容的项目.

## 语法

### 元素类型

- 块级元素：
    - 独占一行
    - `div`，`p`，`h1`, `ul`, `ol`, `li`, `table`, `form`
- 内联元素：
    - 不影响段落
    - `a`

### display 布局展现形式

- `display:block` 是一个块级元素。开始新的一行，撑满容器。例如 `p`，`form`，`header`，`footer`
- `display:inline` 是行内元素。包裹内容但不打乱布局。`a` 就是一个行内元素，用来展示链接
- `display:none` 不删除元素的情况下隐藏，不会占用空间。`visibility:hidden` 会占用空间
- `display:flex` 用于指定自己内部元素布局，参考 [[笔记/前端layout-demo#flex 布局|flex 布局]]

案例：

- 每个元素都有默认的 display，常见的改动就是 `li` 元素改成 `inline`，制作水平菜单
- 一个 div 容器内有 2 个 div，左边 20%，右边 80%。需要 `display: flex` 来让它排列

### 盒子模型

#### margin 外边距

- `marigin: 5%` 上下左右都是 5%
- `margin: 1 2 3 4;` 上 1，右 2，下 3，左 4
- `margin: 0 auto;` 上下 0，左右自动居中

### position 定位

- `static` 代表不会被特殊定位
- `relative` 相对定位，相对上一个 div 元素的位置

    ```css
    .relative2 {
      position: relative;
      top: -20px; /* 向上移动20px */
      left: 20px; /* 左边隔开20px */
      background-color: white;
      width: 500px;
    }
    ```

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

- `absolute` 绝对定位，最近的父元素不为 `static` ，那么根据这个元素来定位

> [参考资料](https://zh.learnlayout.com/position)

### flex 布局

容器内的元素会使用下面默认参数排列：

- 默认 `flex-direction: row` 从左到右
- 默认 `flex-wrap: nowrap` 不换行
- 默认 `justify-content: flex-start` 水平左对齐
- 默认 `align-items: flex-start` 垂直顶部对齐、

> [Flex 布局教程：语法篇 - 阮一峰的网络日志](https://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)

### float 浮动

在一个段落的里面，插入一个图片，[效果参考](https://zh.learnlayout.com/float)

```css
img {
  float: right;
  margin: 0 0 1em 1em;
}
```

### 不常用

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

## 常用内容

### 选择器

- `#id` id 选择器
- `.class` 类选择器
- `div p`, `div>p`, `div,p` 关系选择器

### 常用属性

- 行高 `line-height`
- 字体属性 `font-size`
- 背景颜色 `background`
- 颜色 `color`
- 圆角边框 `border-radius: 1em;`
- 阴影 `text-shadow`, `box-shadow`，[93 Beautiful CSS box-shadow examples - CSS Scan](https://getcssscan.com/css-box-shadow-examples)

## 问题处理

### meta 自动调整宽度

参考默认 `vue` 模板网页 `header` 加入

```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### 宽度

#### width 宽度单位

```css
width: xx%;
width: auto;

/* 替代下面 */
width: xxx px;
```

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

### box 模型宽度不一致

很多开发者这样设置，就可以一样宽度了

```css
* {
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
}
```

如果不设置，下面这两个 box 会不一样大

```css
.simple {
  width: 500px;
  margin: 20px auto;
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
}

.fancy {
  width: 500px;
  margin: 20px auto;
  padding: 50px;
  border: solid blue 10px;
  -webkit-box-sizing: border-box;
     -moz-box-sizing: border-box;
          box-sizing: border-box;
}
```

### css 互相引用

- `@import './base.css';`
