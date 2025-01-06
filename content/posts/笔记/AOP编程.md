---
title: AOP编程
tags:
  - blog
date: 2024-12-27
lastmod: 2024-12-27
categories:
  - blog
description: 
---

## 简介

这里是 [[笔记/point/csharp|csharp]] 的 AOP 笔记

## 分类

- 类型
    - 预处理, 添加源码. source generator.
        - 在 aop 方面比
    - 后处理, 添加二进制命令. IL 代码.
        - 无运行时开销, 原生代码, 减少 jit 压力
        - 调试麻烦, 构建时长增加, 灵活度不够
        - postsharp 商业
            - Metalama
            - [PostSharp](https://www.postsharp.net/)
        - [Fody](https://github.com/Fody/Fody) 免费
            - [知乎文章](https://zhuanlan.zhihu.com/p/557599565)
            - [GitHub - inversionhourglass/Rougamo: Compile-time AOP component. Works with any method, whether it is async or sync, instance or static. Uses an aspectj-like pattern to match methods.](https://github.com/inversionhourglass/Rougamo)
    - 使用特殊编译器, 编译时添加代码
    - 运行时使用代码拦截器.
        - 一些更高级别的服务会选择依赖拦截器. 比如 [EasyCaching](https://easycaching.readthedocs.io/en/latest/Castle/#1-install-the-package-via-nuget)
        - [AspectCore-Framework](https://github.com/dotnetcore/AspectCore-Framework)
        - [Castle](https://github.com/castleproject/Core)
            - [autofac](https://autofac.readthedocs.io/en/latest/advanced/interceptors.html)
        - RealProxy 是 netframework 的 , netcore 使用 DispatchProxy

- 不流行
    - [aspect-injector](https://github.com/pamidur/aspect-injector)
    - [unity](https://github.com/unitycontainer/unity)

## 实例

### Rougamo

安装 `Rougamo.Fody` 后编写 `TimingAttribute`, 放到 `Method` 上就生效了

```csharp
using System.Diagnostics;
using Rougamo;
using Rougamo.Context;
using Serilog;

namespace Uni.Webapi.Common;

public class TimingAttribute : MoAttribute
{
    private readonly Stopwatch _stopwatch = new();

    public override void OnEntry(MethodContext context)
    {
        // OnEntry对应方法执行前
        _stopwatch.Start();
    }

    public override void OnException(MethodContext context)
    {
        // OnException对应方法抛出异常后
    }

    public override void OnSuccess(MethodContext context)
    {
        // OnSuccess对应方法执行成功后
    }

    public override void OnExit(MethodContext context)
    {
        // OnExit对应方法退出时
        _stopwatch.Stop();
        Log.Information($"{context.Method.Name} 耗时:{_stopwatch.ElapsedMilliseconds}ms");
    }
}

// 定义一个类型继承AsyncMoAttribute
// public class TestAttribute : AsyncMoAttribute
// {
//     public override async ValueTask OnEntryAsync(MethodContext context) { }
//
//     public override async ValueTask OnExceptionAsync(MethodContext context) { }
//
//     public override async ValueTask OnSuccessAsync(MethodContext context) { }
//
//     public override async ValueTask OnExitAsync(MethodContext context) { }
// }
```

### 代理模式/IOC

- [AspectCore-Framework](https://github.com/dotnetcore/AspectCore-Framework/blob/master/docs/1.%E4%BD%BF%E7%94%A8%E6%8C%87%E5%8D%97.md)
    - 编写 `CustomInterceptorAttribute`
    - 添加服务 `services.ConfigureDynamicProxy();`
    - 替换容器 `Host.CreateDefaultBuilder(args).UseServiceProviderFactory(new DynamicProxyServiceProviderFactory())`
- [Autofac-DI配置](https://autofac.readthedocs.io/en/latest/integration/aspnetcore.html#asp-net-core-3-0-and-generic-hosting) , [AOP配置](https://autofac.readthedocs.io/en/latest/advanced/interceptors.html)
    - 创建 `public class CallLogger : IInterceptor`
    - 注册拦截器 `builder.Register(c => new CallLogger(Console.Out));`
    - 注册服务的时候启用拦截器 `builder.registerType().EnableInterfaceInterceptors()`
    - 在接口和 class 上配置 `[Intercept(typeof(CallLogger))]` , **不能用在函数上, 默认拦截接口/class 的所有方法**
    - 替换容器 `Host.CreateDefaultBuilder(args).UseServiceProviderFactory(new AutofacServiceProviderFactory())`

## 资料

- [AOP文章-微软杂志](https://learn.microsoft.com/en-us/archive/msdn-magazine/2014/february/aspect-oriented-programming-aspect-oriented-programming-with-the-realproxy-class)
- [AOP文章-AspectCore](https://github.com/dotnetcore/AspectCore-Framework/blob/master/docs/0.AOP%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D.md)
