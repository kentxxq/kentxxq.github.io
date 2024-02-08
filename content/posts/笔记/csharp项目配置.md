---
title: csharp项目配置
tags:
  - blog
  - csharp
date: 2023-07-26
lastmod: 2024-02-06
categories:
  - blog
description: "[[笔记/point/csharp|csharp]] 的项目相关配置, 帮助组织规范项目. 同时优化运行时的一些指标参数."
---

## 简介

[[笔记/point/csharp|csharp]] 的项目配置文章中，没有任何代码相关内容。

## 常用命令

### dotnet-new 模板

```shell
# 新建git项目,clone下来后使用。建议用 kentxxq.Kscheduler 标识.产品名
# 创建一个当前文件夹同名sln文件，可以执行-n kentxxq.Kscheduler
dotnet new sln 
# 创建项目。使用 标识.产品名.模块
dotnet new webapi --name kentxxq.Kscheduler.webapi --use-controllers --no-https
# 添加项目
dotnet sln add .\kentxxq.Kscheduler.webapi\kentxxq.Kscheduler.webapi.csproj


# 查看所有的包
dotnet new --list
# 卸载包
dotnet new --uninstall
# 搜包
dotnet new search kentxxq.Templates
# 安装
dotnet new install kentxxq.Templates
# 使用
dotnet new k-webapi --name certmanager 
```

### nuget 推包

```shell
# 先打包成nupkg
dotnet nuget push kentxxq.Extensions.1.1.0.nupkg --api-key key
```

### nuget 缓存路径配置

```shell
setx /M NUGET_PACKAGES D:\<username>\.nuget\packages
```

### 更新所有 dotnet-tools

```powershell
dotnet tool list -g | ForEach-Object {$index = 0} { $index++; if($index -gt 2) { dotnet tool update -g $_.split(" ")[0] } }
```

## 项目配置

