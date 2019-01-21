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

20190122
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
  }
```