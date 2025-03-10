---
title: csharp编码风格
tags:
  - blog
  - csharp
date: 2023-09-16
lastmod: 2025-02-17
categories:
  - blog
description: "csharp 的编码配置 .editorconfig 文件."
---

## 简介

[[笔记/point/csharp|csharp]] 的 [官网编码风格](https://learn.microsoft.com/zh-cn/dotnet/fundamentals/code-analysis/style-rules/language-rules) 的总结如下

- 代码质量分析
    - `CAxxxx` 是质量格式
- 代码样式分析
    - `IDExxxx` 是样式格式, 同时还包含 `pascal_case` 这样的命名格式
    - [Language rules 语言规则](https://learn.microsoft.com/zh-cn/dotnet/fundamentals/code-analysis/style-rules/language-rules)
    - [Formatting rules 格式规则](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/ide0055)
    - [Naming rules 命名规则](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/naming-rules)
    - [Miscellaneous rules 杂项规则, 基本用不上](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/miscellaneous-rules)  
- 第三方也可以自定义, 比如 [StyleCopAnalyzers](https://github.com/DotNetAnalyzers/StyleCopAnalyzers) 就自定义了 [SA1633](https://github.com/DotNetAnalyzers/StyleCopAnalyzers/blob/master/documentation/SA1633.md) 这样的规则

要用 `stylecop` 代码样式, 就用 `stylecop.json` 来添加自定义的规则 . 如果是内置规则, 就用 `.editorconfig` 来配置. 所以我就直接用 `.editorconfig`

## 强制启用

项目 `csproj` 加入 `EnforceCodeStyleInBuild` 为 `true`. [详情链接](https://learn.microsoft.com/en-us/dotnet/core/project-sdk/msbuild-props#enforcecodestyleinbuild)

## 配置警告

[配置警告参考链接](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/language-rules)

- 示例
    - `dotnet_style_readonly_field = true:suggestion` 如果字段可以写成 `readonly`, 那么就在 IDE 以 `建议` 的形式提示用户
    - `readonly_field` 是配置项
    - `true` 是开启配置
    - `suggestion` 是 `<severity-level>`
- 只有 vs 可以理解 `:<severity-level>` 这种写法
- 所以我们使用编译器能理解的方式 `dotnet_diagnostic.<rule-ID>.severity = <severity-level>`

## 配置文件 editorconfig

项目根路径创建 `.editorconfig` 文件.

```ini
# only record change
 
root = true
[*]
# space instead tab
indent_style = space
charset = utf-8
# trim end 
trim_trailing_whitespace = true
# insert "\n" to end
insert_final_newline = true

[*.{csproj,vbproj,vcxproj,vcxproj.filters,proj,projitems,shproj}]
indent_size = 2

[*.{props,targets,ruleset,config,nuspec,resx,vsixmanifest,vsct}]
indent_size = 2

[*.json]
indent_size = 2

[*.{ps1,psm1}]
indent_size = 4

[*.{razor,cshtml}]
charset = utf-8-bom

# no check
[*.g.cs]
generated_code = false

[*.cs]
# tab = 4 space
tab_width = 4
# indent = 4 space
indent_size = 4

######################################################################################################################################################################################
# Language rules 

# simple code 
dotnet_diagnostic.IDE0001.severity = warning
dotnet_diagnostic.IDE0002.severity = warning
# don't use "this."
dotnet_diagnostic.IDE0003.severity = warning
# always use var
dotnet_diagnostic.IDE0007.severity = warning
csharp_style_var_for_built_in_types = true
csharp_style_var_when_type_is_apparent = true
csharp_style_var_elsewhere = true
# better read your "swith code"
dotnet_diagnostic.IDE0010.severity = warning
# even 1 line code use "{}"
dotnet_diagnostic.IDE0011.severity = warning
csharp_prefer_braces = true
# remove namespce "{}"
dotnet_diagnostic.IDE0161.severity = warning
csharp_style_namespace_declarations = file_scoped

######################################################################################################################################################################################
# Naming rules 
dotnet_diagnostic.IDE1006.severity = warning 
# <kind>.<entityName>.<propertyName> = <propertyValue>

# dotnet_naming_rule
dotnet_naming_rule.interface_should_be_begins_with_i.severity = suggestion
dotnet_naming_rule.interface_should_be_begins_with_i.symbols = interface
dotnet_naming_rule.interface_should_be_begins_with_i.style = begins_with_i
dotnet_naming_rule.types_should_be_pascal_case.severity = suggestion
dotnet_naming_rule.types_should_be_pascal_case.symbols = types
dotnet_naming_rule.types_should_be_pascal_case.style = pascal_case
dotnet_naming_rule.non_field_members_should_be_pascal_case.severity = suggestion
dotnet_naming_rule.non_field_members_should_be_pascal_case.symbols = non_field_members
dotnet_naming_rule.non_field_members_should_be_pascal_case.style = pascal_case
# dotnet_naming_symbols
dotnet_naming_symbols.interface.applicable_kinds = interface
dotnet_naming_symbols.interface.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected
dotnet_naming_symbols.interface.required_modifiers = 
dotnet_naming_symbols.types.applicable_kinds = class, struct, interface, enum
dotnet_naming_symbols.types.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected
dotnet_naming_symbols.types.required_modifiers = 
dotnet_naming_symbols.non_field_members.applicable_kinds = property, event, method
dotnet_naming_symbols.non_field_members.applicable_accessibilities = public, internal, private, protected, protected_internal, private_protected
dotnet_naming_symbols.non_field_members.required_modifiers = 
# dotnet_naming_style
dotnet_naming_style.begins_with_i.required_prefix = I
dotnet_naming_style.begins_with_i.required_suffix = 
dotnet_naming_style.begins_with_i.word_separator = 
dotnet_naming_style.begins_with_i.capitalization = pascal_case
dotnet_naming_style.pascal_case.required_prefix = 
dotnet_naming_style.pascal_case.required_suffix = 
dotnet_naming_style.pascal_case.word_separator = 
dotnet_naming_style.pascal_case.capitalization = pascal_case
dotnet_naming_style.pascal_case.required_prefix = 
dotnet_naming_style.pascal_case.required_suffix = 
dotnet_naming_style.pascal_case.word_separator = 
dotnet_naming_style.pascal_case.capitalization = pascal_case

######################################################################################################################################################################################
# Formatting rules 
dotnet_diagnostic.IDE0055.severity = warning

# .net
# https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/dotnet-formatting-options

# new line
# https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/ide0055

# indent
# https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/csharp-formatting-options#indentation-options

# space
# https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/csharp-formatting-options#spacing-options

# wrap
# https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/csharp-formatting-options#csharp_preserve_single_line_statements
csharp_preserve_single_line_statements = false
```
