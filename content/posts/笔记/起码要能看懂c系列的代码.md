---
title: 起码要能看懂c系列的代码
tags:
  - blog
  - c
date: 2019-08-29
lastmod: 2023-07-11
categories:
  - blog
keywords:
  - "c"
  - "c++"
  - "python"
  - "指针"
  - "动态库"
  - "静态库"
  - "入门"
description: "之前在一些文章里面就有说过。程序员是绕不过JavaScript的，即使有时候会恶心到人。。而很多硬件的嵌入式开发，算法工程师，底层开发人员则真的可以做一辈子，而免疫JavaScript的侵扰。而JavaScript的每一个改动，都多多少少与c/c++有关。可以说大神们用c/c++构建了现在数字化的底层逻辑。比c更底层的，晦涩难懂且开发效率低下，甚至人写的代码经常不如c编译器优化后的代码。比c高级的，性能下降且概念繁多。和c同级别的，都没有c混得好。c是事实标准"
---

## 前言

如果你从来没有了解过编程，而想学习 [[笔记/point/c|c]]。那么去搜新手教程慢慢上手。

如果你有其他编程的基础。这篇文章能用来让你快速了解 c 代码。可以在你不得不去看 c 代码的时候，看懂他的意图。

> 之前在一些文章里面就有说过。程序员是绕不过 [[笔记/point/js|js]] 的，即使有时候会恶心到人。。
>
> 而很多硬件的嵌入式开发，算法工程师，底层开发人员则真的可以做一辈子，而免疫 JavaScript 的侵扰。而 JavaScript 的每一个改动，都多多少少与 c/c++ 有关。
>
> 可以说大神们用 c/c++ 构建了现在数字化的底层逻辑。比 c 更底层的，晦涩难懂且开发效率低下，甚至人写的代码经常不如 c 编译器优化后的代码。比 c 高级的，性能下降概念繁多。和 c 同级别的，都没有 c 混得好。事实上 c 是事实标准。

## 基本了解

### 类型

二进制的 c 表达，需要用代码实现

```python
# python用0b开头
a = 0b101
```

八进制

```c
// c用0开头
int a = 08
```

```python
# python用0o开头  数字0和字母o
a = 0o516
```

十六进制

```c
// c用0x开头
int a = 0x2A
```

```python
# python用0x开头
a = 0x2A
```

其中 int 是 2 个字节。long int 是 4 个字节。

而 float 是 4 个字节。double 是 8 个字节。long double 是 16 个字节。注意在计算的时候，可能存在舍入误差。

char 一个字符一个字节。

字符串则会比 char 多出来一个尾部的 `\0` 字节。

unsigned 则代表没有符号位。例如 int 类型前面都会有一个符号位。没有符号位则会扩大 int 的可存储范围

附带补充一点知识。

![[附件/C_补码.png]]

数组

```c
int a[10];
// 10个长度，空位补0
int b[10]={1,2,3,4,5};
// 自动检测到长度
int b[]={1,2,3,4,5};
```

而字符串就这样表示

```c
// 长度会是4，因为后面还有一个\0
char c[]="C a";
```

说几个常用的字符串函数吧

1. `strcat` 合并
2. `strcpy` 拷贝
3. `strcmp` 比较
4. `strlen` 拿到字符串长度

### 函数部分

1. 函数其实没什么好说的。记得除了库函数 (自带标准库),都要定义一下。才能用。
2. 全局变量默认在静态存储区。
3. 加了 `static` 的局部变量也在静态存储区。
4. `register` 的变量会放在寄存器，会提高性能。
5. 外部变量用 `extern` 声明，则可以在代码中使用。

### 预处理命令

1. `#define PI 3.1415` 用 PI 替代代码中的 3.1415。`#undef PI` 取消。

```c
// 可以带参数。
#define SQ(y) (y)*(y)
/* 但注意扩起来。否则可能结果有误 */
/* 例如sq=SQ(a+1)会变成sq=a+1*a+1 */
```

2. `#include "stdio.h"` 引入头文件。一般都用双引号先从当前目录查找。
3. `#ifdef #else #endif` 用来判断执行。`#if` 则非 0 则为 true。

### 指针

示例代码

```c
// 声明int变量a和int指针*p
int a,*p;
a=10;
// 把a的地址给p
p=&a;
// 现在用*p即可取到a的值
printf('%d',*p);
```

