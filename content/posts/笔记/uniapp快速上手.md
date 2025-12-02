---
title: uniapp快速上手
tags:
  - blog
  - 前端
date: 2024-01-20
lastmod: 2025-12-01
categories:
  - blog
description: 
---

## 简介

记录 uniapp 的快速上手

## 工具

### 命令

- 创建项目 `pnpm dlx degit dcloudio/uni-preset-vue#vite-ts my-vue3-project`
- 安装依赖 `pnpm i`
- 运行 `pnpm dev:h5` 即可看到 `h5` 页面
- 如果是运行 `pnpm dev:mp-weixin`，会生成 `dist/dev/mp-weixin` 文件夹. 在微信开发者工具导入这个目录, 就可以在微信开发者工具实时预览改动了
- `pnpm dlx @dcloudio/uvm@latest` 更新依赖到最新版本

### vscode

vscode 插件

- `uni-helper的组件包` 帮助代码提示
- `uniapp小程序拓展` 帮助悬停查看文档

### 类型提示

安装类型 `pnpm i -D @types/wechat-miniprogram @uni-helper/uni-types`

配置 `tsconfig.json`。确保使用了 ts 类型，配置了 `vueCompilerOptions` 的 `plugins`

```json
{
  "compilerOptions": {
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

### vite 插件

[@uni-helper/plugin-uni](https://github.com/uni-helper/plugin-uni)

- `plugin-uni-pages`，`plugin-uni-components` 的基础，自动注册组件，例如 `unocss`
- 需要在 `package.json` 添加 `"type": "module"`

[vite-plugin-uni-pages](https://uni-helper.js.org/vite-plugin-uni-pages/guide)

- 基于文件生成 `pages.json`
- 页面内部就可以配置相关展示的信息

[vite-plugin-uni-layouts - uni-helper](https://uni-helper.js.org/vite-plugin-uni-layouts)

- 统一布局，tabbar 页面不需要导航栏。其他页面统一导航栏

### 开发配置

#### 样式库

##### wot-ui

使用 wot-ui 原因如下

- 基础组件是 uniapp 自带的，例如 image, 所以主要是替换 uni-ui 部分的组件
- 基础组件的样式没有和 uni-ui 合并，所以 wot-ui 可以统一基础组件和拓展组件的颜色
- uni-ui 的组件都被 wot-ui 包含了，所以不会缺少什么组件
- UI 更好看。风格更统一，方便全局设置样式。api 更友好

安装方式参考 [快速上手 | Wot UI](https://wot-ui.cn/guide/quick-use.html) 即可，下面是注意事项

- `pnpm add sass@1.78.0 -D`

##### uni-ui 被 wot-ui 替代

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
  }
}
```

>  如果无法正常展示组件, 重启微信开发者工具

#### tsconfig 告警

关键字 `importsNotUsedAsValues`，`preserveValueImports`，`verbatimModuleSyntax`

1. 进入 `"extends": "@vue/tsconfig/tsconfig.json",`
2. 注释 `// "preserveValueImports": true,` 和 `// "importsNotUsedAsValues": "error",`
3. **20251017 此步骤可选** `compilerOptions` 内设置 `"verbatimModuleSyntax": false,`

#### 状态管理/持久化存储

安装依赖

