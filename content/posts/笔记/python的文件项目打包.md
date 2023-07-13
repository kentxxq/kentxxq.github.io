---
title: python的文件项目打包
tags:
  - blog
  - python
date: 2017-10-19
lastmod: 2023-07-11
categories:
  - blog
keywords:
  - "python"
  - "项目打包"
description: "在自己的机器还有服务器上面，都应该搭建好pyenv。网络上的教程太多了，但是说的又很乱。所以自己稍微整理一下。这次的目的是写一个及其简单的过程，所以如果有具体问题，请看官方文档"
---

## 简介

打算自己做一个 [[笔记/point/python|python]] 项目, 然后推到 pypi 上去.

这次的目的记录**写一个及其简单的过程**，所以如果有具体问题，请看官方文档。

### 先看目录结构

```python
$ tree
.
├── MANIFEST.in
├── README.md
├── myapp
│   ├── 1.txt
│   ├── __init__.py
│   ├── __pycache__
│   │   ├── __init__.cpython-36.pyc
│   │   └── test.cpython-36.pyc
│   ├── test.py
│   └── txt
│       └── 1.txt
├── myapp2
│   └── test222.py
└── setup.py

4 directories, 10 files
```

1. `MANIFEST.in` 用来记录除了 py 文件外，需要打包的文件

```bash
# 包含文件
include README.md
# 递归-包含
recursive-include myapp/txt *
```

2. `README.md` 一个用来简单介绍的文档

3. `myapp` 和 `myapp2` 都是存放代码

4. `setup.py` 是用来安装和打包的主要文件

```python
# -*- coding: utf-8 -*-

from setuptools import setup, find_packages

setup(
    name='kentxxq',               # 项目名
    version='1.0.2',              # 版本号
    zip_safe=False,               # 因为部分工具不支持zip，推荐禁用
    packages=find_packages(),     # 当前目录下所有的包
    include_package_data=True,    # 启用清单文件MANIFEST.in
    install_requires=[    # 依赖列表
        "Scrapy>=1.4.0",
    ]

    # 上传到PyPI所需要的信息
    author="kentxxq",
    author_email="805429509@qq.com",
    description="This is an Example Package",
    license="PSF",
    keywords="hello world example examples",
    url="https://a805429509.github.io/",
)
```

### 运行打包

```bash
python setup.py sdist

# 构建物在这里
dist/kentxxq-1.0.2.tar.gz
```

### 开始安装

直接拷贝 `dist/kentxxq-1.0.2.tar.gz` 到目标机器，进行解压。

```bash
python setup.py install
```

### 安装完成后，查看安装结果

```bash
$ tree kentxxq-1.0.2-py3.6.egg
kentxxq-1.0.2-py3.6.egg
├── EGG-INFO
│   ├── dependency_links.txt
│   ├── not-zip-safe
│   ├── PKG-INFO
│   ├── requires.txt
│   ├── SOURCES.txt
│   └── top_level.txt
└── myapp
    ├── __init__.py
    ├── __pycache__
    │   ├── __init__.cpython-36.pyc
    │   └── test.cpython-36.pyc
    ├── test.py
    └── txt
        └── 1.txt

4 directories, 11 files
```

1. 没有 `__init__.py` 的 myapp2 是没有打包的。
2. myapp 中 1.txt 没有进入包内，而 MANIFEST.in 中的记录的 `recursive-include myapp/txt *` 在包内。
