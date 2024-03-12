---
title: Vue手册
tags:
  - blog
date: 2024-03-09
lastmod: 2024-03-09
categories:
  - blog
description: 
---

## 简介

个人学习 [[笔记/point/Vue|Vue]] 的手册.

## 工具

### vite

#### 自定义组件名

**现在** 可以这样指定名字

```ts
defineOptions({
  name: 'Foo',
  // ... 更多自定义属性
})
```

**以前**写 vue 的时候组件名会是文件名. 无法配置组件名称, 可以使用 `vite-plugin-vue-setup-extend`.

```ts
import vueSetupExtend from 'vite-plugin-vue-setup-extend'

export default defineConfig({
  plugins: [
    vue(),
    vueSetupExtend() // 加入
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  }
})
```

于是我们就可以像 xml 一样写 name 的值

```ts
<script setup lang="ts" name="自定义组件明">
defineProps<{
  msg: string
}>()
</script>
```