[.NET 项目 SDK 概述 | Microsoft Learn](https://learn.microsoft.com/zh-cn/dotnet/core/project-sdk/overview)

### 配置项参考

#### 发布文件配置

发布文件配置 `win-x64.pubxml`

```shell
dotnet publish -c Release /p:PublishProfile=Properties\PublishProfiles\win-x64.pubxml
```

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
https://go.microsoft.com/fwlink/?LinkID=208121.
-->
<Project>
    <PropertyGroup>
        <Configuration>Release</Configuration>
        <Platform>Any CPU</Platform>
        <PublishDir>bin\Release\net8.0\win-x64\publish\win-x64\</PublishDir>
        <PublishProtocol>FileSystem</PublishProtocol>
        <_TargetId>Folder</_TargetId>
        <TargetFramework>net8.0</TargetFramework>
        <RuntimeIdentifier>win-x64</RuntimeIdentifier>
        <SelfContained>true</SelfContained>
        <PublishSingleFile>false</PublishSingleFile>
        <PublishReadyToRun>false</PublishReadyToRun>
    </PropertyGroup>
</Project>
```

> 已知 aot 的时候 IncludeNativeLibrariesInSingleFile 会失败
> 如果没有生效, 可以 -p 手动传参.
> dotnet publish -c Release -r linux-x 64 -p:IncludeNativeLibrariesInSingleFile=true
> -r runtime 可以指定系统和架构，例如 linux-64
> [完整的支持列表在这里](https://learn.microsoft.com/en-us/dotnet/core/rid-catalog)

#### 项目文件配置

项目文件配置 `xxx.csproj`

```xml
<Project Sdk="Microsoft.NET.Sdk">

    <PropertyGroup>
        <TargetFramework>net8.0</TargetFramework>
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

#### 官方文档

[MSBuild Task Reference - MSBuild | Microsoft Learn](https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-task-reference?view=vs-2022)

#### 拷贝文件 Copy

构建的时候, 拷贝 xx 文件到 xx 目录下面.

```xml
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">

<PropertyGroup>  
    <ip2regionDB>https://ghproxy.com/https://github.com/lionsoul2014/ip2region/blob/master/data/ip2region.xdb</ip2regionDB>  
</PropertyGroup>  
  
<Target Name="DownloadContentFiles" BeforeTargets="Build" Condition="!Exists('$(PublishDir)/ip2region.xdb')">  
    <DownloadFile 
        SourceUrl="$(ip2regionDB)"  
        DestinationFolder="$(PublishDir)">  
        <Output TaskParameter="DownloadedFile" ItemName="Content" />  
    </DownloadFile>
</Target>

</Project>
```

> [!info]
> dotnet publish 的 `-o,--output` 是映射到 MSBUILD 的 `PublishDir`,而不是 `OutputPath`

#### 下载任务 DownloadFile

在构建之前, 下载文件到本地. `ip2region` 就用到了.

- `MSBuildProjectDirectory`: 是 csproj 所在的目录
- `OutputPath`: 是构建物输出的目录

```xml
<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
        <ip2regionDB>https://ghproxy.com/https://github.com/lionsoul2014/ip2region/blob/master/data/ip2region.xdb</ip2regionDB>
    </PropertyGroup>

    <Target Name="DownloadContentFiles" BeforeTargets="Build">
        <DownloadFile
                SourceUrl="$(ip2regionDB)"
                DestinationFolder="$(OutputPath)">
            <Output TaskParameter="DownloadedFile" ItemName="Content" />
        </DownloadFile>
    </Target>
</Project>
```

### single file

- 设计文档 [design.md](https://github.com/dotnet/designs/blob/main/accepted/2020/single-file/design.md#optional-settings)

## 运行配置

```docker
# 多gc节省 0-9之间 https://learn.microsoft.com/zh-cn/dotnet/core/runtime-config/garbage-collector#conserve-memory
ENV DOTNET_GCConserveMemory=9
```

## 杂项

### `.gitignore`

```gitignore
# User-specific files
*.rsuser
*.suo
*.user
*.userosscache
*.sln.docstates

# User-specific files (MonoDevelop/Xamarin Studio)
*.userprefs

# Mono auto generated files
mono_crash.*

# Build results
[Dd]ebug/
[Dd]ebugPublic/
[Rr]elease/
[Rr]eleases/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Oo]ut/
[Ll]og/
[Ll]ogs/

# Visual Studio 2015/2017 cache/options directory
.vs/
# Uncomment if you have tasks that create the project's static files in wwwroot
#wwwroot/

# Visual Studio 2017 auto generated files
Generated\ Files/

# MSTest test Results
[Tt]est[Rr]esult*/
[Bb]uild[Ll]og.*

# NUnit
*.VisualState.xml
TestResult.xml
nunit-*.xml

# Build Results of an ATL Project
[Dd]ebugPS/
[Rr]eleasePS/
dlldata.c

# Benchmark Results
BenchmarkDotNet.Artifacts/

# .NET Core
project.lock.json
project.fragment.lock.json
artifacts/

# ASP.NET Scaffolding
ScaffoldingReadMe.txt

# StyleCop
StyleCopReport.xml

# Files built by Visual Studio
*_i.c
*_p.c
*_h.h
*.ilk
*.meta
*.obj
*.iobj
*.pch
*.pdb
*.ipdb
*.pgc
*.pgd
*.rsp
*.sbr
*.tlb
*.tli
*.tlh
*.tmp
*.tmp_proj
*_wpftmp.csproj
*.log
*.vspscc
*.vssscc
.builds
*.pidb
*.svclog
*.scc

# Chutzpah Test files
_Chutzpah*

# Visual C++ cache files
ipch/
*.aps
*.ncb
*.opendb
*.opensdf
*.sdf
*.cachefile
*.VC.db
*.VC.VC.opendb

# Visual Studio profiler
*.psess
*.vsp
*.vspx
*.sap

# Visual Studio Trace Files
*.e2e

# TFS 2012 Local Workspace
$tf/

# Guidance Automation Toolkit
*.gpState

# ReSharper is a .NET coding add-in
_ReSharper*/
*.[Rr]e[Ss]harper
*.DotSettings.user

# TeamCity is a build add-in
_TeamCity*

# DotCover is a Code Coverage Tool
*.dotCover

# AxoCover is a Code Coverage Tool
.axoCover/*
!.axoCover/settings.json

# Coverlet is a free, cross platform Code Coverage Tool
coverage*.json
coverage*.xml
coverage*.info

# Visual Studio code coverage results
*.coverage
*.coveragexml

# NCrunch
_NCrunch_*
.*crunch*.local.xml
nCrunchTemp_*

# MightyMoose
*.mm.*
AutoTest.Net/

# Web workbench (sass)
.sass-cache/

# Installshield output folder
[Ee]xpress/

# DocProject is a documentation generator add-in
DocProject/buildhelp/
DocProject/Help/*.HxT
DocProject/Help/*.HxC
DocProject/Help/*.hhc
DocProject/Help/*.hhk
DocProject/Help/*.hhp
DocProject/Help/Html2
DocProject/Help/html

# Click-Once directory
publish/

# Publish Web Output
*.[Pp]ublish.xml
*.azurePubxml
# Note: Comment the next line if you want to checkin your web deploy settings,
# but database connection strings (with potential passwords) will be unencrypted
*.pubxml
*.publishproj

# Microsoft Azure Web App publish settings. Comment the next line if you want to
# checkin your Azure Web App publish settings, but sensitive information contained
# in these scripts will be unencrypted
PublishScripts/

# NuGet Packages
*.nupkg
# NuGet Symbol Packages
*.snupkg
# The packages folder can be ignored because of Package Restore
**/[Pp]ackages/*
# except build/, which is used as an MSBuild target.
!**/[Pp]ackages/build/
# Uncomment if necessary however generally it will be regenerated when needed
#!**/[Pp]ackages/repositories.config
# NuGet v3's project.json files produces more ignorable files
*.nuget.props
*.nuget.targets

# Microsoft Azure Build Output
csx/
*.build.csdef

# Microsoft Azure Emulator
ecf/
rcf/

# Windows Store app package directories and files
AppPackages/
BundleArtifacts/
Package.StoreAssociation.xml
_pkginfo.txt
*.appx
*.appxbundle
*.appxupload

# Visual Studio cache files
# files ending in .cache can be ignored
*.[Cc]ache
# but keep track of directories ending in .cache
!?*.[Cc]ache/

# Others
ClientBin/
~$*
*~
*.dbmdl
*.dbproj.schemaview
*.jfm
*.pfx
*.publishsettings
orleans.codegen.cs

# Including strong name files can present a security risk
# (https://github.com/github/gitignore/pull/2483#issue-259490424)
#*.snk

# Since there are multiple workflows, uncomment next line to ignore bower_components
# (https://github.com/github/gitignore/pull/1529#issuecomment-104372622)
#bower_components/

# RIA/Silverlight projects
Generated_Code/

# Backup & report files from converting an old project file
# to a newer Visual Studio version. Backup files are not needed,
# because we have git ;-)
_UpgradeReport_Files/
Backup*/
UpgradeLog*.XML
UpgradeLog*.htm
ServiceFabricBackup/
*.rptproj.bak

# SQL Server files
*.mdf
*.ldf
*.ndf

# Business Intelligence projects
*.rdl.data
*.bim.layout
*.bim_*.settings
*.rptproj.rsuser
*- [Bb]ackup.rdl
*- [Bb]ackup ([0-9]).rdl
*- [Bb]ackup ([0-9][0-9]).rdl

# Microsoft Fakes
FakesAssemblies/

# GhostDoc plugin setting file
*.GhostDoc.xml

# Node.js Tools for Visual Studio
.ntvs_analysis.dat
node_modules/

# Visual Studio 6 build log
*.plg

# Visual Studio 6 workspace options file
*.opt

# Visual Studio 6 auto-generated workspace file (contains which files were open etc.)
*.vbw

# Visual Studio LightSwitch build output
**/*.HTMLClient/GeneratedArtifacts
**/*.DesktopClient/GeneratedArtifacts
**/*.DesktopClient/ModelManifest.xml
**/*.Server/GeneratedArtifacts
**/*.Server/ModelManifest.xml
_Pvt_Extensions

# Paket dependency manager
.paket/paket.exe
paket-files/

# FAKE - F# Make
.fake/

# CodeRush personal settings
.cr/personal

# Python Tools for Visual Studio (PTVS)
__pycache__/
*.pyc

# Cake - Uncomment if you are using it
# tools/**
# !tools/packages.config

# Tabs Studio
*.tss

# Telerik's JustMock configuration file
*.jmconfig

# BizTalk build output
*.btp.cs
*.btm.cs
*.odx.cs
*.xsd.cs

# OpenCover UI analysis results
OpenCover/

# Azure Stream Analytics local run output
ASALocalRun/

# MSBuild Binary and Structured Log
*.binlog

# NVidia Nsight GPU debugger configuration file
*.nvuser

# MFractors (Xamarin productivity tool) working folder
.mfractor/

# Local History for Visual Studio
.localhistory/

# BeatPulse healthcheck temp database
healthchecksdb

# Backup folder for Package Reference Convert tool in Visual Studio 2017
MigrationBackup/

# Ionide (cross platform F# VS Code tools) working folder
.ionide/

# Fody - auto-generated XML schema
FodyWeavers.xsd

.idea/
```