1. 指针如果指向数组，则默认指向数组的第一个元素。可以通过 `*(p+1)` 取到第二个元素的值。字符串同理。
2. 函数也是占用连续的内存段。则 `int (*pf)();` 代表指向一个返回值是 int 的函数。当指针赋值后，通过 `(*pmax)(a)` 调用。
3. `int *ap(int x,int y)` 代表返回指针。

语法 | 说明
--- | ---
int i; | 定义整型变量 i
int *p; | p 为指向整型数据的指针变量
int a[n]; | 定义整型数组 a，它有 n 个元素
int *p[n]; | 定义指针数组 p，它由 n 个指向整型数据的指针元素组成
int (*p)[n]; | p 为指向含 n 个元素的一维数组的指针变量
int f(); | f 为带回整型函数值的函数
int *p(); | p 为带回一个指针的函数，该指针指向整型数据
int (*p)(); | p 为指向函数的指针，该函数返回一个整型值
int **p; | P 是一个指针变量，它指向一个指向整型数据的指针变量

优先级为：()>[]>*。然后从左往右看。

### 结构体

如果你理解了前面所说的指针，那么指针就会很好理解。其实就是一系列的基本类型放在一个连续的内存段中。

```c
// 声明一个结构体
struct human {
    int num;
    char name[20];
    char sex;
};
// human结构的变量
struct human {
        int num;
        char *name;
        char sex;
}boy;
// 5个human结构组成的数组变量
struct human {
        int num;
        char *name;
        char sex;
}boy[5];
// 带上初始化的值
struct human
{
    int num;
    char *name;
    char sex;
}boy[5]={
          {101,"Li ping",'M'},
          {102,"Zhang ping",'M'},
          {103,"He fang",'F'},
          {104,"Cheng ling",'F'},
          {105,"Wang ming",'M'},
};
```

取值赋值:boy.num

数组类似普通数组:boy[i].num

指针:struct human *ph

指针取值:ph->num 或 (*ph).num

### 动态分配

很多时候不确定需要多大空间的时候，通过传参来实现。

```c
// 分配一个100字节长度字符数组，pc为指向这个字符数组
pc=(char *)malloc(100);
// 分配2个struct human结构体的长度。ps为指针且指向这个数组
ps=(struet human*)calloc(2,sizeof(struct human));
// 接收指针变量，释放它
free(pc);
free(ps);
```

### typedef

用 typedef 加在 struct 前面，变量名写 HUMAN，就可以用 HUMAN h1,h2 来声明变量了！简洁明了。

```c
typedef int INTEGER;
INTEGER a,b;
typedef char NAME[20];
// 在和预定义不同的是，这是在编译器进行的。
NAME a1,a2,s1,s2;
// 等效
char a1[20],a2[20],s1[20],s2[20]
```

### 位运算

位运算方面其实和其他语言的区别不大。看到应用最多的地方是权限方面的。自己对着文档看吧。我反正是觉得不好理解，不爱用。

### 文件操作

其实到了文件操作部分，就开始用前面学到的知识来进行延伸了。

- `File *fp;` 声明一个指针变量，文件类型。这并不是一个特殊的语法。我的 mac 上可以看到定义，是一个结构体。

```c
typedef	struct __sFILE {
	unsigned char *_p;	/* current position in (some) buffer */
	int	_r;		/* read space left for getc() */
	int	_w;		/* write space left for putc() */
	short	_flags;		/* flags, below; this FILE is free if 0 */
	short	_file;		/* fileno, if Unix descriptor, else -1 */
	struct	__sbuf _bf;	/* the buffer (at least 1 byte, if !NULL) */
	int	_lbfsize;	/* 0 or -_bf._size, for inline putc */

	/* operations */
	void	*_cookie;	/* cookie passed to io functions */
	int	(* _Nullable _close)(void *);
	int	(* _Nullable _read) (void *, char *, int);
	fpos_t	(* _Nullable _seek) (void *, fpos_t, int);
	int	(* _Nullable _write)(void *, const char *, int);

	/* separate buffer for long sequences of ungetc() */
	struct	__sbuf _ub;	/* ungetc buffer */
	struct __sFILEX *_extra; /* additions to FILE to not break ABI */
	int	_ur;		/* saved _r when _r is counting ungetc data */

	/* tricks to meet minimum requirements even when malloc() fails */
	unsigned char _ubuf[3];	/* guarantee an ungetc() buffer */
	unsigned char _nbuf[1];	/* guarantee a getc() buffer */

	/* separate buffer for fgetln() when line crosses buffer boundary */
	struct	__sbuf _lb;	/* buffer for fgetln() */

	/* Unix stdio files get aligned to block boundaries on fseek() */
	int	_blksize;	/* stat.st_blksize (may be != _bf._size) */
	fpos_t	_offset;	/* current lseek offset (see WARNING) */
} FILE;
```

