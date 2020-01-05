---
title:  复习vue的重点要记
date:   2019-01-17 21:15:00 +0800
categories: ["笔记"]
tags: ["vue"]
keywords: ["vue","重点要记"]
description: "复习vue的重点要记"
---

vue备忘录

### 常用
```html
v-model
v-text
v-for
v-show
:key
@click
```

获取dom元素:`this.$ref`



获取当前元素:`this.$el`



vm渲染完后执行:`this.$nextTick(()=>{})`



vm上的数据:`this.$vm`



在子组件上触发父组件给自己创建的事件:    
父组件先定义好对应的方法    
`methods:{things(val){this.money = val;}}`    
这里先把money穿给子组件，然后绑定事件和对应的方法     
`<child :m="money" @child-msg="things"></child>`    
子组件触发父组件的方法，并且传递参数。    
`this.$emit('child-msg',800);`    
或者：     
`<child :m.sync="money"></child>`  
`this.$emit('update:m',800);`  
```js
子组件(带参数)=>触发父组件的函数标签=>执行父组件绑定好的method
```
