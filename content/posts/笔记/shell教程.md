---
title: shell教程
tags:
  - blog
  - shell
date: 2023-08-10
lastmod: 2024-12-26
categories:
  - blog
description: "虽然我不喜欢写 [[笔记/point/shell|shell]],但其实 [[笔记/point/shell|shell]] 是高效的."
---

## 简介

虽然我不喜欢写 [[笔记/point/shell|shell]],但其实 [[笔记/point/shell|shell]] 是高效的.

这里记录一些用法和技巧.

## 常用内容

### 一行命令

```shell
# 循环ssh不同机器执行命令
for i in {12..17};do ssh root@l0.0.0.si "ifconfig grep -Al flannel.1";done
# 也可以用 for i in item1 item2 ... itemN;
```

### 基础

#### 变量

```shell
# 变量,优先使用双引号(可以有变量,转移字符)
a="a1"
# 拼接
greeting_1="hello, ${a} !"
# 相等
$a == ${a}
# 长度
${#a}
# 从位置0开始截取长度1
${a:0:1}

# 只读
readonly a
# 删除变量
unset a
```

#### 数组

```shell
array_name=(value0 value1 value2 value3)

array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen

# 取值必须用${}包围
# 取得数组元素的个数,也可以length=${#array_name[@]}
length=${#array_name[*]}
# 单个元素
lengthn=${#array_name[n]}


# 键值对就是自己设置下标,其他使用完全一致
declare -A site
site["google"]="www.google.com"
site["runoob"]="www.runoob.com"
site["taobao"]="www.taobao.com"

echo ${site["runoob"]}
```

#### 参数

```shell
echo "执行的文件名: $0";
echo "第一个参数为: $1";
echo "第二个参数为: $2";
echo "第三个参数为: $3";
echo "参数个数: $#";
echo "进程号: $$";
echo "演示\$*"
for i in "$*"; 
do 
    echo $i  
done;
echo "演示\$@"
for var in "$@"; 
do 
    echo $var 
done;

echo "执行的文件名: $0";
echo "第一个参数为: $1";
echo "第二个参数为: $2";
echo "第三个参数为: $3";
echo "参数个数: $#";
echo "进程号: $$";
echo "演示\$*"
for i in "$*"; 
do 
    echo $i  
done;
echo "演示\$@"
for var in "$@"; 
do 
    echo $var 
done;
echo "退出码 $?"
```

### If 语法

```shell
if condition1;
then
    command1;
elif condition2;
then 
    command2;
else
    commandN;
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

### 计算

```shell
val1=`expr 2 + 2`
# 乘法必须转义
val2=`expr 2 \* 2`
```

### 函数

```shell
funWithParam(){
    echo "第一个参数为 $1 !"
    echo "第二个参数为 $2 !"
    echo "第十个参数为 $10 !"
    echo "第十个参数为 ${10} !"
    echo "第十一个参数为 ${11} !"
    echo "参数总数有 $# 个!"
    echo "作为一个字符串输出所有参数 $* !"
}
funWithParam 1 2 3 4 5 6 7 8 9 34 73
```

### 重定向

```shell
# > 覆盖写入文件,  >> 追加到文件
# /dev/null可以丢弃

touch 1.txt
# stdout输出到1.txt,stderr显示到屏幕
ls 1.txt 2.txt > 1.txt
# stdout输出到1.txt,stderr输出到2.txt
ls 1.txt 3.txt > 1.txt 2>2.txt

# 注意!!! 2>&1永远不变, 而>1.txt或者>>1.txt决定覆盖或者追加 
# stdout和stderr都输出到1.txt
ls 1.txt 2.txt >1.txt 2>&1
# 新版本写法,crontab就不兼容..建议不用
ls 1.txt 2.txt &>1.txt
```

### 包含外部 shell 文件

```shell
#使用 . 号来引用test1.sh 文件
. ./test1.sh

# 或者使用以下包含文件代码
source ./test1.sh
```

## 拓展内容

### 条件判断

```shell
# $memory_usage默认字符串,所以无法比较
if (( $(echo "$memory_usage > 1" | bc -l) )) ; then
    echo "2"
fi

# 检测字符串长度是否为0，为0返回 true
if (( -z $a ))
# 检测字符串长度是否不为 0，不为 0 返回 true
if (( -n $a ))
# 字符串不为空,返回true
if (( $a ))

