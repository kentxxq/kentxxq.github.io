---
title:  我对go语言的了解
date:   2019-05-11 16:46:00 +0800
categories: ["笔记"]
tags: ["go"]
keywords: ["go"]
description: "一直刷知乎，有很多go语言的推崇者。不少大企业也有java转go的项目。所以就了解了一下hello world和语法相关的东西。今天写这个文章的原因，是因为cgo"
---


> 一直刷知乎，有很多go语言的推崇者。不少大企业也有java转go的项目。所以就了解了一下hello world和语法相关的东西。
>
> 今天写这个文章的原因，是因为cgo。


go语言简介
===

我看到的go优点
---
1. 性能好。不输java。
2. 编译快，且可以生成二进制文件。你的代码部署只需要拷贝上去，执行它。这一点优于c/c++。
3. 静态类型比动态类型更好避免低级错误。优于python/js等。
4. 语言级别的并发。简单的语法。

我看到的go缺点
---
1. 虽然有不错的标准库，但是对比python/java/js生态方面还是差一些。
2. nil这个东西无处不在！看过不少代码，都存在这个问题。
3. 如果包含有cgo，不方便交叉编译且编译速度慢。

关于交叉编译
===

概念
---

`交叉编译`也就是无论我在何种环境下开发程序，我都可以打包成对应的的二进制程序。

一个纯go项目，我在mac下开发的。可以直接编译成在Windows/iOS/Android/linux下可执行的文件。

如果包含了c代码，则会变得麻烦。

遵循了POSIX标准的C/C++程序源代码，可以直接在Linux/BSD环境下用GCC编译，或者在windows下用Cygwin/MinGW编译(Cygwin、MinGW提供了跨操作系统的兼容编译)。这叫`跨操作系统的编译`。

常见的一些手机都是arm体系的。而你的开发是在linux之类的x86体系。那么你就需要用到arm-linux-gcc编译器，来把你的代码编译成可执行代码。这叫`交叉编译/也就是跨体系的编译`。

举例说明,我的项目需要连接oracle数据库。但是没有纯go的连接驱动，必须使用cgo。

纯go的交叉编译
---

先准备好package
```bash
go get gopkg.in/goracle.v2
```

