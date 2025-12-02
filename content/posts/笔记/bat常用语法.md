---
title: bat常用语法
tags:
  - blog
  - windows
date: 2023-08-15
lastmod: 2023-08-15
categories:
  - blog
description: "这里记录 [[笔记/point/windows|windows]] 的 bat 脚本常用语法.推荐用 [[笔记/point/powershell|powershell]] 脚本, 而不是 bat."
---

## 简介

这里记录 [[笔记/point/windows|windows]] 的 bat 脚本常用语法.

> 推荐用 [[笔记/point/powershell|powershell]] 脚本, 而不是 bat.

## 语法

### echo

```
echo hello
输出显示 hello
```

### 写入和追加

```
echo hello >e:\1.txt     覆盖1.txt文件，写入hello        
echo hello >>e:\1.txt    往1.txt末尾追加字符串 hello
```

### 注释 rem

```
rem 开始执行xxx
> bat里面的注释，在执行过程中，不会输出
```

### 跳转 goto

```
goto 指定代码块
> 执行完以后，按照当前位置执行下面的代码，有可能进入死循环
----------------------------------------------------
goto :eof
> 可以终止此次的跳转
```

### 终止程序 exit

==无论是否嵌套了 bat 执行，执行到 exit，一切终止==

### 代码块

`:xx`

```
goto xx
> 跳转到xx这个代码块，之后按照顺序执行
```

### 条件判断 if

`if %errorlevel%==0 (goto a) else (goto b)`

```
如果上一条语句执行成功 跳转到a
否则  跳转到b
```

### 时间日期

%date:~0,10% %time:~0,8%

```
echo %date:~0,10% %time:~0,8%
输出显示 2016/08/20  4:07:08
>截取%date%的前10位，%time%的前八位
```

### 调用脚本 call

```
call e:\1.bat    调用另外一个bat脚本
1.bat中，如果结尾是goto:eof 或者无，则跳转回来
1.bat中，如果结尾是exit,则调用的主bat也会退出！
```

### 循环 forfiles

```
forfiles /p 路径文件夹 /s /m *.* /d -800 /c "cmd /c del @file"
/s 扫描子目录
/m 指定扫描类型
/d 指定天数 -800 代表800天前的文件
/c 指定的命令
cmd /c 隐式执行
```

### 其它

```
>flashfxp 上传下载
d:\FlashFXP\flashfxp.exe -c4 -upload ftp://用户名:密码@ip和端口 -localpath="E:\backup\huaxinqu_%date:~0,10%DAY.rar" -remotepath="/backup/huaxinqu_%date:~0,10%DAY.rar"
-download/-upload 下载上传
-c1 打开软件执行    -c4 执行完毕后关闭
```

## 示例

![[附件/bat备份流程.png]]

```bat
echo 开始备份  %date:~0,10% %time:~0,8%    >> E:\1.txt
expdp system/"""密码""" directory=EXPDP_DIR exclude=STATISTICS,INDEX dumpfile=huaxinqu_%date:~0,10%DAY.dmp logfile=huaxinqu_%date:~0,10%DAY.log network_link=remote_hydb  tables=qx_huaxin.t_zs101_06

if %errorlevel%==0 (goto cg1) else (goto sb1)


:sb1
echo 备份失败 %date:~0,10% %time:~0,8%>> E:\1.txt
exit
 
:sb2
echo 压缩失败 %date:~0,10% %time:~0,8%>> E:\1.txt
exit

:sb3
echo ftp上传失败 %date:~0,10% %time:~0,8%>>E:\1.txt
exit

:cg1
echo 备份成功  %date:~0,10% %time:~0,8% >> E:\1.txt
echo 开始压缩  %date:~0,10% %time:~0,8%  >> E:\1.txt
C:\progra~1\winrar\winrar.exe a -ibck E:\backup\huaxinqu_%date:~0,10%DAY.rar E:\backup\huaxinqu_%date:~0,10%DAY.DMP E:\backup\huaxinqu_%date:~0,10%DAY.log   
if %errorlevel%==0 (goto cg2) else (goto sb2)

:cg2
echo 压缩成功  %date:~0,10% %time:~0,8% >> E:\1.txt
echo 开始ftp上传  %date:~0,10% %time:~0,8% >> E:\1.txt
d:\FlashFXP\flashfxp.exe -c4 -upload ftp://用户名:密码@ip和端口 -localpath="E:\backup\huaxinqu_%date:~0,10%DAY.rar" -remotepath="/backup/huaxinqu_%date:~0,10%DAY.rar"    
if %errorlevel%==0 (goto cg3) else (goto sb3) 

:cg3
echo ftp上传成功  %date:~0,10% %time:~0,8% >> E:\1.txt
del /f E:\backup\huaxinqu_%date:~0,10%DAY.dmp
del /f E:\backup\huaxinqu_%date:~0,10%DAY.log
if %errorlevel%==0 (echo 删除本地文件成功！ %date:~0,10% %time:~0,8% >>E:\1.txt) else (echo 删除本地文件失败！ %date:~0,10% %time:~0,8% >>E:\1.txt  )
```
