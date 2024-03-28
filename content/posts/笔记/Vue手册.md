---
title: Vue手册
tags:
  - blog
  - vue
  - 前端
date: 2024-03-09
lastmod: 2024-03-26
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
import { useRouter } from "vue-router"
const router = useRouter()
// 这里的push可以传递RouterLink里的 to 值
router.push('/url1')
```

### 全局传递/状态管理 pinia

定义一个 store

```ts
import { defineStore } from 'pinia'
import axios from 'axios'
import { computed, ref } from 'vue'

export const useDogStore = defineStore('dog', {
  state() {
    return {
      urls: [
        'https://images.dog.ceo/breeds/pekinese/n02086079_10613.jpg',
        'https://images.dog.ceo/breeds/cockapoo/bubbles1.jpg'
      ]
    }
  },
  // 用于把state计算一下,字符串拼接一下来用
  getters: {
    doubleUrls(state) {
      return state.urls.concat(state.urls)
    },
    doubleUrls2: (state) => state.urls.concat(state.urls),
    doubleUrls3(): Array<string> {
      return this.urls.concat(this.urls)
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

// 组合式
// ref() 就是 state 属性
// computed() 就是 getters
// function() 就是 actions
export const useDog2Store = defineStore('dog', () => {
  let urls = ref([
    'https://images.dog.ceo/breeds/pekinese/n02086079_10613.jpg',
    'https://images.dog.ceo/breeds/cockapoo/bubbles1.jpg'
  ])

  const doubleUrls = computed(() => urls.value.concat(urls.value))
  const doubleUrls2 = computed(() => urls.value.concat(urls.value))
  const doubleUrls3 = computed(() => urls.value.concat(urls.value))

  async function addDog2() {
    const {
      data: { message }
    } = await axios.get('https://dog.ceo/api/breeds/image/random')
    urls.value.push(message)
  }

  return { urls, doubleUrls, doubleUrls2, doubleUrls3, addDog2 }
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

###  信息传递

#### defineProps/父与子

- 父传子 `使用props`.
- 子传父 1: `父传子一个函数,子接收并带上参数来调用函数`

```ts
// 父
<子组件 :dataA="dataA" @click="fangfa">
function fangfa(value:number){
  consolo.log(value)
}

// 子
// 接收特定key,例如字符串 <子组件 a="a" b="b">
defineProps(['dataA','fangfa'])
fangfa(1)
// 接收父组件的Person对象
defineProps<dataA:Person>()
// 可以不传 
defineProps<dataA?:Person>()
// 默认值
withDefaults(defineProps<dataA?:Person>(),{
    dataA: ()=> [{id: 1,name: "ken",age: 1}]
})
```

#### emit 自定义事件/子传父

只能子传父 2:

- 自定义一个函数名 haha, 传入一个函数
- 子组件接收特定名称, 然后 emit 传回去

```ts
// 父
<子组件 @haha="fangfa">
function fangfa(value:number){
  consolo.log(value)
}

// 子
<button @click="emit('haha',a)"></button>
var a = ref(1)
const emit = defineEmits(['haha'])
```

#### mitt 事件订阅传递/任意组件

```ts
import mitt from 'mitt'
const emitter = mitt()

// 监听
emitter.on('foo', e => console.log('foo', e) )
// 触发
emitter.emit('foo', { a: 'b' })
// 去掉所有事件
emitter.all.clear()

unMounted(()=>{
  // 销毁的时候去掉这个
  emitter.off('foo')
})
```

#### v-model 底层原理/父与子

关于 `$event`

- 如果是原始 html 对象, 例如 input . 那么 `$event` 就是 dom 元素, 需要去 `target.value` 获取值
- 如果是自己定义的事情或对象, 那么 `$event` 就是你传递的对象

```ts
// 父
// <A-Input v-model="aa"/> 其实是下面的简写
<A-Input :modelValue="username" @update:modelValue="username = $event"></A-Input>
let username = ref('ken')

// 子
<input type="text" :value="modelValue" @input="emit('update:modelValue',(<HTMLInput>)$event.target.value)">
// 接收传入的值
defineProps(['modelValue'])
// 接受传递的事件
const emit = defineEmits(['update:modelValue'])
```

#### $attr 父传子

父传子的时候, 如果子没有使用 `defineProps` 接收. 就会到子组件的 `$attr` 里.

常见于把用户的配置通过 `attrs` 传递到下层组件. 所以常见场景是: 二次封装组件

```ts
// 父
// {c:1,d:2} 等于 :c="1" :d="2"
<child :a="a" :b="func" v-bind="{c:1,d:2}">

// 子 原封不动传递一下
<sun v-bind:"$attr">

// 孙 直接可以接收到
defineProps(["a","func"])
```

#### $refs 父传子 && $parent 子传父

```ts
// 父 给子一个ref
<child ref="z">
// 拿到子
let z = ref()
// 子暴露的都可以拿到
z.value.a = 2
// 自己的数据,也暴露出去
let q = ref(1)
defineExpose({q})

// 子 暴露出去a
a = ref(1)
defineExpose({a})
// 通过$parent拿到父暴露的q
console.log($parent.q)
```

#### provide/inject 祖传

祖辈向下一代传递

```ts
// 祖先
let qian = ref(1)
provide('money',qian)
// 复杂的对象
provide('money',{qian,func})

// 子
let q = inject('money',5) // 默认值5,顺便用来做类型推断
// 复杂的对象
let {qian,func} = inject('money',{q:5,f:()=>{}})  
```

###  for 循环

- 循环遍历数组 `(person, index) in Persons`
- 循环遍历对象 `v-for="(value, key, index) in object"`

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

### slot 插槽

假设一个页面, 有一个热门推荐窗口.

- 推荐图片
- 推荐视频
- 推荐文字

那么用 `slot` 就可以传递不同的元素.

```html
// 父
<h3>今日推荐</h3>
<child>
<img src="xxx">
</child>

// 子
<template>
<slot>默认没有内容</slot>
</template>
```

`具名插槽` 给插槽一个名字, 对应插入内容.

```html
<!-- ParentComponent.vue -->
<template>
  <ChildComponent>
    <template v-slot:header>
      <h2>这是标题</h2>
    </template>
    <template v-slot:footer>
      <p>这是页脚</p>
    </template>
  </ChildComponent>
</template>

<!-- ChildComponent.vue -->
<template>
  <div>
    <header>
      <slot name="header"></slot>
    </header>
    <main>
      <slot></slot>
    </main>
    <footer>
      <slot name="footer"></slot>
    </footer>
  </div>
</template>
```

`作用域插槽`: 子组件有数据 `q={a:1}`. 而父组件需要定义如何展示. 就会用到 `q.a`. 就需要作用域插槽解决这个问题.

常见于 ui 组件库.

- 你在编写一个 ui 组件库的 table 组件, 有一个配套的搜索栏.
- 这时候父组件就需要传入搜索的字段, 配置这个搜索框的样式.
- 而可以使用哪些字段来搜索, 是 table 组件控制的.
- 所以 table 子组件把可以用的字段通过 `slot` 传递给父组件.

### lifetime 生命周期

- `setup` 创建阶段
- `onBeforeMounted`, `onMounted` 挂载阶段
- `onBeforeUpdated`, `onUpdated` 更新阶段
- `onBeforeUpdated`, `onUnmounted` 卸载阶段

```ts
onMounted(()=>{
    console.log(1)
})
```

### 其他

- `shallowref({a:1,b:{c:2}})`: 包裹对象的第一层 `a` 响应式. 下级 `b` 不监测. 性能更好
- `readonly({a:1,b:2})` 无法修改
- `const rawObj = toRaw(reactiveObj)` 拿到 `reactive` 包装前的原对象.
- `const nonReactiveObj = markRaw(copiedObj)` 相当于深拷贝一个新对象出来.
- `teleport` 让一个组件渲染到不同的 dom 位置 (例如相对于 body 元素, 而不是当前位置)
- `suspense` 自定义一个 loading 或加载失败时展示内容. 是占位符 + 加载状态展示
- `customRef` 是 Vue 3 中的一个函数，用于创建一个自定义的 ref 对象。通过 `customRef`，你可以定义一个自定义的 getter 和 setter 函数来管理 ref 对象的值，并且可以手动控制依赖追踪和触发更新。这使得你可以更灵活地处理一些复杂的情况，例如惰性计算、异步更新等。

```js
import { customRef } from 'vue';

function customComputedRef(getter, setter) {
  let value = getter();
  return customRef((track, trigger) => {
    return {
      get() {
        track(); // 手动追踪依赖
        return value;
      },
      set(newValue) {
        setter(newValue);
        value = newValue;
        trigger(); // 手动触发更新
      }
    };
  });
}

const myCustomRef = customComputedRef(
  () => {
    console.log('getter executed');
    return 1;
  },
  (v) => {
    console.log('setter executed', v);
  }
);

console.log(myCustomRef.value); // 输出: "getter executed", 1

myCustomRef.value = 2; // 输出: "setter executed", 2
console.log(myCustomRef.value); // 输出: "getter executed", 2

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
