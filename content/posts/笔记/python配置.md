---
title: python配置
tags:
  - blog
date: 2024-12-23
lastmod: 2024-12-23
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
