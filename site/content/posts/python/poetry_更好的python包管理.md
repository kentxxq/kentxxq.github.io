---
title:  poetry_更好的python包管理
date:   2019-03-05 23:41:00 +0800
categories: ["笔记"]
tags: ["python"]
keywords: ["python","pipenv","venv","poetry","包管理","PyCharm"]
description: "我在学习python过程中，一直想要寻求到最佳实践。因为它意味着当你拿到一份你没有见过的代码时，这种事实标准会帮助到你"
---

> 我在学习python过程中，一直想要寻求到`最佳实践`。
>
> 因为它意味着当你拿到一份你没有见过的代码时，这种事实标准会帮助到你。

使用包管理的原因
===
`pip`和`python`包管理问题
---
1. 单个项目中要把需要的包独立出来，方便部署
2. 不同的项目要求不同的包版本，不能混乱
3. py2和py3或者具体的小版本，区分开来

pipenv vs venv(py3) vs poetry
===
[pipenv](https://github.com/pypa/pipenv)
---
pipenv在github上有15000+的star，commit次数达6000+，这代表着很多人`看好它`,`足够大用户群`,`完善程度较高`。

但是它也存在有问题：  

1. lock太慢。在国内特别特别慢，你需要修改`Pipfile`的`source`才能加速(还是会慢)。
2. 只是单纯用来替代`requirements.txt`文件，没有综合解决setup.py等工具的打包问题

[venv](https://docs.python.org/3/library/venv.html)
---
它是`python官方推荐`的工具。所以(PyCharm，vscode等)对它的支持也会是最好的。  

虽然之前官方包**pyvenv被弃用**了。但是它支持最好，它只有一些基本的功能。

[poetry](https://github.com/sdispater/poetry)
---
使用的人不多，知名度也不高。  

但是没有pipenv的一些问题。这是我比较推荐的一个。  

但也有一个问题。那就是`PyCharm`等等工具是不支持的。

最终选择
===
使用`poetry`,要素:  

1. 简单，快速  
2. 综合了**setup.py**，所以极有可能以后成为**事实标准**，对任何开发者都更加方便。  
3. PyCharm不是你的常用首选工具  

为什么我加上第三点呢？因为PyCharm(vscode对它的支持个人觉得不实用)支持pipenv。在ide内安装包，很方便啊。而且我没有遇到速度慢的问题,不清楚是不是ide自己做了处理。  

PyCharm默认的情况下，是使用virtualvenv，它和venv几乎没有什么区别。方便就好啊!  

poetry在PyCharm呢？去命令行里装。虽然更直接。但是你可能记不清具体的包名？想看看最新的版本号？PyCharm都给你解决了。


杂谈
===
`requests`的确是个很好用的库。  

那是因为python标准库在一开始没有设计好，而后有很多的开发者加入了requests的贡献行列，所以很厉害。  
但是并不是他开发的所有东西都是最适合你的。你需要自己去体验它。  

他的库，总有用`for humans`来标榜自己。其他人写的难道就不是给人用的啦？  
虽然很多人都这样创造了好用的工具，但是pipenv显然还不是那么好。
