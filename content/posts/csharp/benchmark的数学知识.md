---
title:  benchmark的数学知识
date:   2021-08-15 00:00:00 +0800
categories: ["笔记"]
tags: ["csharp","benchmark"]
keywords: ["C#","benchmark","性能","指标"]
description: "程序性能总是一个永恒的话题。各个系统、编程语言、算法、io逻辑，总是不停的对比。今天在dotnet闲逛的时候，看到了官方做的一个性能评测库，但是指标我却看不懂。于是就看了一会儿相关知识，准备记录一下"
---

> 程序性能总是一个永恒的话题。各个系统、编程语言、算法、io逻辑，总是不停的对比。今天在dotnet闲逛的时候，看到了官方做的一个性能评测库，但是指标我却看不懂。于是就看了一会儿相关知识，准备记录一下。


## 程序说明

抄了一个官方的demo。很简单，就是在对比`md5`和`sha256`两者的性能。

```cs
using System;
using System.Security.Cryptography;
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Jobs;
using BenchmarkDotNet.Running;

namespace Cli
{
    public class Md5VsSha256
    {
        private const int N = 10000;
        private readonly byte[] data;

        private readonly SHA256 sha256 = SHA256.Create();
        private readonly MD5 md5 = MD5.Create();

        public Md5VsSha256()
        {
            data = new byte[N];
            new Random(42).NextBytes(data);
        }

        [Benchmark]
        public byte[] Sha256() => sha256.ComputeHash(data);

        [Benchmark]
        public byte[] Md5() => md5.ComputeHash(data);
    }
    class Program
    {
        static void Main(string[] args)
        {
            var summary = BenchmarkRunner.Run<Md5VsSha256>();
        }
    }
}
```

## 输出分析

首先需要将代码release。因为这样会对代码进行优化。让我们的性能观测更加准确。

接下来就是查看我们的输出结果。

```sh
BenchmarkDotNet=v0.13.1, OS=Windows 10.0.22000
Intel Core i5-10210U CPU 1.60GHz, 1 CPU, 8 logical and 4 physical cores
.NET SDK=5.0.400
  [Host]     : .NET 5.0.9 (5.0.921.35908), X64 RyuJIT
  DefaultJob : .NET 5.0.9 (5.0.921.35908), X64 RyuJIT

| Method |     Mean |    Error |   StdDev |
|------- |---------:|---------:|---------:|
| Sha256 | 48.94 us | 0.947 us | 1.197 us |
|    Md5 | 19.58 us | 0.356 us | 0.315 us |

Mean   : Arithmetic mean of all measurements
Error  : Half of 99.9% confidence interval
StdDev : Standard deviation of all measurements
1 us   : 1 Microsecond (0.000001 sec)
```

**Mean**代表平均值。举例我们有100次样本，这时候`Mean=所有样本时间/100`。也就是说可以看做是平均时间。

**Error**代表标准误差。标准误越小，样本均值和总体均值差距越小，那么样本数据就越能代表总体数据。标准误是多次抽样统计，量化了多组测量值均值的变化程度。因此用于推论统计，越小对Mean的结果推论越准确。

**StdDev**代表标准偏差。标准差越小，样本值之前的差别越小。标准差是一次抽样，量化了一组测量值的变化程度，用于描述统计。而我们的测试中用到了所有的样本(all measurements)，所以这里我们可以知道Mean和实际请求时间相差多少us。

## 总结

我们通过结果和概念，可以得到以下信息
1. `Mean`是此次性能测试的平均值。得到信息是：md5是比sha256要快的。
2. `Error`表明如果我们做更多的测试。sha256所花费的时间，预计是Mean加减0.947us。而md5预计是Mean加减0.356us。得到的信息是：准确性还是不错的。
3. `StdDev`表明在此次测试中，sha256偏差是加减1.197us。md5偏差是加减0.315us。得到的信息是：此次测试中每次花费的时间差别不大。