```shell
# uniapp兼容版本
"pinia": "^2.3.1",
"pinia-plugin-persistedstate": "^3.2.3",

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

#### css 原子化

##### unocss

1. 相关项目
	- [unocss](https://github.com/unocss/unocss) css 原子化引擎，自定义转换 css 样式
	- [unocss-applet/unocss-applet: 在小程序中使用UnoCSS，兼容不支持的语法。](https://github.com/unocss-applet/unocss-applet) 为小程序做了兼容，支持 rpx，样式 reset，预设 tailwind
	- [uni-helper/unocss-preset-uni: 专为 uni-app 打造的 UnoCSS 预设](https://github.com/uni-helper/unocss-preset-uni) 基于 unocss-applet 做的封装，方便用户快速接入
	- [unibest-tech/unibest](https://github.com/unibest-tech/unibest) 是一个流行的 uniapp 模板，完整使用了上面组件。
2. 分析总结。都是非官方方案，更新和兼容性其实一般。所以直接通过参考 unibest 实现整合
3. 安装使用。2025 年 11 月 26 日
	1. `"@uni-helper/unocss-preset-uni": "0.2.11",`
	2. `"unocss": "66.0.0"`
	3. 配置 unocss 集成 [UnoCSS Vite Plugin](https://unocss.dev/integrations/vite)
	4. 参考 [unibest-tech/unibest](https://github.com/unibest-tech/unibest) 调整 `vite.config.ts`，`uno.config.ts`

##### unocss-icons

[unocss icons 安装文档](https://unocss.dev/presets/icons)

1. 安装 `pnpm add -D @iconify/json` 全量图标
2. `presetIcons` 已经包含在 `unocss` 中，直接 `uno.config.ts` 加入 `presetIcons({ /* options */ }),`

##### tailwindcss 被 unocss 替代

- [weapp-tailwindcss配置](https://ice-tw.netlify.app/docs/quick-start/v4/uni-app-vite)
	- uniapp 是 `750rpx` ，而这里的 tailwindcss 默认 `1rem = 16px = 32rpx`
	- `w-80` 等于 `640rpx`，等效 8 倍。总计宽度最多 `w-93.75`
	- 所以有 110 rpx 可以用作 padding。可以使用 `w-[750rpx]`, `px-[55rpx]` 。 或者 p-6/p-4, 然后设置内容居中
- 使用 tailwind 的 css 会发现无法覆盖 uniapp 自己的样式, 例如 `uni-view` 的 `display:block`, [参考这里](https://ice-tw.netlify.app/docs/quick-start/v4)

## 使用

### 表单

- 使用 form
- 多页表单其实就是 steps 组件展示进度，然后通过 if 判断展示不同阶段的表单内容

### 拦截/登录

#### 拦截

这里使用 `onShow`，因为 [uni.addInterceptor](https://uniapp.dcloud.net.cn/api/interceptor.html#addinterceptor) 无法拦截微信小程序底部点击 tabbar

```ts
const { isLogged } = storeToRefs(useAuthStore())
onShow(() => {
  console.log('登录状态', isLogged.value)
  if (!isLogged.value) {
    uni.showModal({
      title: '提示',
      content: '您需要登录才能查看此页面',
      cancelText: '返回首页',
      confirmText: '登录', // 不能超过 4 个字！否则微信端无法弹出
      success: function (res) {
        if (res.confirm) {
          uni.navigateTo({
            url: '/pages/login'
          })
        } else if (res.cancel) {
          uni.switchTab({ url: '/pages/home/index' })
        }
      }
    });
  }
})
```

#### 登录

1. `uni.login` 用户这里拿到 code
2. 发送给后端，后端拿到 openid/unionid 即可确认用户身份
3. 返回前端 token，前端登录成功

### 获取用户信息

1. 用户首先是完成登录，确认用户身份后再来修改用户信息
2. 通过设置 input 的 type 获取昵称，设置 button 的 open-type 获取头像的临时路径

- [官方文档 - 获取头像昵称](https://developers.weixin.qq.com/miniprogram/dev/framework/open-ability/userProfile.html)
- [博主的uniapp的实操](https://juejin.cn/post/7336020150867279909)
- [uniapp-input-文档 | uni-app官网](https://uniapp.dcloud.net.cn/component/input.html)

### tarbar 图标

**使用 png，iconfont 不支持小程序端**

1. 去 iconfont 选取图标
2. 鼠标移动到图标，然后选择下载。设置图标颜色和 `pages.json 里 tabbar.selectedColor` 一致
3. 未选中就是 `user.png` , 选中就用 `user_HL.png`  ，**限制 40 kb，像素大小 81 x 81**

**如果想折腾** 两者兼得（小程序自动使用 png，iconfont 用在其他端）

- iconfont 的优先级更高，所以非小程序会使用 iconfont
- 小程序只会使用 iconPath 和 selectedIconPath

iconfont 配置方法如下

下载 `iconfont.ttf` 文件到仓库，在 tabbar 配置中引入

```json
// tabbar 配置
"iconfontSrc": "static/iconfont.ttf"
```

打开你下载的 css 文件来查找你要的图标。比如下面的用户图标 `\e7ae` 改成 `\ue7ae`, 放到 `iconfont` 下的 `text` 和 `selectedText`

```css
.icon-user:before {
  content: "\e7ae";
}
```

```json
// tabbar 配置
"iconfontSrc": "static/iconfont.ttf"

// list 内配置
{
  iconPath: 'static/logo.png',
  selectedIconPath: 'static/logo.png',
  iconfont: {
    text: '\ue7ae',
    selectedText: '\ue7ae',
    color: '#999999',
    selectedColor: '#007aff'
  }
},
```

### 使用 iconfont 做页面图标

作为页面图标使用

1. 去 iconfont 选取图标
2. `项目设置` 勾选 `base64`, 选择 `font class`
	- unicode 语义化不好
	- symbol 兼容性不好。其实就是 `svg` 标签内部 `use` 这个团
	- fontclass 就是字体图标。这个图标实际上是文字，通过设置文本的大小和颜色来设置图标
3. 点击 css 的 url，复制内容到本地 `iconfont.css` 里，注释掉 css 文件里的 `font-size: 16px;`
4. `App.vue` 的 `style` 引入 `@import "./static/iconfont.css";`
5. 使用 `<i class="iconfont icon-user text-2xl text-green-400"></i>`

>  img. src 的方式使用 svg 无法通过 css 设置样式

作为 tabbar 图标使用 (不在乎小程序端的兼容)

```
```

### 安全边距

```ts
// 拿到安全区域距离，单位是px
// 比如自定义导航栏。在拿到top以后，给导航加上样式 :style="{ paddingTop: safeAreaInsets?.top + 'px' }"
const { safeAreaInsets } = uni.getSystemInfoSync()
console.log(safeAreaInsets)
```

### rpx 单位

- [uniapp的rpx文档](https://zh.uniapp.dcloud.io/tutorial/syntax-css.html#flex-%E5%B8%83%E5%B1%80)
    - 设计稿永远是 750 px, 如果元素占用 100 px。那么就是 `750 * 100 / 750 = 100rpx`
    - 所以屏幕越大, 像素越大. div 应该用 rpx, 字体应该用 px

## 资源

### uni-app 黑马模板

```shell
# 项目模板代码  
git clone -b template https://gitee.com/heima-fe/uniapp-shop-vue3-ts.git heima-shop  
# 项目成品代码  
git clone https://gitee.com/Megasu/uniapp-shop-vue3-ts.git
```
