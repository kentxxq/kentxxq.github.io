---
title:  webpack配置学习
date:   2018-01-03 16:44:00 +0800
categories: ["笔记"]
tags: ["vue"]
---


> 刚刚开始学习vue，把基础的用法学过了一遍。现在开始使用vue-cli搭建项目，以及使用了解相关router，vuex和webpack
> 这一篇内容是用来简单记录webpack的配置

```bash
#安装node，vue-cli
brew install node 
#修改为淘宝源
npm config set registry http://registry.npm.taobao.org/
#安装vue-cli
npm install vue-cli -g
```

生成项目
===

```bash
vue-cli init myapp
#选择一些基础信息，就自动下载生成了数据
```

vue-cli生成项目后深入了解
===

```bash
#在构建完成以后，查看整体文件大小 --report
run npm build --report

#目录下的.babelrc文件
#1. presets预设置中 env的作用不再需要安装es20xx presets了,更加方便
#2. 启用将ES6模块语法转换为另一种模块类型，默认是commonjs
#3. 这部分是编译后的运行环境，比如有node和browsers
#   我的运行浏览器市场份额>1%,支持其中的最后两个版本,必须要高于ie8
#4. 完成初步规范的是stage-2,变动不大且后续浏览器即将提供支持
#5. transform-vue-jsx插件支持转换 用vue写的jsx
#6. babel-runtime帮助babel复用一些函数用来转换,有效减少文件体积
{
  "presets": [
    ["env", {
      "modules": false,
      "targets": {
        "browsers": ["> 1%", "last 2 versions", "not ie <= 8"]
      }
    }],
    "stage-2"
  ],
  "plugins": ["transform-vue-jsx", "transform-runtime"]
}
```
