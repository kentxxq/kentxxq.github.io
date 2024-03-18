---
title: Vue手册
tags:
  - blog
  - vue
  - 前端
date: 2024-03-09
lastmod: 2024-03-18
categories:
  - blog
description: 
---

## 简介

个人学习 [[笔记/point/Vue|Vue]] 的手册.

开始前, 应该先搞定 [[笔记/前端迅速上手|前端迅速上手]] 里的 [[笔记/前端迅速上手#VUE 官网版本|vue项目创建]] 和 [[笔记/前端迅速上手#Vscode|vscode配置]],

## 语法/概念

### 定义对象 Person

```ts
export interface Person {
  id: number
  name: string
  age: number
  x?: string
}

type Persons = Array<Person>
```

### 路由 router

#### 路由配置

`router.ts` 文件内容

```ts
import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '@/views/HomeView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'root',
      // 重定向到 /home
      redirect: '/home'
    },
    {
      path: '/home',
      name: 'home',
      component: HomeView
    },
    {
      path: '/about',
      name: 'about',
      // 懒加载
      component: () => import('../views/AboutView.vue')
    }
  ]
})

export default router
```

子路径嵌套

```json
    // 子路径
    {
      path: '/home2',
      name: 'home2',
      component: HomeView,
      children: [
        {
          name: 'p1'
          path: 'p1',
          component: Detail
        }
      ]
    },
```

路由参数. 在路径 url 里传递参数.

- `title?` 说明 title 可以不传
- routerlink 写法为 `:to="{name: 'p1', params:{id: 1, title:2}}"`

```json
    {
      path: '/home2',
      name: 'home2',
      component: HomeView,
      children: [
        {
          name: 'p1'
          // 传递参数
          path: 'p1/:id/:title?',
          component: Detail
        }
      ]
    },
```

`props` 是配合上面路由参数使用的. 原因是有时候只配置了路由, 无法使用 `<Component a="1">` 传参

```ts
// 通过query传参的函数写法
props(route){
  return route.query
  // 返回params不如用属性 props: true
  // return route.params 
}

// 属性写法. 只能用来替代函数写法的 return route.params
props: true

// 对象写法
props: {
  id:1
  title:2
}

// 接收方
// defineProps(['id','title'])
```

#### 链接

```html
<!-- 传字符串 -->
<RouterLink replace :to="url" active-class="active-link">{{ index }}-{{ url }}</RouterLink>

<!-- 传对象 -->
<RouterLink :to="{name: 'name', query:{a:1,b:2}}" active-class="active-link">{{ index }}-{{ url }}</RouterLink>
```

- 可以传递 url, 其实就是 path 路径
- 传递对象的话, 可以写 router 里面的 name, 用 query 传递 url 参数
- `replace` 属性, 使用户无法使用浏览器的返回按钮去到上一个页面

css 内容

```css
.active-link {
  background-color: skyblue;
}
```

#### 编程路由

```ts
const router = useRouter()
// 这里的push可以传递RouterLink里的 to 值
router.push('/url1')
```

### 状态管理 pinia

定义一个 store

```ts
import { defineStore } from 'pinia'
import axios from 'axios'

export const useDogStore = defineStore('dog', {
  state() {
    return {
      urls: [
        'https://images.dog.ceo/breeds/pekinese/n02086079_10613.jpg',
        'https://images.dog.ceo/breeds/cockapoo/bubbles1.jpg'
      ]
    }
  },
  actions: {
    async addDog() {
      const {
        data: { message }
      } = await axios.get('https://dog.ceo/api/breeds/image/random')
      this.urls.push(message)
    }
  }
})

```

读取

```ts
const dogStore = useDogStore()
// store的解构用storeToRefs, storeToRefs只会处理数据,而不会处理store里的函数
const {urls} = storeToRefs(dogStore)

<img v-for="url in dogStore.urls" :key="url" :src="url" mode="scaleToFill" />
```

修改

```ts
// 1 直接修改
dogStore.urls = ['1','2']

// 2 patch方式修改对象,一次提交多个修改
counterStore.$patch({
  urls: ['1','2']
  b: 4
})

// 3 就是在store定义里, 用actions修改
```

订阅

```ts
// 订阅
// mutate里有id和事件.没什么用.
// state则可以拿到数据
counterStore.$subscribe((mutate, state) => {
  // 一旦数据发生了变化,就存起来
  localStorage.setItem('counter', JSON.stringify(state.count))
})
```

###  for 循环

- 循环遍历数组 `(person, index) in Persons`
- 循环遍历对象 `v-for="(value, key, index) in object"`

### defineProps 接收参数

```ts
<子组件 :dataA="dataA">

// 接收特定key,例如字符串 <子组件 a="a" b="b">
defineProps(['a','b'])

// 接收父组件的Person对象
defineProps<dataA:Person>()
// 可以不传 
defineProps<dataA?:Person>()
// 默认值
withDefaults(defineProps<dataA?:Person>(),{
    dataA: ()=> [{id: 1,name: "ken",age: 1}]
})
```

### computed 计算

`computed`

- 肯定有返回值
- 依赖项不变, 就可以用缓存. 性能好
- 不能异步.
- 场景: 购物车结算, 字符串拼接

```ts
let price = ref(0)//$0 

let p = computed<string>(()=>{ return `$` + price.value })
```

### watch 变化

`watch`

- 返回值是停止自己
- 每次都重新执行整体
- 可以异步
- 场景: 搜索框匹配内容, 做一些计算内容的限制

```ts
const stopWatch = watch(sum, (newValue, oldValue) => {
  console.log('sum变化了', newValue, oldValue)
  if (newValue >= 10) {
    // 停止
    stopWatch()
  }
}, { immediate: false, deep: false })
```

### 生命周期

- `setup` 创建阶段
- `onBeforeMounted`, `onMounted` 挂载阶段
- `onBeforeUpdated`, `onUpdated` 更新阶段
- `onBeforeUpdated`, `onUnmounted` 卸载阶段

```ts
onMounted(()=>{
    console.log(1)
})
```

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
