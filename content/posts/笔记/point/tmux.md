---
title: tmux
tags:
  - point
  - tmux
date: 2023-08-06
lastmod: 2023-08-09
categories:
  - point
---

`tmux` 是一种终端工具. 帮助你保存会话, 分屏.

要点:

- 免费
- 分屏

#todo/笔记 配合 trzsz 使用

## 配置

```shell
vim /etc/tmux.conf

# 鼠标右键可分屏,拖动窗口大小
set -g mouse on
# 默认关闭窗口需要按y确认,这一行去掉确认
bind-key & kill-window
```

## 使用

```shell
# 安装
apt install tmux -y

# 查看会话
tmux ls
# 新建会话
tmux new -s 别名
# 更换别名
tmux rename-session -t 0或者别名xx xx2
# 杀死会话
tmux kill-session -t 0或者别名xx
# 进入会话
tmux a [-t 0或者别名xx]


# 下面的开头都是Ctrl+b
# 更换当前会话别名
Ctrl+b $

# 窗口,一个会话可以多个窗口
# 新建一个窗口
Ctrl+b c
# 窗口列表选择/切换会话
Ctrl+b w
# 切换窗口
Ctrl+b n/p
# 关闭当前窗口
Ctrl+b &

# 左右分屏
Ctrl+b %
# 上下分屏
Ctrl+b "



# 注意使用英文输入法
# 按下 ctrl+b，然后松开键盘，按 d
# 退出但是保持会话
Ctrl+b d
```
