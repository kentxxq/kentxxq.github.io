---
title: powershell命令与配置
tags:
  - blog
  - powershell
date: 2023-06-26
lastmod: 2024-01-04
categories:
  - blog
description: "这里记录 [[笔记/point/powershell|powershell]] 的常用命令."
---

## 简介

这里记录 [[笔记/point/powershell|powershell]] 的常用命令.

## 操作手册

### 日常操作

#### grep 过滤

```powershell
# 类似 ls | grep xxx 搜索
winget list | Select-String nodejs
```

#### 重载配置文件

```powershell
. $profile
```

#### 操作变量

```powershell
# 示例是配置golang,启用cgo编译
# 本地变量
set CGO_ENABLED "1"
echo $CGO_ENABLED
rv CGO_ENABLED

# $env 用于访问用户变量和系统变量
echo $env:CGO_ENABLED
```

### 命令查询

```powershell
# 查询所有命令
Get-Command
# 查询名字包含Process的命令
Get-Command -Name *Process

# 查看alias
Get-Alias
Alias           set -> Set-Variable
Alias           echo -> Write-Output
Alias           rv -> Remove-Variable

Alias           ls -> Get-ChildItem
Alias           cat -> Get-Content
Alias           cd -> Set-Location
Alias           clear -> Clear-Host
Alias           copy -> Copy-Item
Alias           cp -> Copy-Item
Alias           mv -> Move-Item
```

### 常用配置

#### $profile 配置

1. 安装 `oh-my-post`: `winget install JanDeDobbeleer.OhMyPosh -s winget`
2. 编辑配置文件 `notepad $profile` 或者 `code $profile`
3. 贴入配置文件

```powershell
# 主题配置,主题列表 https://ohmyposh.dev/docs/themes
oh-my-posh init pwsh --config "D:\OneDrive\kentxxq\config\oh-my-posh\theme.json" | Invoke-Expression

# vpn命令
function vpn {
    $Env:all_proxy = "http://127.0.0.1:7890";
}
# function vpn {
#     $Env:http_proxy = "http://127.0.0.1:7890"; $Env:https_proxy = "http://127.0.0.1:7890";
# }

function novpn {
    $Env:all_proxy = "";
}
# function novpn {
#     $Env:http_proxy = ""; $Env:https_proxy = "";
# }

# 重新加载环境变量

function reload {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# 默认启用vpn
vpn

# 配合ssh-agent使用
$env:GIT_SSH = "C:\Windows\System32\OpenSSH\ssh.exe"
```

#### 主题文件

