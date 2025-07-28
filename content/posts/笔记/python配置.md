---
title: python配置
tags:
  - blog
date: 2024-12-23
lastmod: 2025-07-03
categories:
  - blog
description: 
---

## 简介

记录一下 [[笔记/point/python|python]] 的配置.

## 安装

普通安装

- 搜索 `winget search python`
- 安装 `winget install Python.Python.3.13`
- 安装 pipx `py -m pip install --user pipx`
- 配置 pipx `py -m pipx ensurepath`

新工具安装

- `winget install --id=astral-sh.uv  -e`

## 配置源

- 运行完命令, 会显示配置文件路径
    - `pip config set global.index-url http://mirrors.aliyun.com/pypi/simple/`
    - `pip config set global.trusted-host mirrors.aliyun.com`

效果如下

```ini
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
trusted-host = mirrors.aliyun.com
```

## 新工具

- [Astral · GitHub](https://github.com/astral-sh)
    - [uv](https://github.com/astral-sh/uv) 会取代 [rye](https://github.com/astral-sh/rye). 但是现阶段 rye 更好用
    - 这个机构下面还有 [ruff](https://github.com/astral-sh/ruff) 用于 lint 格式化
- PDM [README\_zh.md](https://github.com/pdm-project/pdm/blob/main/README_zh.md)
- Poetry [Introduction | Documentation | Poetry - Python dependency management and packaging made easy](https://python-poetry.org/docs/)

### uv

安装

1. 下载二进制文件 [Releases · astral-sh/uv](https://github.com/astral-sh/uv/releases) 到 `/usr/local/bin/`
2. 配置镜像源到 `~/.bashrc`

```shell
export UV_DEFAULT_INDEX=https://mirrors.aliyun.com/pypi/simple/
export UV_PYTHON_INSTALL_MIRROR=https://gh-proxy.com/https://github.com/astral-sh/python-build-standalone/releases/download
```

使用

- 命令工具
    - `uv tool` 可以用来代替 `pipx`:  
    - 添加 `$PATH` 路径 `export PATH="/root/.local/bin:$PATH"`
    - 安装 `uv tool install ansible-core`
    - 常用命令 `uv tool upgrade/uninstall/list`  , 查看安装路径 `uv tool dir`
- 安装 python
    - 最新版本 `uv python install`
    - `uv python list` 查看所有的版本, 包括系统自带的
- 运行脚本
    - `uv run 1.py` 运行脚本
- 项目
    - `uv init hi` : 会创建项目文件夹, 锁定 python 版本
    - `pyproject.toml` 添加镜像源

        ```toml
        [[tool.uv.index]]
        url = "https://mirrors.aliyun.com/pypi/simple/"
        default = true
        ```

    - `uv add requests`: 创建 `.venv` 环境, 锁包 `uv.lock`
