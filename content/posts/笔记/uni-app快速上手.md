---
title: uni-app快速上手
tags:
  - blog
  - 前端
date: 2024-01-20
lastmod: 2025-04-17
categories:
  - blog
description: 
---

## 简介

记录 uni-app 的快速上手

## 工具

### 命令

- 创建项目 `npx degit dcloudio/uni-preset-vue#vite-ts my-vue3-project`
- 安装依赖 `pnpm i`
- 运行 `pnpm dev:h5` 即可看到 `h5` 页面
- 如果是运行 `pnpm dev:mp-weixin`，会生成 `dist/dev/mp-weixin` 文件夹. 在微信开发者工具导入这个目录, 就可以在微信开发者工具实时预览改动了
- `npx @dcloudio/uvm@latest` 更新依赖到最新版本

### vscode

vscode 插件

- `uni-create-view` 帮助创建页面
- `uni-helper的组件包` 帮助代码提示
- `uniapp小程序拓展` 帮助悬停查看文档

### 类型提示

安装类型 `pnpm i -D @types/wechat-miniprogram @uni-helper/uni-types`

配置 `tsconfig.json`。确保使用了 ts 类型，配置了 `vueCompilerOptions` 的 `plugins`

```json
{
  {
    "types": ["@dcloudio/types","@types/wechat-miniprogram","@uni-helper/uni-types"]
  },
  "vueCompilerOptions": {
    "plugins": ["@uni-helper/uni-types/volar-plugin"]
  }
}
```

## 代码

### 结构

- `manifest.json` 存放 appid，应用名称，版本
- `pages.json`
    - 注册页面
    - 全局样式
    - tabbar 底部
- `pages` 存放页面
- `static` 存放静态资源

### 开发配置

#### UI 配置组件

安装 uni-ui：

- `pnpm i @dcloudio/uni-ui`
- 安装 sass `pnpm i sass -D`
- 项目根路径添加 `vue.config.js`

```js
// vue.config.js
module.exports = {
    transpileDependencies:['@dcloudio/uni-ui']
}
```

配置组件自动引入

```json
// pages.json
{
  "easycom": {
  "autoscan": true,
   "custom": {
      // uni-ui 规则如下配置
      "^uni-(.*)": "@dcloudio/uni-ui/lib/uni-$1/uni-$1.vue"
    }
  },
  "pages": [
     // …
  ]
}
```

>  如果无法正常展示组件, 重启微信开发者工具

#### tailwindcss

- 使用 tailwind 的 css 会发现无法覆盖 uniapp 自己的样式, 例如 `uni-view` 的 `display:block`, [参考这里](https://ice-tw.netlify.app/docs/quick-start/v4)
- [weapp-tailwindcss配置](https://ice-tw.netlify.app/docs/quick-start/v4/uni-app-vite)

#### 状态管理/持久化存储

安装依赖

```shell
pnpm add pinia pinia-plugin-persistedstate
```

创建 `src/stores/index.ts`

```ts
import { createPinia } from "pinia";
import persist from "pinia-plugin-persistedstate";

// 创建 pinia 实例
const pinia = createPinia();
// 使用持久化存储插件
pinia.use(persist);

// 默认导出，给 main.ts 使用
export default pinia;

// 模块统一导出
export * from "./modules/user";
```

创建 `src/stores/modules/user.ts`, 保存用户信息的示例

```ts
import { defineStore } from "pinia";
import { ref } from "vue";

interface User {
  username: string;
  role: string;
}

// 定义 Store
export const userStore = defineStore(
  "user",
  () => {
    // 用户信息
    const user = ref<User>();

    // 保存用户信息
    const setProfile = (val: User) => {
      user.value = val;
    };

    // 清理用户信息，退出时使用
    const clearProfile = () => {
      user.value = undefined;
    };

    // 记得 return
    return {
      user,
      setProfile,
      clearProfile,
    };
  },
  // 持久化
  {
    persist: {
      // 默认是localStorage，改成uni来兼容多端
      storage: {
        setItem(key, value) {
          uni.setStorageSync(key, value);
        },
        getItem(key) {
          return uni.getStorageSync(key);
        },
      },
    },
  }
);
```

`main.ts` 中引入使用 `app.use(pinia);`

## 资料

### 安全边距

```ts
// 拿到安全区域距离，单位是px
// 比如自定义导航栏。在拿到top以后，给导航加上样式 :style="{ paddingTop: safeAreaInsets?.top + 'px' }"
const { safeAreaInsets } = uni.getSystemInfoSync()
console.log(safeAreaInsets)
```

### rpx 单位

- [uniapp的rpx文档](https://zh.uniapp.dcloud.io/tutorial/syntax-css.html#flex-%E5%B8%83%E5%B1%80)
    - 假定所有的屏幕都是 750 宽度, 所以 1rpx 就是 750/100 的宽度
    - 所以屏幕越大, 像素越大. div 应该用 rpx, 字体应该用 px

### uni-app  

```shell
# 项目模板代码  
git clone -b template https://gitee.com/heima-fe/uniapp-shop-vue3-ts.git heima-shop  
# 项目成品代码  
git clone https://gitee.com/Megasu/uniapp-shop-vue3-ts.git
```
