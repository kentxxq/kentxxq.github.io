---
title: 让hugo支持wikilink
tags:
  - blog
  - hugo
date: 2023-06-26
lastmod: 2023-07-11
keywords:
  - hugo
  - wikilink
  - hugo
  - dart-sass
  - goldmark-wikilink
categories:
  - blog
description: "在我决定使用 [[笔记/point/obsidian|obsidian]] 来记录笔记后, 就发现有 `wikilink` 这个东西, 它不是 [CommonMark](https://commonmark.org/) 的一部分, 所以会导致很多的工具链的不兼容. 例如 [[笔记/point/vscode|vscode]] 默认无法读取.而我选择用 [hugo](point/hugo.md) 进行站点的构建发布. 所以这篇博客就如题目所说的, 我要打通 [[笔记/point/hugo|hugo]] 和 [[笔记/point/obsidian|obsidian]] ,所以就有了这一篇文章.我搭建了一个 demo 站点, 你可以看看 [效果](https://doit-demo.kentxxq.com/)."
---

## 前情提要

在我决定使用 [[笔记/point/obsidian|obsidian]] 来记录笔记后, 就发现有 `wikilink` 这个东西, 它不是 [[笔记/point/CommonMark|CommonMark]] 的一部分, 所以会导致很多的工具链的不兼容. 例如 [[笔记/point/vscode|vscode]] 默认无法读取.