```json
{
    "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
    "blocks": [
        {
            "alignment": "left",
            "newline": true,
            "segments": [
                {
                    "background": "#d75f00",
                    "foreground": "#f2f3f8",
                    "properties": {
                        "alpine": "\uf300",
                        "arch": "\uf303",
                        "centos": "\uf304",
                        "debian": "\uf306",
                        "elementary": "\uf309",
                        "fedora": "\uf30a",
                        "gentoo": "\uf30d",
                        "linux": "\ue712",
                        "macos": "\ue711",
                        "manjaro": "\uf312",
                        "mint": "\uf30f",
                        "opensuse": "\uf314",
                        "raspbian": "\uf315",
                        "ubuntu": "\uf31c",
                        "windows": "\ue70f"
                    },
                    "style": "diamond",
                    "leading_diamond": "\u256d\u2500\ue0b2",
                    "template": " {{ .Icon }} ",
                    "type": "os"
                },
                {
                    "background": "#e4e4e4",
                    "foreground": "#4e4e4e",
                    "style": "powerline",
                    "powerline_symbol": "\ue0b0",
                    "template": " {{ .UserName }}@{{ .HostName }} ",
                    "type": "session"
                },
                {
                    "background": "#0087af",
                    "foreground": "#f2f3f8",
                    "properties": {
                        "style": "full",
                        "max_depth": 3,
                        "folder_icon": "\u2026"
                        // "folder_separator_icon": " <transparent>\ue0b1</> "
                    },
                    "style": "powerline",
                    "powerline_symbol": "\ue0b0",
                    "template": " \ue5ff  {{ .Path }} ",
                    "type": "path"
                },
                {
                    "background": "#378504",
                    "foreground": "#f2f3f8",
                    "background_templates": [
                        "{{ if or (.Working.Changed) (.Staging.Changed) }}#a97400{{ end }}",
                        "{{ if and (gt .Ahead 0) (gt .Behind 0) }}#54433a{{ end }}",
                        "{{ if gt .Ahead 0 }}#744d89{{ end }}",
                        "{{ if gt .Behind 0 }}#744d89{{ end }}"
                    ],
                    "properties": {
                        "branch_max_length": 25,
                        "fetch_stash_count": true,
                        "fetch_status": true,
                        "branch_icon": "\uf418 ",
                        "branch_identical_icon": "\uf444",
                        "branch_gone_icon": "\uf655"
                    },
                    "style": "diamond",
                    "leading_diamond": "<transparent,background>\ue0b0</>",
                    "template": " {{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} <transparent>\ue0b1</> <#121318>\uf044 {{ .Working.String }}</>{{ end }}{{ if .Staging.Changed }} <transparent>\ue0b1</> <#121318>\uf046 {{ .Staging.String }}</>{{ end }}{{ if gt .StashCount 0 }} <transparent>\ue0b1</> <#121318>\uf692 {{ .StashCount }}</>{{ end }} ",
                    "trailing_diamond": "\ue0b0",
                    "type": "git"
                }
                // ,
                // {
                //     "type": "dotnet",
                //     "style": "powerline",
                //     "powerline_symbol": "\uE0B0",
                //     "foreground": "#000000",
                //     "background": "#00ffff",
                //     "template": " \uE77F {{ .Full }} "
                // }
            ],
            "type": "prompt"
        },
        {
            "alignment": "right",
            "segments": [
                {
                    "background": "#e4e4e4",
                    "foreground": "#585858",
                    "properties": {
                        "style": "austin",
                        "always_enabled": true
                    },
                    "invert_powerline": true,
                    "style": "powerline",
                    "powerline_symbol": "\ue0b2",
                    "template": " \uf608 {{ .FormattedMs }} ",
                    "type": "executiontime"
                },
                {
                    "background": "#d75f00",
                    "foreground": "#f2f3f8",
                    "properties": {
                        "time_format": "15:04:05"
                    },
                    "invert_powerline": true,
                    "style": "diamond",
                    "template": " \uf5ef {{ .CurrentDate | date .Format }} ",
                    // "trailing_diamond": "\ue0b0",
                    "type": "time"
                },
                {
                    "type": "exit",
                    "style": "diamond",
                    "foreground": "#ffffff",
                    "background": "#00897b",
                    // "invert_powerline": true,
                    "powerline_symbol": "\ue0b2",
                    "background_templates": [
                        " {{ if gt .Code 0 }} #e91e63 {{ end }} "
                    ],
                    "trailing_diamond": "\ue0b0",
                    // "template": "\uE0B0 \uE23A ",
                    "template": "<#d75f00>\uE0B0</> \uE23A ",
                    // "template": " <#193549>\uE0B0</> \uE23A ",
                    "properties": {
                        "always_enabled": true
                    }
                }
            ],
            "type": "prompt"
        },
        {
            "alignment": "left",
            "newline": true,
            "segments": [
                {
                    "foreground": "#d75f00",
                    "style": "plain",
                    "template": "\u2570\u2500 {{ if .Root }}#{{else}}${{end}}",
                    "type": "text"
                }
            ],
            "type": "prompt"
        }
    ],
    "final_space": true,
    "version": 2
}
```

## 问题处理

- [[笔记/point/wsl|wsl]] 的网络修复

  ```powershell
  # 需要管理员权限
  netsh winsock reset
  ```

- 接触 powershell 的下载限制

  ```powrshell
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

## 相关资源

- [官方参考文档](https://docs.microsoft.com/en-us/powershell)
