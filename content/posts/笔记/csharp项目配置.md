---
title: csharp项目配置
tags:
  - blog
  - csharp
date: 2023-07-26
lastmod: 2023-07-27
categories:
  - blog
description: 
---

## 简介

[[笔记/point/csharp|csharp]] 的项目相关配置, 帮助组织规范项目.

## 项目配置

[.NET 项目 SDK 概述 | Microsoft Learn](https://learn.microsoft.com/zh-cn/dotnet/core/project-sdk/overview)

### 配置项参考

> 已知 aot 的时候 IncludeNativeLibrariesInSingleFile 会失败
> 如果没有生效, 可以 -p 手动传参.
> dotnet publish -c Release -r linux-x 64 -p:IncludeNativeLibrariesInSingleFile=true

```xml
<Project Sdk="Microsoft.NET.Sdk">

    <PropertyGroup>
        <TargetFramework>net7.0</TargetFramework>
        <!-- 减少空指针异常 -->
        <Nullable>enable</Nullable>
        <!-- 全局using -->
        <ImplicitUsings>enable</ImplicitUsings>
        <!-- 默认linux容器 -->
        <DockerDefaultTargetOS>Linux</DockerDefaultTargetOS>
        <!-- 锁定包版本 https://learn.microsoft.com/zh-cn/nuget/consume-packages/package-references-in-project-files#locking-dependencies -->
        <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
        <!-- 可以被Version替代,弃用 -->
        <!-- 生成包信息 https://learn.microsoft.com/zh-cn/dotnet/core/project-sdk/msbuild-props#generateassemblyinfo -->
        <!-- <GenerateAssemblyInfo>true</GenerateAssemblyInfo> -->
        <!-- 版本信息 kentxxq.cli通过这个定义版本号 -->
        <!-- <InformationalVersion>1.0.0</InformationalVersion> -->
        <Version>1.0.0</Version>
        <!-- 删除已存在的文件 -->
        <DeleteExistingFiles>true</DeleteExistingFiles>

        <!-- 需要机制优化的时候使用 https://learn.microsoft.com/zh-cn/dotnet/core/deploying/trimming/trimming-options?pivots=dotnet-7-0#trimming-framework-library-features -->
        <!-- 删除debug信息,祝你好运... -->
        <DebuggerSupport>false</DebuggerSupport>
        <!-- 删除eventsource,无法trace追踪了.. -->
        <EventSourceSupport>false</EventSourceSupport>
        <!-- http诊断 -->
        <HttpActivityPropagationSupport>false</HttpActivityPropagationSupport>
        <!-- 删除过时的序列化 -->
        <EnableUnsafeBinaryFormatterSerialization>false</EnableUnsafeBinaryFormatterSerialization>
        <!-- 全球化,我总是用一组固定的ui展示 -->
        <InvariantGlobalization>true</InvariantGlobalization>
        <!-- System.* 的异常信息会被简化变成相当差 -->
        <UseSystemResourceKeys>true</UseSystemResourceKeys>
        <!-- ilc https://devblogs.microsoft.com/dotnet/performance_improvements_in_net_7/ -->
        <IlcOptimizationPreference>Size</IlcOptimizationPreference>
        <IlcGenerateStackTraceData>false</IlcGenerateStackTraceData>
        <!-- 默认会混合,不建议开启下面2个 -->
        <!-- <OptimizationPreference>Size</OptimizationPreference> -->
        <!-- <OptimizationPreference>Speed</OptimizationPreference> -->



        <!-- Cli -->
        <OutputType>Exe</OutputType>
        <!-- 构建出来的名字 -->
        <AssemblyName>ken</AssemblyName>
        <!-- 自包含 -->
        <SelfContained>true</SelfContained>
        <!-- 启用 aot, 和 PublishSingleFile 冲突 -->
        <PublishAot>true</PublishAot>
        <!-- 单个文件, 和aot冲突 -->
        <PublishSingleFile>true</PublishSingleFile>
        <!-- 缩减大小 -->
        <PublishTrimmed>true</PublishTrimmed>
        <!-- 分离pdb调试文件,可执行文件 https://learn.microsoft.com/en-us/dotnet/core/deploying/native-aot/?tabs=net8plus#native-debug-information -->
        <StripSymbols>true</StripSymbols>
        <!-- 压缩一下大小 -->
        <EnableCompressionInSingleFile>true</EnableCompressionInSingleFile>
        <!-- 包含二进制库 -->
        <IncludeNativeLibrariesForSelfExtract>true</IncludeNativeLibrariesForSelfExtract>
        <!-- 打包所有文件,然后解压使用 -->
        <IncludeAllContentForSelfExtract>true</IncludeAllContentForSelfExtract>



        <!-- Web -->
        <!-- 拷贝swagger文件 -->
        <DocumentationFile>bin\Debug\MyApi.xml</DocumentationFile>



        <!-- Nuget -->
        <!-- 打包常用 https://learn.microsoft.com/zh-cn/nuget/reference/msbuild-targets#pack-target -->
        <Authors>kentxxq</Authors>
        <Company>kentxxq.com</Company>
        <PackageProjectUrl>https://github.com/kentxxq/kentxxq.Cli</PackageProjectUrl>
        <RepositoryUrl>https://github.com/kentxxq/kentxxq.Cli</RepositoryUrl>
        <PackageLicenseFile>LICENSE.md</PackageLicenseFile>
        <GeneratePackageOnBuild>false</GeneratePackageOnBuild>

        <!-- 你分发插件库,又依赖了其他项目的时候,把lock文件拷贝过去 -->
        <CopyLocalLockFileAssemblies>true</CopyLocalLockFileAssemblies>

        <!-- 这个库是否兼容aot -->
        <IsAotCompatible>true</IsAotCompatible>

    </PropertyGroup>



    <ItemGroup>
        <!-- 配合 PropertyGroup.PackageLicenseFile 使用 -->
        <None Include="..\..\LICENSE.md">
            <Pack>True</Pack>
            <PackagePath></PackagePath>
        </None>

        <!-- docker构建时候忽略文件 -->
        <Content Include="..\.dockerignore">
            <Link>.dockerignore</Link>
        </Content>

        <!-- grpc -->
        <Protobuf Include="Proto\greet.proto" GrpcServices="Server" />
    </ItemGroup>


    <ItemGroup>
        <PackageReference Include="Grpc.AspNetCore" Version="2.55.0" />
        <PackageReference Include="IP2Region.Net" Version="1.0.10" />
        <PackageReference Include="Serilog.AspNetCore" Version="7.0.0" />
        <PackageReference Include="Serilog.Enrichers.Thread" Version="3.1.0" />
        <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
    </ItemGroup>

</Project>

```

### 项目引入 aspnetcore

```xml
<Project Sdk="Microsoft.NET.Sdk">
    <ItemGroup>
        <FrameworkReference Include="Microsoft.AspNetCore.App" />
    </ItemGroup>
</Project>
```

### 执行 msbuild 任务

官方链接 [MSBuild Task Reference - MSBuild | Microsoft Learn](https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-task-reference?view=vs-2022)

- [Copy Task - MSBuild | Microsoft Learn](https://learn.microsoft.com/en-us/visualstudio/msbuild/copy-task?view=vs-2022) 构建的时候, 拷贝 xx 文件到 xx 目录下面

### single file

- 设计文档 [design.md](https://github.com/dotnet/designs/blob/main/accepted/2020/single-file/design.md#optional-settings)
