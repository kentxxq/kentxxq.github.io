---
title: shell教程
tags:
  - blog
  - shell
date: 2023-08-10
lastmod: 2023-08-10
categories:
  - blog
description: "虽然我不喜欢写 [[笔记/point/shell|shell]],但其实 [[笔记/point/shell|shell]] 是高效的."
---

## 简介

虽然我不喜欢写 [[笔记/point/shell|shell]],但其实 [[笔记/point/shell|shell]] 是高效的.

这里记录一些用法和技巧.

## 常用技巧

### 基础

```shell
# 变量
a="a1"
```

### If 条件

```shell
if condition1
then
    command1
elif condition2 
then 
    command2
else
    commandN
fi
```

### case-when 分支

```shell
case 值 in
模式1)
    command1
    command2
    ...
    commandN
    ;;
模式2)
    command1
    command2
    ...
    commandN
    ;;
esac

# 示例
echo '输入 1 到 4 之间的数字:'
echo '你输入的数字为:'
read aNum
case $aNum in
    1)  echo '你选择了 1'
    ;;
    2)  echo '你选择了 2'
    ;;
    3)  echo '你选择了 3'
    ;;
    4)  echo '你选择了 4'
    ;;
    *)  echo '你没有输入 1 到 4 之间的数字'
    ;;
esac
```

### 循环

`break` 和 `continue` 可以跳出和继续循环.

#### for 循环

```shell
for var in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done

# 一行
for var in item1 item2 ... itemN; do command1; command2… done;


# 高级用法
# for file in $(ls /etc)
for file in `ls /etc`
do
    head -n 1 $file
done
```

#### while 循环

```shell
while condition
do
    command
done

# 循环5次
int=1
while(( $int<=5 ))
do
    echo $int
    let "int++"
done
```

#### 无限循环

```shell
# 1
while :
do
    command
done

# 2
while true
do
    command
done

# 3
for (( ; ; ))
```

## 拓展内容

### 行匹配 + 计算

```shell
# 使用正则/Mem/匹配某一行.
# 第三个字段/第二个字段*100,取2位余数
free | awk '/Mem/{printf("%.2f"), $3/$2 * 100}'
```