- `fp=("/home/a.txt","r");` 只读方式打开制定文件，后面的参数类似 python。

- `ch=fgetc(fp);` 取第一个字符赋值给 ch。

- `fputc('a',fp);` 弄一个字符串到到指针位置。

- `fgets(str,n,fp);` 从 fp 中取 n-1 个字符 (即字符串) 到 str 这个 char 数组中。为什么是 n-1(一般也是 str 长度 -1)，因为字符串后面要有一个 '\0' 啊！ 它读取到换行符或者文件结尾会停止。
str 这个数组我试过几个不同的大小。发现 4096(4k) 是一个门槛，小于它可能会影响性能。而我看到 python 默认使用的是系统 buffer 大小 8192(8k 即 2 个 block)。现在的文件系统多数都是 4k 为一个 block，而 io 一般最少存取一个 block。那么设置成 2 个 block，也有助于更快的对下一个 block 数据块进行操作，而更大的话就没有太大意义了，可能会浪费磁盘 io 导致占用过多的资源。

- `fputs(“abcd“,fp);` 把字符串放到指针位置。这里传递的是字符串，其实传递的就是字符数组首地址。所以如果是 char *b="abcd" 要进行传递，直接传递 fputs(b,fp) 即可！

- `fread(qq,sizeof(struct stu),2,fp);`qq 是一个指针，表示数据的首地址 (在这里指向一个 stu 结构体)，qq+1 会移动到第二个 stu 结构体。第二个是数据块的大小,第三个是读取几个数据块，fp 是文件指针。

- `fwrite(qq,sizeof(struct stu),2,fp);` 参数同上，只不过是写数据。

- `fscanf(fp,"%d %s",&i,s);` 和 `fprintf(fp,"%d %c",j,ch);` 用来通过第二个参数指定的方式，存放或者打印数据。主义第二个参数中的空格也是会生效的！

- `rewind` 函数把文件指针重新指向头部。

- `fseek(fp,100L,0);` 类似 python 的指针偏移。0 文件首地址，1 当前位置，2 文件末尾。常量表示偏移量必须带上 'L'。移动到离文件首 100 字节距离的位置。也可以直接填写数字。负号前移，正号后移。

**最后说明**EOF 是一个隐藏字符。在读取完了数据以后，才会遇到 EOF。

而 feof() 是通过返回错误来判断是否结束。所以需要先取值，后判断。遇到了 EOF(即 -1) 就会出错。停止下一个循环。

0 是 false，非 0 位 true。

## 编译

简单来说，编译就是使用 `gcc`,`make`,`cmake` 等工具来进行的。

如果使用 vs 或者 clion 这样的工具，需要了解的是工具的使用方法。而下面我要简单说明的是手工编译。

1. 在项目目录下新建 build 文件夹。
2. 进入 build 文件夹使用 `cmake ..` 生成 Makefile
3. 运行 make 命令编译成功，找到输出文件即可。

### linux

我在 centos7 上运行 `gcc`,`make`,`cmake` 都可以正常使用。

### mac

用 brew 安装 cmake 后，也可以跑通。

### windows