file="/tmp/1.txt"
# 是目录,返回true
if (( -d $a ))
# 是文件,返回true
if (( -f $a ))
# 存在,返回true
if (( -e $a ))
# 文件大小大于0
if (( -s $a ))
```

### 调试/报错

```shell
# 开启调试.可以看到变量值和执行命令情况
set -x
# 出错就停止返回非0
set -e
```

### 行匹配 awk

```shell
# 使用正则/Mem/匹配某一行.
# 默认是空格分隔,可以 -F ',' 指定逗号分隔
# 第三个字段/第二个字段*100,取2位余数
free | awk '/Mem/{printf("%.2f"), $3/$2 * 100}'
```

### 循环 seq+ 打印 printf

```shell
# seq 100 生成序列
# 输出的时候 .0 去掉了序列里的值,所以只会输出井号
echo `printf '#%.0s' $(seq 100)`
```

### 查找字符串 expr

```shell
string="runoob is a great site"
echo `expr index "$string" io`  # 输出4.因为o在第4个,i在第8位
```

### 输出变成输入

```shell
/root/kubeconfigs/kubectl get pods -n default -o name --kubeconfig qs-test-kube.conf | while read pod; do 
    echo $pod 
    /root/kubeconfigs/kubectl exec $pod -n default --kubeconfig qs-test-kube.conf -- ss -anp | grep 3306 | wc -l 
done
```

## 代码示例

### 内存检测重启 nginx

> `*/10 * * * * /opt/memory-check.sh >>/tmp/memory_check.log 2>&1`

```shell
#!/bin/bash
echo `date +'%Y-%m-%d %H:%M:%S'`
memory_usage=`free | awk '/Mem/{printf("%.2f"), $3/$2 * 100}'`
echo "内存使用率为$memory_usage"

if (( $( echo "$memory_usage > 80" | bc -l ) )); then
    /usr/local/nginx/sbin/nginx -t;
    if (( $? == 0 )); then
        echo "配置检查没问题,开始reload nginx"
        /usr/local/nginx/sbin/nginx -s reload;
        if (( $? == 0 )); then
            echo "reload完成"
        else
            echo "reload失败"
        fi
    fi
fi
echo "====================================="
```

### 清空 log 结尾的日志文件

> `0 3 * * * /opt/rm-log.sh`

```shell
#!/bin/bash
files=`find / -name '*.log'`
for file in $files
do
  truncate -s 0 $file
done
```

### 同步 nginx 配置

1. 先要对远程主机进行 [[笔记/linux命令与配置#免密 ssh|免密 ssh]]
2. `chmod +x sync_nginx.sh`
3. 移动到 `mv sync_nginx.sh /usr/local/bin/sync_nginx.sh`

```shell
#!/bin/bash

# 本地验证配置是否ok
/usr/local/bin/nginx -t
# 验证没问题，就reload
if [ $? -eq 0 ]; then
    # 返回值为0，表示执行成功
    echo "本地验证成功"
    # 执行xxx操作
    /usr/local/bin/nginx -s reload
    echo "nginx reload完成"
else
    echo "本地验证失败，停止运行"
    exit 1;
fi

# 远程主机验证
host_list=("stage-prod-nginx2")
for host in "${host_list[@]}"
do
    echo "$host 开始同步配置文件..."
    # 同步下面3个路径
    /usr/bin/rsync -atvP --delete /usr/local/nginx/conf/nginx.conf "root@$host:/usr/local/nginx/conf/nginx.conf"
    /usr/bin/rsync -atvP --delete /usr/local/nginx/conf/hosts/*.conf "root@$host:/usr/local/nginx/conf/hosts/"
    /usr/bin/rsync -atvP --delete /usr/local/nginx/conf/options/*.conf "root@$host:/usr/local/nginx/conf/options/"
    /usr/bin/rsync -atvP --delete /data/files/* "root@$host:/data/files/"
    # 远程测试nginx配置
    /usr/bin/ssh "root@$host" "/usr/local/bin/nginx -t"
    # 远程机器测试成功，进行reload
    if [ $? -eq 0 ]; then
        # 返回值为0，表示执行成功
        echo "$host 验证成功"
        # 执行xxx操作
        /usr/bin/ssh "root@$host" "/usr/local/bin/nginx -s reload"
        echo "$host nginx reload完成"
    else
        echo "$host 验证失败，停止运行"
        exit 1;
    fi
done
```
