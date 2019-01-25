---
title:  用vue搭建web
date:   2019-01-21 20:23:00 +0800
categories: ["笔记"]
tags: ["vue"]
---


> 刚刚开始学习vue，把基础的用法学过了一遍。现在开始使用vue-cli搭建项目，以及使用了解相关router，vuex和webpack等等。

安装开发环境
---
```bash
#安装node，vue-cli
brew install node 
#修改为淘宝源
npm config set registry http://registry.npm.taobao.org/
#安装vue-cli
npm install -g @vue/cli
```

vue-cli来初始化项目
---

```bash
vue create wechat_web
#选择一些基础信息，就自动生成了项目

#在构建完成以后，查看整体文件大小 --report
npm run build --report

#直接构建出来项目
npm run build

#开发的时候运行项目，实时自动reload
npm run serve
```

安装ui库
---
`pc端使用element-ui`     
`mobile端使用vant`      
```bash
#进入项目的ui管理界面
vue ui
# 1.点击依赖
# 2.搜索安装vant
# 3.安装插件，方便自动生成按需引用，减少js体积
npm i babel-plugin-import -D
```
`babel.config.js中配置`:
```json
module.exports = {
  plugins: [
    ['import', {
      libraryName: 'vant',
      libraryDirectory: 'es',
      style: true
    }, 'vant']
  ]
};
```
`引用+使用`
```html
<template>
  <div class="about">
    <van-row>
      <van-col span="8">span: 8</van-col>
      <van-col span="8">span: 8</van-col>
      <van-col span="8">span: 8</van-col>
      <van-col span="8">span: 8</van-col>
    </van-row>
  </div>
</template>

<script>
import { Row, Col } from "vant";
// import "vant/lib/button/style";

export default {
  components: {
    [Row.name]: Row,
    [Col.name]: Col
  }
};
</script>
```

20190122 00:00
===

关于pwa
---
> 看了很久的vue-pwa部分。记录一下吧。其实我对pwa的要求没那么高，毕竟不是一个离线应用。但是想要搞懂它。因为发现很多网站其实都用了这个技术，比如淘宝/bet365/twitter之类的。所以以后应该会常用到。

`workbox`的[具体配置信息](https://developers.google.com/web/tools/workbox/modules/workbox-webpack-plugin)    
`vue-pwa`的[具体配置信息以及源代码](https://github.com/vuejs/vue-cli/blob/dev/packages/%40vue/cli-plugin-pwa/README.md)      
改动后的`vue.config.js`如下:
```json
pwa: {
    name: 'kentxxq',
    // 由于谷歌国内不稳定，所以改成local
    workboxOptions: {
      importWorkboxFrom: 'local'
    }
    // 下面这是默认排除掉的文件类型
    //const defaultOptions = {
    //    exclude: [
    //      /\.map$/,
    //      /img\/icons\//,
    //      /favicon\.ico$/,
    //      /manifest\.json$/
    //    ]
    //  }
    // 其实最重要的是下面这两个，自己按需求定制
    // include: [/\.html$/, /\.js$/]
    // exclude: [/\.jpg$/, /\.png$/]
    // 下面是具体资源的配置选项，用的时候最好参考官方文档
    //runtimeCaching: [
    //    {      // To match cross-origin requests, use a RegExp that matches
    //        // the start of the origin:
    //        urlPattern: new RegExp('^https://api'), handler: 'staleWhileRevalidate', options: {   //     // Configure which responses are considered cacheable.
    //            cacheableResponse: {
    //                statuses: [200]
    //            }
    //        }
    //    },
  }
```
关于修改主题
---
关于安卓上的启动动画background_color和图片icon之类自己手动再替换一下吧，我改了好久好久都没成功。。

20190123 01:20
===
加上了一个轮播图，轮播图的关键是`图片的大小比例要合适`，免得在各个机器上很麻烦的适配   
关于首页，推荐使用`redirect`跳转
```javascript
export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/home',
      name: 'home',
      component: () => import('./views/Home.vue')
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (about.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import(/* webpackChunkName: "about" */ './views/About.vue')
    },
    {
      path: '/',
      redirect: '/home'
    }
  ]
})

```

20190126 00:04
===
关于前端页面的存放
---
我现在是把主页的轮播图放到了vue项目里，但是后续的话。肯定是要存在服务器，然后通过ajax来获取路径，刷新页面的。  
这就关系到了不少地方:  
1. 前后端的接口要通过yapi来拟定好
2. 数据库的设计必须要做出来了
3. 图片的存储，还是应该要定时清理的。  
用户头像应该直接替换。  
商品图片如果没有在购物车/历史记录/现有上架商品里，就可以删除。  
页面使用的图片(比如轮播图)，通过手动来替换就好了  


todo
===
1. 首页的pwa加载以后，需要点一下，才会出来轮播图的图片。这个后面搞，先会走，再会跑。
2. 后续部署vue的dist代码，需要修改manifest.json
3. 测试打包以后的性能，进行性能优化。当前的serve模式下面，无法准确得到性能状态