我是用的 [scoop](https://scoop.sh/) 安装 cmake。

然后安装最新的 vs。下载 `mingw-get`，然后安装 `mingw32-make`。

```bash
cmake -G   "MinGW Makefiles" . # .为当前目录, "MinGW Makefiles"为makefile类型，如果编译器为vs的话使用"NMake Makefiles"
```

看到了 Makefile 后 mingw32-make 即可。

## 难点

记录一下难以理解的地方。

### 指针数组和数组指针

在看书的时候，了解到 main 函数可以接受 2 个参数。而 main 函数不能被其他函数调用 (有一些编译器不管你这么多，也能编译通过。但是制定标准的委员会明确表明了**不行**)。

`int argc` 代表单数的个数。包括程序自己本身。

`char *argv[]` 代表一个指向字符串的指针数组。

先说一下我之前的**错误想法**吧。

一个指针数组。那么我拿到的就是一个数组。

那么我应该先用 `argv[i]` 拿到数组中的第 i 个指针。然后如何取值呢？用 `*(argv[i])` 取第一个值。可是报错了。

那么我的理解错误在哪呢？下面用 `./helloworld a=1` 来举例。

### 第一点，c 中没有字符串类型。字符串是由字符数组组成，以\0 结尾。字符串又有 2 个声明的方式。

```c
//可以修改指针的地址，但是无法修改原有的值。存储在内存只读段。只要程序在运行，那么就不会释放。
char *a="hehe";
//可以修改。在函数内接收，用完就会释放掉。
char b[]="hehe";
```

c 是如何读取字符串的呢？

在 c 语言中，指向字符和指向字符串的区别只是在于取值，根本就没有指向字符串的指针。从字符串 (字符数组) 的首地址开始取值，一直到\0 结束，那么这个字符串就读完了。

于是根据例子，系统传递给 main 函数的就是 2 个字符数组。也就变成了传递 1 个包含有 2 个 char* 类型指针的指针数组即可。取第 n 个值，就从数组中第 n 个指针所指向的地址取值到\0 即可。

所以 `printf("%s",*a)` 中。*a 取到的值 'h'。而 printf 中指明了要取一个字符串。所以它打印的结果会一直读到\0 才会停止。

### 第二点，要彻底了解的是**数组作为参数的传递**。

1. 我的 main 会得到一个长度为 2 的数组。如果用户还输入了 b=2，c=3 呢？我的的程序是无法预测到用户参数的具体个数。所以 main 函数无法写死数组长度，所以还会有一个 `int argc` 参数告诉我才行。
2. 数组在传递的时候，传递的只是首地址。用一小段代码来理解一下发生了什么。

```c
void test3(int ac,char av[]){
    printf("%p\n",av);
    for (int i = 0; i < ac; ++i) {
        printf("%c",av[i]);
    }
}

void test4(char a){
    printf("%p\n",&a);
}

void test5(char *qt[]){
    printf("%p\n", qt);
}

int main(int argc, char *argv[]) {
    char p='p';
    printf("%p\n",&p);
    test4(p);

    char pch[] = "pch";
    printf("%p\n", pch);
    test3(strlen(pch), pch);

    char *qq[]={"q","w"};
    char **qq2=qq;
    printf("%p\n", qq);
    test5(qq);

    return 0;
}
// 结果
// 0x7ffee0afc77f
// 0x7ffee0afc75f
// 0x7ffee0afc77b
// 0x7ffee0afc77b
// pch
// 0x7ffee81d0770
// 0x7ffee81d0770
```

**先看 test3 和 test4 的结果**。

可以发现 2 个变量的数据存在不同的内存区域，char 类型传递的是 `具体值`，也就是给形参 a 赋值。也即是我在 test4 中修改 a 的值，不会影响到 p 的值。

test3 中 2 个变量的数据为同一内存区域，数组类型传递的是 `值的地址`，也就是让 av 也指向 pch 所指向的地方，于是相同的地址指向同一个值。当我使用 *av 修改值，对应的 pch 值也会变动。

而通过打印，我们会知道。地址指向字符串 (字符数组) 第一个 char。可以用 *av 直接取值。

**C 语言规定，数组名代表数组的首地址，也就是第 0 号元素的地址**。说明我们在声明了 pch 以后，就可以把数组名 pch 看成是一个指针。

那么我们在 test3 函数中，形参也可以写成 char *av(你可以验证看)。

**再看 test5 的结果。发现地址也是一样的**。

同理就可以推断出，传递的是地址，所以 qt 是指针类型。根据结果，指针数组传递的就是第一个指针所指向值的地址。直接 *qt 即可取值。

前面在传递数组的时候，数组名代表着一个指针。同样在传递指针数组的时候，数组名就是第一个元素的地址，而第一个元素是指针。所以数组名 qt 是指针的指针！

那么我们在 test5 函数中，形参也可以写成 char **qt(char **qq2=qq 也侧面验证了 `char**类型` 接收数组变量名 qq)。这也是为什么 main 函数中 char *argv[] 也可以写的 char **argv 的原因了！

得到结论：数组在传递的时候，形参 char* 和 char[] 等效。char**与 char *[] 等效。

同时也说明，数组 [i] 只不过是指针的一个语法糖，相当于 *(指针 +i)。

所以取值如下：

`char **qt` 强调自己是指针。取值常用 `**qt`。

`char *qt[]` 强调自己是数组。取值常用 `qt[0]`。

虽然你的形参是 `char **qt` 也可以用 `qt[0]` 取值。但是不方便理解，且容易出错。

```c
// 你的第一感觉应该是用**rrr取值。
char r='a';
char *rr=&r;
char **rrr=&rr;
// 下面报错
printf("%d\n",rrr[0]);
// 说明要分情况的，char **qt不等同于char *qt[]
```

### 第三点，再来说一下我自己理解错误。

由于之前所接触到的语言，基本的逻辑都是面向对象且没有指针。都是值传递，而不是地址传递。

写过一篇 go 语言的文章，可我没有深入了解过它的指针。经过翻查，发现 go 在数组传递的时候也是值传递。在 go 中，指针是为了减少性能开销存在的。而很少见到有人做指针运算。

而 c 的指针贯穿了整个语言。在进行值传递的时候，形参可以拿到所有信息，因为要进行赋值操作。值传递会让变量名直接取到值。

而地址传递只有一个地址和类型，需要用到取值符 *。且在一个指针指向数组的时候 *p 和 p[0] 等价。

只有搞清楚传递的过程中是值还是地址，才能正确的分析问题。

### 文件读取

### 代码示例

```c
/*文本内容如下
123
哈哈
*/

/* 下面这段代码会正确打印文本内容直到结束 */
int str3;
while ((str3 = fgetc(f1)) != EOF) {
    printf("%c", str3);
}

/* 下面这段代码会多打印一个奇怪的问号符 */
int str2;
while (str2 != EOF) {
    str2 = fgetc(f1);
    printf("%c", str2);
}

/* 下面这段代码会把最后的哈哈打印两次 */
char str[4096];
while (!feof(f1)) {
    fgets(str, 4096, f1);
    printf("%s", str);
}

```

下面来说说为什么。

1. 先看第一个。首先把数据用 fgetc 取出，然后判断是否为 EOF，选择是否打印。没毛病。
2. 第二个则是先判断是否为 EOF，当我们读取到 ' 哈 ' 的时候，先打印出来。然后再判断依旧!=EOF，就会导致把 EOF 读取出来后进行了打印。
3. feof 是通过返回错误 `-1` 来停止循环的。所以在使用的时候先进行读取。在循环了 2 次以后，feof 仍然没有收到错误信息。第三次循环的时候 fgets 其实没有读取到数据。但是下面的语句还是得要执行。

```c
/* 改成这样，最后一次读取到了错误，但是下面没有代码了，什么都没发生。循环条件进行判断后跳出循环。 */
char str[4096];
int c = 0;
fgets(str, 4096, f1);
if (feof(f1)) {
    printf("空文件\n");
} else {
    while (!feof(f1)) {
        printf("%s", str);
        fgets(str, 4096, f1);
    }
}
```

### EOF 和 feof

EOF 和 foef 什么时候用呢？

EOF 主要用于文本文件进行判断结尾。不适合或者说不适用于读取二进制文件。

foef 则都可以使用。

**那么我到底应该怎么读取文件呢？**

下面这个应该是通用版本。无论是二进制还是文本。

```c
FILE *fp,*xx;
int c;
fp=fopen("/Users/kentxxq/test.txt","rb");
xx=fopen("/Users/kentxxq/xx.txt","wb");
if(fp==NULL) {
    printf("文件打开错误");
}else{
    c = fgetc(fp);
    if(ferror(fp)){
        printf("文件读取失败！");
    }else{
        if(feof(fp)){
            printf("这是一个空文件");
        } else{
            while (!feof(fp)){
                printf("%c",c);
                fputc(c, xx);
                c = fgetc(fp);
            }
        }
    }
}
```

### 静态库和动态库

其实我来学 c 相关的知识，最大的动力就是性能以及 c/c++ 有很多的轮子。而我爱用 Python，它与 c 结合非常紧密。

`静态库` 编译完成以后就不需要 lib 和头文件了，所以是打包到了一起。不方便增量更新、且编译速度会慢一些。

`动态库` 编译完成以后其实还是需要从指定的路径取引用库文件。二进制分发的你在通过包管理工具安装以后 (例如 sqlite) 会在系统的 include 和 lib 之类的文件夹存放。源码则可以你自己通过编译放在系统或者自己指定的文件夹内。只要能引用到就好了。

windows 下的静态库为 `.lib` 文件。如果需要使用它，就包含它的头文件。然后 `#pragma comment(lib,"xxx.lib")` 即可直接通过函数名调用。打包后的文件不再 lib 静态库。这是标准做法。

不过我在 vs2019 的实际操作中，略有不同。可参考 [微软官方文档](https://docs.microsoft.com/zh-cn/cpp/build/walkthrough-creating-and-using-a-static-library-cpp?view=vs-2019)

类 *unix 静态库为 `.a` 文件。用法同上。

windows 下的动态库为 `.dll` 文件。

动态库有 2 种用法。第一种是隐式调用。第二种是显式调用。注: 隐式调用若主函数是 C++ 程序,需要 extern "C"{}包含被调用函数 (add.c) 的头文件。动态库的文档可以参考这个 [微软官方文档](https://docs.microsoft.com/zh-cn/cpp/build/walkthrough-creating-and-using-a-dynamic-link-library-cpp?view=vs-2019)

1. 我现在常见的是通过 `LoadLibrary` 来直接加载 dll 文件，然后通过 typedef 来定义一个函数指针声明出被调用函数的返回类型和参数类型，最后通过 `GetProcAddress` 来指定内部函数名得到函数赋值给指针。可以看到我们需要有 dll 文件、函数名、函数指针声明函数。而 python 的 ctypes 通过把传入的参数一一转换成了 c 的对应类型，所以函数指针可以自己推断出来是什么样，而我们给 ctypes 提供了必要的 dll 地址和函数名。所以直接传参即可调用。如果传入的参数错误，就直接报错呗~

2. 通过包含头文件、使用 `#pragma comment(lib,"xxx.lib")` 包含 lib、以及 dll，同静态库也直接通过函数名调用。这里的 lib 文件内部存放的是函数位置和索引。让程序在编译期间使用的。具体的函数体还是存放在 dll 中。

所以动态库两种方法都说明，在打包完程序以后，依旧需要 dll 文件。

类 *unix 动态库为 `.so` 文件。则对应 `dlopen` 和 `dlsym` 来加载和指定函数名。其他原理相同。

我们也知道，windows 一脉相承，提供比较强的兼容性。所以在 windows 上编译后的库，可以兼容多个 windows 版本。

而类 *unix 则不然。多数的做法都是在各个平台上各自编译后分发。

所以也就解决了我对如何使用别人代码库的疑惑。

1. 有源码就下载下来，编译以后你用静态库或者动态库的方式都取决于你。
2. 别人通过二进制分发 (注意选择对应平台的包)，除了 dll 也都会提供.h 的头文件。如果只有一个 dll 呢？那你就对着文档写就一个头文件或者函数指针用。头文件其实和 typedef 函数指针的目的是一样的，让 c/c++ 的代码能获取到函数的相关信息，从而正确编译。因此调用 dll 不用包含头文件也是可以的。只是如果别人做好了库给你用，肯定也会提供给你这个库的调用方法，不提供 h 头文件是他懒！

## 总结

在写这篇文章之前。好久没有写博客了。。偶尔更新一些影片记录而已。

最近也弄了一个域名邮箱，把联系地址改成了邮箱地址。

我大概看了 1 个月的 c 相关的东西。。才写完这点点东西。过程感觉还是很痛苦的，c 语言很简单，但是经常会涉及到系统、编译、环境、调试方面的问题。但是写完以后觉得豁然开朗。对以后的编码也有了更加清晰的理解。

不得不说一句，微软的文档是真的强。。我正在准备彻底抛弃苹果，面向微软。。如果你看不懂这篇文章，取参考微软的文档。毕竟那是 windows 的标准文档啊，绝不会错！