而我选择用 [hugo](point/hugo.md) 进行站点的构建发布. 所以这篇博客就如题目所说的, 我要打通 [[笔记/point/hugo|hugo]] 和 [[笔记/point/obsidian|obsidian]] ,所以就有了这一篇文章.我搭建了一个 demo 站点, 你可以看看 [效果](https://doit-demo.kentxxq.com/).

## 我做了什么

### 原理

1. [[笔记/point/hugo|hugo]] 默认使用 [goldmark](https://github.com/yuin/goldmark/) 进行 markdown 的渲染.
2. [goldmark](https://github.com/yuin/goldmark/) 可以通过插件支持 wikilink.
3. [abhinav 的 goldmark-wikilink](https://github.com/abhinav/goldmark-wikilink) 这个插件与我的主题, 笔记路径, url 配置**不兼容, 需要进行调整**.
4. 改 [[笔记/point/hugo|hugo]] 代码, 加入配置, 编译构建.
5. 编写 github actions 发布工具.

### 准备 goldmark-wikilink

首先 fork 一份 [goldmark-wikilink](https://github.com/abhinav/goldmark-wikilink) 代码到 [我的仓库](https://github.com/kentxxq/goldmark-wikilink).

改动 [go.mod](https://github.com/kentxxq/goldmark-wikilink/blob/main/go.mod)

```go
module github.com/kentxxq/goldmark-wikilink
```

改动 [resolver.go](https://github.com/kentxxq/goldmark-wikilink/blob/main/resolver.go), 添加解析代码. 下面是伪代码, 讲一下我做了什么:

```go
// 默认解析,看起来不错
//	[[Foo]]      // => "Foo.html"
//	[[Foo bar]]  // => "Foo bar.html"
//	[[foo/Bar]]  // => "foo/Bar.html"
//	[[foo.pdf]]  // => "foo.pdf"
//	[[foo.png]]  // => "foo.png"
var DefaultResolver Resolver = defaultResolver{}

// hugo默认路径是/Foo/,所以我加了一个PrettyResolver解决这个问题
// 关于url的路径切换可以参考文档 https://gohugo.io/content-management/urls/#appearance
//  [[Foo]]      // => "Foo/"
var PrettyResolver Resolver = prettyResolver{}

// 当我的obsidian笔记wikilink使用`相对于当前文件的路径`时
//  /root/Foo.md                 url: /root/Foo/
//  /root/a.md include [[Foo]] . url: /root/a/    wikilink: /root/a/Foo/ not found!
//  所以我加上了RelResolver
//  [[Foo]]      // => "../Foo/"    worked!
var RelResolver Resolver = relResolver{}

// 但其实obsidian中使用这样的格式并不好看.我改成了`相对于项目根路径`后
// when i use pretty url with [[absolute path]]
//  /Foo.md                      url: /posts/Foo/
//  /a.md include [[root/Foo]] . url: /posts/a/    wikilink: /posts/a/posts/Foo/ not found!
//  so...
//  [[Foo]]      // => "/root/Foo/" worked!
var RootResolver = func(b string) Resolver {
	return &rootResolver{
		base: b,
	}
}


var pretty_html = []byte("/")

// 相对路径就是在最前面加上../,变成请求上一级目录
var rel_head = []byte("../")

type relResolver struct{}

func (relResolver) ResolveWikilink(n *Node) ([]byte, error) {
	dest := make([]byte, len(rel_head)+len(n.Target)+len(pretty_html)+len(_hash)+len(n.Fragment))
	var i int
	if len(n.Target) > 0 {
		i += copy(dest, rel_head)
		i += copy(dest[i:], n.Target)
		if filepath.Ext(string(n.Target)) == "" {
			i += copy(dest[i:], pretty_html)
		}
	}
	if len(n.Fragment) > 0 {
		i += copy(dest[i:], _hash)
		i += copy(dest[i:], n.Fragment)
	}
	return dest[:i], nil
}


// 绝对路径就是传入前缀,然后直接加上wikilink的内容即可
type rootResolver struct {
	base string
}

func (r rootResolver) ResolveWikilink(n *Node) ([]byte, error) {
	dest := make([]byte, len(r.base)+len(n.Target)+len(pretty_html)+len(_hash)+len(n.Fragment))
	var i int
	if len(n.Target) > 0 {
		i += copy(dest, []byte(r.base))
		i += copy(dest[i:], n.Target)
		if filepath.Ext(string(n.Target)) == "" {
			i += copy(dest[i:], pretty_html)
		}
	}
	if len(n.Fragment) > 0 {
		i += copy(dest[i:], _hash)
		i += copy(dest[i:], n.Fragment)
	}
	return dest[:i], nil
}

```

### 改动 hugo

同样 fork 一份 [[笔记/point/hugo|hugo]] 代码到 [我的仓库](https://github.com/kentxxq/hugo).

安装依赖 `go get github.com/kentxxq/goldmark-wikilink`.

改动 [markup/goldmark/goldmark_config/config.go](https://github.com/kentxxq/hugo/blob/master/markup/goldmark/goldmark_config/config.go),加入配置参数

```go
type Extensions struct {
	Typographer    Typographer
	Footnote       bool
	DefinitionList bool

	// GitHub flavored markdown
	Table            bool
	Strikethrough    bool
	Linkify          bool
	LinkifyProtocol  string
	TaskList         bool

	// 下面是我们新加的参数
	// 采用那种方法解析链接?
	WikilinkReslover string
	// ROOT模式下,传入路径前缀
    WikilinkRootPath string
	// 是否启用wikilink
	EnableWikilink   bool
}
```

改动 [markup/goldmark/convert.go](https://github.com/kentxxq/hugo/blob/master/markup/goldmark/convert.go),让我们的配置和 wikilink 解析器生效.

```go
import (
	"bytes"

	"github.com/gohugoio/hugo/identity"

	"github.com/gohugoio/hugo/markup/goldmark/codeblocks"
	"github.com/gohugoio/hugo/markup/goldmark/goldmark_config"
	"github.com/gohugoio/hugo/markup/goldmark/images"
	"github.com/gohugoio/hugo/markup/goldmark/internal/extensions/attributes"
	"github.com/gohugoio/hugo/markup/goldmark/internal/render"

	"github.com/gohugoio/hugo/markup/converter"
	"github.com/gohugoio/hugo/markup/tableofcontents"
	wikilink "github.com/kentxxq/goldmark-wikilink" //引入解析
	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/ast"
	"github.com/yuin/goldmark/extension"
	"github.com/yuin/goldmark/parser"
	"github.com/yuin/goldmark/renderer"
	"github.com/yuin/goldmark/renderer/html"
	"github.com/yuin/goldmark/text"
)

	extensions = append(extensions, images.New(cfg.Parser.WrapStandAloneImageWithinParagraph))
	// 加入
	if mcfg.Goldmark.Extensions.EnableWikilink {
		switch mcfg.Goldmark.Extensions.WikilinkReslover {
		case "DefaultResolver":
			extensions = append(extensions, &wikilink.Extender{
				Resolver: wikilink.DefaultResolver,
			})
		case "PrettyResolver":
			extensions = append(extensions, &wikilink.Extender{
				Resolver: wikilink.PrettyResolver,
			})
		case "RelResolver":
			extensions = append(extensions, &wikilink.Extender{
				Resolver: wikilink.RelResolver,
			})
		case "RootResolver":
			extensions = append(extensions, &wikilink.Extender{
				Resolver: wikilink.RootResolver(mcfg.Goldmark.Extensions.WikilinkRootPath),
			})
		}
	}

```

### 配置 dart-sass

下载 [Releases · sass/dart-sass](https://github.com/sass/dart-sass/releases) 的对应系统版本, 我用的 `dart-sass-1.63.6-windows-x64.zip`.解压后配置到环境变量里. ![[附件/dart-sass环境变量.png]]

打开终端验证效果

```powershell
sass --version
1.63.6
```

### 开始构建代码

```powershell
$GOOS=windows
$GOARCH=amd64
$CGO_ENABLED=1
$CC="gcc"
$CXX="g++"

# 构建命令
# -v 详细信息
# -x 打印出执行的命令，以及相关的详细信息
# extended是加入sass,release则是hugo自定义
# `-s` 表示禁用符号表，`-w` 表示禁用 DWARF 调试信息，`-extldflags '-static'` 表示使用静态链接方式进行链接。
go build  -v -x -tags extended,release -ldflags "-s -w -extldflags '-static'"
# 文件夹多出一个hugo.exe
```

### hugo 预览

```powershell
# 克隆我的示例代码
git clone https://github.com/kentxxq/doit-demo.git
# 注意hugo.toml文件加入了如下配置
EnableWikilink = true
WikilinkRootPath = "/posts/"
WikilinkReslover = "RootResolver"

# 启动3333端口
cd doit-demo
hugo server --disableFastRender -p 3333
```

访问 [http://localhost:3333](http://localhost:3333) 看看效果吧.

## 相关资料

- 除非 [[笔记/point/CommonMark|CommonMark]] 添加对 wikilink 的支持, [[笔记/point/hugo|hugo]] 可能永远都不会有 wikilink 了. [Support wiki-style internal page links · Issue #3606 · gohugoio/hugo · GitHub](https://github.com/gohugoio/hugo/issues/3606#issuecomment-1555955974)
- 除了让 [[笔记/point/hugo|hugo]] 在渲染阶段支持 wikilink, 还可以再主题内进行 url 的处理,例如 [[笔记/obsidian发布hugo-quartz|obsidian发布hugo-quartz]].但是这样的主题很少...
