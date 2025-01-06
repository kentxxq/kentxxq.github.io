---
title: pnpm的monorepo实践
tags:
  - blog
date: 2024-12-30
lastmod: 2024-12-31
categories:
  - blog
description: 
---

## 简介

pnpm 的 monorepo 实践

## 创建项目

1. 创建项目 `mkdir w` , `cd w` ,
2. 初始化 `pnpm init`, 会创建出 `package.json`
3. 创建 `pnpm-workspace.yaml`

    ```yaml
    packages:
      - "apps/*" # app目录 /apps/dashboard /apps/website
      - "packages/*" # 公共包目录 /packages/charts  /packages/ui
    ```

4. 创建 `.npmrc` 配置文件

    ```toml
    # 配置依赖提升,把A依赖的B项目提升到项目的依赖中
    # 
    # 1 需要兼容npm的老项目
    # 2 存在隐式依赖(未在 package.json 中声明,但是使用了)
    # 3 插件,构建工具不支持扁平化依赖
    # shamefully-hoist = true
    ```

5. 每个项目都 `pnpm init`
6. `packages/tools` 的 `package.json`

    ```json
    {
      "name": "@kentxxq/uni-tools",
      "version": "1.0.0",
      "private": "true"
    }
    ```

7. 导出函数 `index.ts`

    ```ts
    import consola from "consola";
    
    export function echo() {
      consola.info("hi...");
    }
    ```

8. `apps/app1` 初始化 vue 项目后,  添加依赖 `pnpm add @kentxxq/uni-tools --workspace`, 即可导入使用. (如果希望一直使用最新版本, 可以把 `"workspace:^"` 改成 `"workspace:*"` )

    ```ts
    import { echo } from '@kentxxq/uni-tools';
    
    echo()
    ```

9. 把共享的依赖移动到最外层的 `package.json`, 添加启动命令.

```json
{
  "name": "30",
  "version": "1.0.0",
  "scripts": {
    "dev:d": "pnpm --filter app1 dev",
    "build:d": "pnpm --filter app1 build"
  },
  "dependencies": {
    "consola": "^3.3.3"
  },
  "devDependencies": {
    "@tsconfig/node22": "^22.0.0",
    "@types/node": "^22.10.2",
    "@vitejs/plugin-vue": "^5.2.1",
    "@vue/eslint-config-prettier": "^10.1.0",
    "@vue/eslint-config-typescript": "^14.2.0",
    "@vue/tsconfig": "^0.7.0",
    "eslint": "^9.17.0",
    "eslint-plugin-vue": "^9.32.0",
    "npm-run-all2": "^7.0.2",
    "prettier": "^3.4.2",
    "typescript": "~5.7.2",
    "vite": "^6.0.6",
    "vite-plugin-vue-devtools": "^7.6.8",
    "vue-tsc": "^2.2.0"
  }
}
```

## 相关 pnpm 命令

```shell
# 添加全局依赖
pnpm add vue -w

# 针对某个项目执行
pnpm add --filter AppName PackageName

# 添加项目依赖
cd app1
pnpm add consola

# 单个项目运行命令
pnpm --filter <package-name> <command>
pnpm --filter app1 dev
# 遍历运行命令
pnpm -r dev

# 顺序执行
pnpm build:dev & pnpm build:test

# cli命令
# 生成默认tsconfig.json
pnpm tsc --init
# 编译成js
pnpm tsc
# 执行
node dist/index.js
# 结合执行
"dev":"pnpm tsc & node dist/index.js"
```

## 使用细节

### 共享库 tools

`tsup` 是安装 `typescript` 构建工具, 所以先添加到空间 `pnpm add tsup -D -w`

创建 `tsup.config.ts`

```ts
import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["index.ts"],
  // format: ["cjs", "esm"], // Build for commonJS and ESmodules
  format: ['esm'],
  dts: true, // Generate declaration file (.d.ts)
  splitting: false,
  sourcemap: true,
  clean: true,
  minify: true
});
```

`package.json` 添加构建命令 , 添加必要配置

```json
{
  "name": "@kentxxq/uni-tools",
  "version": "1.0.0",
  "private": "true",
  
  // 构建命令
  "scripts": {
    "build:node": "tsup --platform node",
    "build:browser": "tsup --platform browser",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  // 添加配置,告诉使用者入口,类型,文件在哪
  "module": "./dist/index.mjs",
  // 如果同时支持commonjs和esm,就用下面的配置
  // "main": "./dist/index.js",
  // "types": "./dist/index.d.ts",
  "main": "./dist/index.mjs",
  "types": "./dist/index.d.mts",
  "files": [
    "dist"
  ]
}
```

参考文章 [Guide: TypeScript NPM Package Publishing \| Medium](https://pauloe-me.medium.com/typescript-npm-package-publishing-a-beginners-guide-40b95908e69c)

### node 程序报错

#### MODULE_TYPELESS_PACKAGE_JSON

报错是因为我们构建的是 esm 语法, 但是项目里没有声明. 所以在执行的时候会有性能开销.

在 `package.json` 加上 `"type":"module"`

### 代码同步更新

1. `tools` 中有**构建命令** `"build:browser": "tsup --platform browser"` 构建出来 js 文件
2. `cli` 引用 `tools`, **启动命令用于被调用** `"dev": "pnpm tsc & node dist/index.js"`
3. `workspace` 的 `packages.json` 启动项目
    - 构建最新的共享包 `"build:packages-browser": "pnpm -r --filter ./packages/* build:browser"`
    - 前端属于 `browser` 类型的应用.  `"dev:d": "pnpm run build:packages-browser && pnpm --filter docker-mirror dev"`
    - `cli` 属于 `node` 类型应用. 先调用构建命令, 然后调用 `cli` 的命令 `"dev:cli": "pnpm run build:packages-node && pnpm --filter cli dev"`
4. 启动项目后, 可以在共享库 `tools` 目录下, 使用 ` pnpm tsup --platform browser --watch ` 监控依赖, 构建最新的版本
