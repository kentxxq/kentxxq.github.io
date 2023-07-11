---
title: java配置和操作
tags:
  - blog
  - java
date: 2023-07-04
lastmod: 2023-07-05
categories:
  - blog
description: "我不怎么写 [[笔记/point/java|java]] 代码, 但是国内一般都是 java 后台, 所以记录一些配置和操作, 方便复用."
---

## 简介

我不怎么写 [[笔记/point/java|java]] 代码, 但是国内一般都是 java 后台, 所以记录一些配置和操作, 方便复用.

## JVM 启动参数

### JVM 内存配置

可以理解成 `java运行内存 = 堆内存 + 元空间 + 非堆内存`.

- 堆内存：通过参数设置  
- 元空间：通过参数设置  
- 非堆内存：线程数 *1m + non-heap  
- 线程数：pstree pid

常用内存参数

- `-Xms2048m` 初始堆大小
- `-Xmx2048m` 最大堆大小 (建议一致，避免伸缩带来的性能影响)
- `-Xmn500m` 新生代，可以不设置
- `-Xss1024k` 线程的栈大小，默认 1m。线程数 * 这个值是内存一部分
- `-XX:MaxMetaspaceSize=256m` 最大元数据空间大小
- `-XX:+UseContainerSupport` 使用容器内存,JDK 8u191+、JDK 10 及以上版本
- `-XX:InitialRAMPercentage=70.0` 初始内存百分比
- `-XX:MaxRAMPercentage=70.0` 最大内存百分比

### JVM 其他配置

- `gc配置` 不同的 jvm 版本用不同的 gc 回收. 例如 java8 用 `ParallelGC` 或者 `CMS` [java8的gc优化](https://help.aliyun.com/document_detail/148851.html#section-pvl-1zi-0zl), java 11 用 ` g1 `, java 17 用 ` zgc `.所以参数也都不一样. 除非根据监控确定了问题, 明确了解决方案, 否则用默认的吧.
- `-XX:-OmitStackTraceInFastThrow` 一些 jvm 会优化异常抛出, 但缺少 `message` 和 `stack trace`, 所以关闭.
- `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=6666` 远程 debug 连接到 6666 端口. 启用 suspend 是说是否阻塞直到被连接. 除非是 debug 应用启动过程的代码, 否则配置成 n.

### 推荐使用

```shell
-XX:+UseContainerSupport -XX:InitialRAMPercentage=70.0 -XX:MaxRAMPercentage=70.0 -XX:-OmitStackTraceInFastThrow -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=6666
```

## 命令

### Maven 构建

```shell
# clean install 清理以前的文件,解决很多问题
# -T 4 4个线程构建
# -T 1C 每个cpu核心1个线程
# 跳过了测试和,不生成javadoc文件
mvn -T 1C clean install -Dmaven.test.skip -Dmaven.javadoc.skip=true
```

### 内存 dump

```shell
jmap -dump:format=b,file=/tmp/20210107mem.hprof 30699pid
```

### 反编译 jar 包

下载 jar 包 [Releases · java-decompiler/jd-gui](https://github.com/java-decompiler/jd-gui/releases),然后 `java -jar jd-gui.1.6.6.jar`

## 代码配置

- [如何为SpringBoot应用设置健康检查\_Serverless 应用引擎-阿里云帮助中心](https://help.aliyun.com/document_detail/200637.html?spm=a2c4g.148851.0.0.7cdc4077HkuNCz)
