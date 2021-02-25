---
title:  flutter的入门之路
date:   2019-05-19 17:30:00 +0800
categories: ["笔记"]
tags: ["dart","flutter"]
keywords: ["dart","flutter","dart包管理","跨平台","Future","async","闪光灯"]
description: "之前了解了一下xamarin，也写过关于xamarin的一篇记录。而flutter的用途也一样是用于开发跨平台UI。flutter的编写语言是dart，爸爸是谷歌。所以推崇者比xamarin要多得多。大公司的跟进也更多。如果连一个hello world都没有写过的话，那怎么能去对比呢？就像现在网上的用户对比手机，连手机都没有，就去云评测？"
---


> 之前了解了一下xamarin，也写过关于xamarin的一篇记录。而flutter的用途也一样是用于开发跨平台UI。
> 
> flutter的编写语言是dart，爸爸是谷歌。所以推崇者比xamarin要多得多。大公司的跟进也更多。
> 
> 如果连一个hello world都没有写过的话，那怎么能去对比呢？就像现在网上的用户对比手机，连手机都没有，就去云评测？

## 安装

请参考[flutter官网](flutter.dev)。我反正是一次性就弄好了。

如果弄不好，重装系统或者弄个虚拟机吧。

说真的，开发环境都弄不好的话。说明你对操作系统和语言开发相关的知识太差了。


## 移动开发的hello world

之前在[入坑xamarin初探](https://kentxxq.com/contents/%E5%85%A5%E5%9D%91xamarin%E5%88%9D%E6%8E%A2/)就有对比各个框架的优劣。

既然是移动开发，那就照样写一个带控制闪光灯的hello world，没想到就坑到了。。

### 使用现成的依赖包

谷歌搜了一下，发现lamp和torch这两个包可以满足我的需求。

flutter的这些工具包是如何跨平台的呢？

1. 先用android和ios的原生开发语言kolin/java和swift把功能实现好。
2. 然后用dart打包好，提供给用户调用。

而经过我的躺坑，torch的ios编译无法通过。swift的编译不通过。貌似是版本之类问题。

而lamp也一样有坑。ios可以正常使用。Android中无响应。后面发现是因为用了老的api。所以找到了一个别人改进之后的版本。正常完成工作。

### 添加依赖
`pubspec.yaml`文件中如下:

```yml
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^0.1.2
  english_words: ^3.1.5 
  http: ^0.12.0+2
  tip_dialog: ^2.0.0
  lamp:
    git: 
      url: https://github.com/a805429509/flutter_lamp.git
```

其中http是一个公共库上已经存好了的包。

而lamp则是直接导入我github上的地址。

### 代码实例

1. 首先引入了lamp包。
2. 定义了2个void方法，实现了开灯和关灯。
3. 在页面上有2个按钮，onPressed对应到方法

```dart
import 'package:flutter/material.dart';
import 'package:lamp/lamp.dart';

void main()=>runApp(MyToolsPage());

class MyToolsPage extends StatelessWidget {
  void _openflashlight() {
    Lamp.turnOn();
  }

  void _closeflashlight() {
    Lamp.turnOff();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            MaterialButton(
              color: Colors.blue,
              child: Text('开灯'),
              onPressed: _openflashlight,
            ),
            MaterialButton(
              color: Colors.orange,
              child: Text('关灯'),
              onPressed: _closeflashlight,
            )
          ],
        ),
      ),
    );
  }
}

```

### 权限问题
在lamp的文档中写了在android里要加入权限的请求，但是我没有加，也能用。

我的安卓测试机器是小米a1，属于国际版。系统是谷歌的android go，和国内的手机环境会有不一样。苹果用的是X。

所以还是贴一下吧。`app_dir/android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.FLASHLIGHT" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-feature android:name="android.hardware.camera.flash" />
```

### 关于打包

flutter主要有3种打包，或者说生成app的版本。

1. debug
2. profile
3. release

`debug`是给你用来做开发测试用的。安装包会非常大。

`profile`会流畅很多。一般都是用来测试流畅度，比如看看能不能有60fps。

`release`就是用来给用户的版本。

## 有用的一点记录

1. snackBar可以用来提示用户更新成功等等类似的提示。
2. initState用来初始化状态，记得第一行一般都要写super.initState()。
3. setState来更新组件状态，刷新界面。
4. tabController用来控制ListView。类要继承SingleTickerProviderStateMixin，TabBarView和TabBar共用这个controller，初始化用_tabController = new TabController(vsync: this, length: 3)，数量必须要一致。销毁的时候在dispose加上_tabController.dispose()
5. 函数加上async，就一定返回的是Future。可以是`Future<void>`。
6. GlobalKey来生成唯一的key，用这个key可以找到这个对象。然后_scaffoldKey.currentState.showSnackBar显示SnackBar


## 总结
flutter的上手速度还是比较快的。但是时间没有xamarin长，所以像lamp这样的包，还是会有bug的存在。需要自己排坑。

js做的app是性能最差的。但是用的人最多。js火得不行，一些pwa，微信小程序，快应用等等快速发展。肯定是有前景的。

xamarin其实早在2012年就开始了，可却不温不火。但微软的c#在不久的将来就会统一生态，windows的地位也不可撼动。如果以后真的发布了surface phone，那xamarin也会大放异彩。

flutter性能算是3个里面最好的。甚至能和原生来比。但是时间也是最短的，有很多坑。同时它有谷歌的支持，新的fuchsiaOS也是用的flutter来写。如果真的替代了安卓呢？前景也很不错。

这还只是跨平台开发，还有原生技术呢？

学好一门东西。然后解决所有的问题。如果不能解决。那么就引入新的元素来解决新的问题。

按场景来选择技术才是王道。

最后留一下自己[demo地址](https://github.com/a805429509/flutter_app)

## 更新

**20200330**: 这个项目发现跑不起来了。。明天研究一下kotlin，修复一下吧。。