下载好[oracle的免安装客户端](https://www.oracle.com/technetwork/topics/intel-macsoft-096467.html)

解压以后,放到`~/lib/`路径下，代码就能找到它了。
```bash
sudo cp /Users/kentxxq/kent_file/instantclient_18_1/{libclntsh.dylib.18.1,libclntshcore.dylib.18.1,libons.dylib,libnnz18.dylib,libociei.dylib} ~/lib/
```

`test.go`文件代码如下
```go
package main

import (
	// "database/sql"
	"fmt"

	// _ "gopkg.in/goracle.v2"
)

func main() {
	fmt.Println("Hello, World!")

	// db, _ := sql.Open("goracle", "username/password@192.168.0.2:1521/orcl")
	//// sql.Open在官方文档中有写，可能只是验证了字符串格式。必须使用Ping命令来测试
	// if err := db.Ping(); err != nil {
	// 	fmt.Println("连接失败！")
	// 	fmt.Println(err.Error())
	// 	return
	// }
	// fmt.Println("连接成功")
	// db.Close()
}
```

进入项目目录$GOPATH/src/myapp，在mac下生成test二进制文件，目标平台为linux arm。没有问题。
```bash
CGO_ENABLED=0 GOOS=linux GOARCH=arm go build test.go
```

这里我们用go成功的进行了交叉编译。跨体系，跨操作系统！

**而你如果把注释的代码去掉，你就会发现无法编译通过**

包含cgo的交叉编译
---
要想在对应的操作系统直接执行二进制文件。只有2种办法。

1. 在对应的平台上本地编译。
2. 在自己的机器上配置各种编译器的开发环境，然后交叉编译。

纯go写的代码，可以非常简单的在本地进行交叉编译。
```bash
# 在纯go项目中，无论本机在什么平台，直接可以生成linux arm的二进制代码
CGO_ENABLED=0 GOOS=linux GOARCH=arm go build test.go
```

而包含c代码的go项目就麻烦多了。

你在一个大型go项目中，你负责编写连接oracle数据库相关的操作。在你的Windows本机上，你搭建好了linux服务器的交叉编译环境，在编译的时候设置`CC=mips-linux-gnu-gcc`,`CXX=mips-linux-gnu-g++`等等一系列的参数。生成的二进制文件可以在linux上直接运行。**而和你一同在Windows上开发的同事们没有这个环境，他们在本机上就不能成功编译出linux下的可执行文件。他们也必须人手一套编译器环境**。

如果你的代码非常底层，非常核心。必须要在Windows/mac/linux/Android等等系统上，跨x86和arm体系运行。那么就不只是一套编译器环境了。**开发环境的复杂度陡增**。

那怎么解决呢？运用docker技术，把所有的编译器环境都搭建好。然后每次把代码放到docker里编译。

使用docker来交叉编译
---

[xgo](https://github.com/karalabe/xgo)是一个非常好用的工具。

1. 装好[docker](https://docs.docker.com/install/)环境
2. 拉取xgo准备好的镜像`docker pull karalabe/xgo-latest`
3. xgo命令可以帮助你省掉很多参数命令`go get github.com/karalabe/xgo`

我的`go env`环境
```bash
# kentxxq @ kentxxq-MBP in ~/go/src/myapp [1:15:39] 
$ go env                    
GOARCH="amd64"
GOBIN=""
GOCACHE="/Users/kentxxq/Library/Caches/go-build"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="darwin"
GOOS="darwin"
GOPATH="/Users/kentxxq/go"
GOPROXY=""
GORACE=""
GOROOT="/usr/local/Cellar/go/1.12.4/libexec"
GOTMPDIR=""
GOTOOLDIR="/usr/local/Cellar/go/1.12.4/libexec/pkg/tool/darwin_amd64"
GCCGO="gccgo"
CC="clang"
CXX="clang++"
CGO_ENABLED="1"
GOMOD=""
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/var/folders/6k/fcg4pk951vq7vp9gj035m0wr0000gn/T/go-build267314503=/tmp/go-build -gno-record-gcc-switches -fno-common"
```

我的代码目录`/Users/kentxxq/go/src/myapp`
```bash
# kentxxq @ kentxxq-MBP in ~/go/src/myapp [1:17:06] 
$ ls
test.go
```

进入代码目录，使用命令`xgo --targets=linux/amd64 .`
```bash
$ xgo --targets=linux/amd64 .
Checking docker installation...
Client: Docker Engine - Community
 Version:           18.09.2
 API version:       1.39
 Go version:        go1.10.8
 Git commit:        6247962
 Built:             Sun Feb 10 04:12:39 2019
 OS/Arch:           darwin/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          18.09.2
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.6
  Git commit:       6247962
  Built:            Sun Feb 10 04:13:06 2019
  OS/Arch:          linux/amd64
  Experimental:     true

Checking for required docker image karalabe/xgo-latest... found.
Cross compiling myapp...
Building locally myapp...
Compiling for linux/amd64...
Cleaning up build environment...

# kentxxq @ kentxxq-MBP in ~/go/src/myapp [1:17:50] 
$ ls
myapp-linux-amd64 test.go
```

(前提是你在linux也安装了oracle的客户端，且数据库连接参数正确)拷贝到linux下，连接成功！


总结
===
我了解了很多种的编程语言。很多语言我都只是写一个`hello world`级别的例子，而这个例子中必须要有的部分，就是连接数据库。

python/ruby/js这样的解释性语言在运行的时候，都离不开c/c++。在连接oracle的过程中，你不会觉得有什么问题。因为你总是要把代码都拷贝到服务器上。

java/c#的oracle驱动，则是纯java/c#写的。所以你的程序跑起来，并不需要安装客户端。

而go语言并没有纯go编写的驱动。你在编写go代码的时候，非常想在本机生成目标机器的可执行二进制文件。你就不得不使用我刚才说到的docker交叉编译。因为如果是arm开发版，你忍受不了在那样的配置上面编译代码。

其实java的代码是非常容易反编译的。然后可以根据代码，得到SQL*NET的协议。跟着写一个纯go项目的oracle驱动。但是这是一个法律问题。

这也就是go的生态问题。一个10年的语言。不少的方方面面，都有这c代码的影子。虽然丰富了生态，却也产生了不便。

不可否认go语言还是很优秀的。否则docker和区块链等等技术也不会想着来用它。值得学习。

