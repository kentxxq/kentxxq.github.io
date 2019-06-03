---
title:  入坑Xamarin初探
date:   2019-05-10 00:46:00 
categories: ["笔记"]
tags: ["C#","Xamarin"]
keywords: ["C#","Xamarin","iOS","Android","visual studio","微软","跨平台开发"]
description: "在之前无意中了解到了linq，被超级方便的语法吸引到了。开始认真了解C#以及微软的现状。github被微软收购以后开放了免费的无限量私人仓库。C#自举且一系列生态代码完全开源。net core跨平台且目标是替代framework系列。浏览器开始使用chrome相同的内核且融合了ie模式，却被谷歌摆了一道。还有云平台，ide等等一系列的动作。这些做法让我对微软的好感度急剧攀升。无意间了解到Xamarin，更是让我不得不想叫一句：微软爸爸。"
---




> 在之前无意中了解到了linq，被超级方便的语法吸引到了。开始认真了解C#以及微软的现状。
>
> github被微软收购以后开放了免费的无限量私人仓库。C#自举且一系列生态代码完全开源。net core跨平台且目标是替代framework系列。浏览器开始使用chrome相同的内核且融合了ie模式，却被谷歌摆了一道。还有云平台，ide等等一系列的动作。
>
> 这些做法让我对微软的好感度急剧攀升。无意间了解到Xamarin，更是让我不得不想叫一句：微软爸爸。


为什么会有这篇文章
===
在最近了解了一系列微软的技术发展动态后，一个**不能停止学习**的程序员应该体会到，如果不去了解它(微软的技术栈)，沉溺在公司现有的技术栈，会导致视野越来越小。甚至几年以后，与公司外部世界技术脱轨。

从技术方面来说，微软有这些值得注意的点:

1. c#/c++/xaramin等等技术的全面开源。可以在使用微软技术栈的同时，更好的学习知识(或者排坑)。
2. 积极拥抱社区，为Chromium内核项目提交代码。发布WSL2支持原生linux内核，秒级启动！同时支持docker技术！
3. 从net5的blog来看，以后windows会放弃net framework，而使用net core。
![Xamarin_dotnet5规划](/images/csharp/Xamarin_dotnet5规划.png)
4. 随着vs/vsc和微软服务绑定增多，开发越来越方便。vsc remote等理念非常前沿，甚至可以说是未来的开发模式！

从上面可以得出，学好了微软技术栈在开发中可以有以下优势:

1. 类似java，可以跨平台运行。同时在windows上，可以不用安装运行环境！
2. 对于普通用户来说，跨平台就是一个伪需求。在xp电脑上能双击打开的exe才是王道。
3. xaramin可以开发移动端app(iOS/Android)，且拥有庞大的社区。
4. 对比js写的windows客户端，C#性能不用担心。


Xamarin初步了解
===
**一个跨平台UI开发的解决方案**。

对比原生语言。同时开发iOS，Android应用，且代码的复用率高。

对比js跨平台。性能有优势。

对比flutter技术。dart是一个不主流的语言。且如果flutter胎死腹中(指fuchsia无法代替安卓)，那你学了dart语言以后，几乎没有用武之地！因为几乎没有公司用dart来编写除flutter以外的项目。

![Xamarin_框架对比图](/images/csharp/Xamarin_框架对比图.png)

前期准备工作
===
只需要傻瓜化安装vs，即可完成整个开发环境的搭建。[vs官方文档](https://docs.microsoft.com/zh-cn/visualstudio/products/?view=vs-2019)是最好的教程了。且中文！

参见[Xamarin官方文档](https://docs.microsoft.com/zh-cn/xamarin/get-started/first-app/?pivots=windows)，数据线连接在安卓手机上开启debug模式。点击即可运行。

而iOS则属于排坑之旅了。

排坑之旅
===

iOS开发
---

1. 你需要一个mac电脑。或者参考[云mac](https://www.macincloud.com/)，我没用过，也不推荐这样。
2. 最好有一个iPhone，因为模拟器耗资源，且不方便操作。
3. 装好xcode
4. 新建跨平台应用的时候注意你的应用名称和组织标识符
![新建项目](/images/csharp/Xamarin_新建项目.png)
5. 用Apple ID[申请成为开发者](https://developer.apple.com/account/)。**如果你有付费的开发者账号可以按照Xamarin官网的方法来，否则继续往下看**。
6. Xcode随便新建一个项目，关键`Bundle Identifier`要一致。打开**Xcode=>Preferences=>Accounts**，。然后添加你自己的账号。Manage Certificates。
![xcode登陆](/images/csharp/Xamarin_xcode登陆.png)

---
![xcode证书](/images/csharp/Xamarin_xcode证书.png)

---
![xcode完成签名](/images/csharp/Xamarin_xcode完成签名.png)
7. 回到General，钩上自动signing。team选择自己personal team。等一会就ojbk了！
![xcode签名ojbk](/images/csharp/Xamarin_xcode签名ojbk.png)
8. 回到**vs=>左上角kentxxq_app.iOS=>Debug=>你的iPhone**,启动项目吧！

生成apk
---
在生成apk文件的时候，记得选择release来生成。否则apk的大小会非常惊人。

笑容逐渐展露
===
开始写代码。参考官方文档，试一下**闪光灯和语音功能**！

为什么呢？因为我记得好久以前iPhone没有自带手电筒的功能，我是通过app下载的。而且一个调用了硬件，语音功能则调用了软件。

```xml
<?xml version="1.0" encoding="utf-8"?>
<ContentPage xmlns="http://xamarin.com/schemas/2014/forms" xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml" xmlns:local="clr-namespace:kentxxq_app" x:Class="kentxxq_app.MainPage">
    <StackLayout>
        <!-- Place new controls here -->
        <Label Text="Welcome to Xamarin.Forms!" HorizontalOptions="Center" VerticalOptions="CenterAndExpand" />
        <Button Text="说话" Clicked="Speak_Word"/>
        <Button Text="开闪光灯" Clicked="Open_Flashlight"/>
        <Button Text="关闪光灯" Clicked="Close_Flashlight"/>
    </StackLayout>
</ContentPage>
```

```cs
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xamarin.Forms;
using Xamarin.Essentials;

namespace kentxxq_app
{
    // Learn more about making custom code visible in the Xamarin.Forms previewer
    // by visiting https://aka.ms/xamarinforms-previewer
    [DesignTimeVisible(true)]
    public partial class MainPage : ContentPage
    {
        public MainPage()
        {
            InitializeComponent();
        }

        protected async void Open_Flashlight(object sender,EventArgs e)
        {
            try
            {
                // Turn On
                await Flashlight.TurnOnAsync();
            }
            catch (Exception ex)
            {
                
            }
        }

        protected async void Close_Flashlight(object sender, EventArgs e)
        {
            try
            {
                // Turn On
                await Flashlight.TurnOffAsync();
            }
            catch (Exception ex)
            {

            }
        }


        protected async void Speak_Word(object sender, EventArgs e)
        {
            await TextToSpeech.SpeakAsync("Hello World");
        }

    }
}
```

ojbk!!!后面就慢慢自己深入学习吧！

总结
===
开发工具安装挺方便的，只是开发环境比较耗硬盘空间。

Android开发还是很方便的。就是iOS的开发太麻烦了。

为了开发方便，vs的mac版本右边有一个模拟窗口。cpu占用也不高。windows版本则最好通过xamarin hotload插件来支持热重载。

最后留一下自己的[demo地址](https://github.com/a805429509/kentxxq_app)