---
title: wsl
aliases:
  - wsl2
tags:
  - point
  - wsl
date: 2023-06-29
lastmod: 2023-08-07
categories:
  - point
---

`wsl` 是 [[笔记/point/windows|windows]] 下面的 [[笔记/point/linux|linux]] 子系统. 方便开发人员在 windows 上使用 linux.

要点:

- 打通了文件系统
- 网络互通
- 支持 linux 图形界面

## 相关内容

### 管理工具

[wsl2-distro-manager简称WSL-Manager](https://github.com/bostrot/wsl2-distro-manager/wiki) 可以帮助操作

- 鼠标启停
- 磁盘位置选择
- 备份
- 清理无用

### 启用 systemd

默认不是 [[笔记/point/Systemd|Systemd]] 守护进程. 改动如下

- WSL-Manager =>某实例=>设置=>WSL 设置=>启动=>勾选 Systemd
- 操作如下:

    ```shell
    vim /etc/wsl.conf
    [boot]
    systemd=true
    
    # 重启生效
    ```

### 禁用 windows 下的 PATH

- 配置文件

    ```shell
    vim /etc/wsl.conf
    [interop]
    appendWindowsPath = false

    # 重启生效
    ```
