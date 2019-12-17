---
title:  csv转xlsx文件
date:   2019-12-17 11:45:00 +0800
categories: ["笔记"]
tags: ["python","c#"]
keywords: ["python","c#","csv","xlsx","xlsx"]
description: "我的超级多学习资料，都是通过书签来进行保存的。之前说过好好理一理python，所以打算从python书签开始。python的性能一直被诟病，有多方面的原因。而多进程是解决办法之一"
---

> Excel是大家办公最常遇到的文件之一。一旦需要具体数据的时候，客户都要求这个文件。
>
> 而我用plsql从oracle数据库中查出来以后，一般都是直接导出csv文件。需要手动去wps导入csv，转换成xlsx文件。有时候文件实在是太多了，麻烦。
>
> 于是就有了这个文章。

python代码
===

pyexcel版本
---
这个版本代码最简单的，缺点就是非常慢。100W行的数据[1,2,3,4][2,3,4,5]...需要2分钟！

```python
# 你还需要安装pyexcel-xlsx
from pyexcel import get_sheet

sheet = get_sheet(file_name='/Users/kentxxq/test.csv')

sheet.save_as(filename='/Users/kentxxq/test.xlsx')

print(sheet.number_of_rows())

print('ok')
```

pyexcelerate版本
---
这个看了一个它在测试，确实很快。大概60s。还是不太理想。

```python

import time
from pyexcelerate import Workbook
import csv
import os
from multiprocessing.pool import Pool


def csv_to_xlsx(file):
    start = time.time()
    print('开始处理:'+os.path.split(file)[1])
    with open(file, 'r', encoding='gbk') as f:
        lines = list(csv.reader(f))
        wb = Workbook()
        wb.new_sheet('sheet1', data=lines)
        wb.save(file + '.xlsx')
    end = time.time()
    duration = end-start
    print(os.path.split(file)[1] + '处理完成:' + str(duration) + '秒')


if __name__ == '__main__':
    start = time.time()
    folder = os.path.dirname(__file__) or '.'
    print(folder)
    print('处理开始---------------------------------------')
    p = Pool()
    for root, dirs, files in os.walk(folder):
        for name in files:
            if os.path.splitext(name)[1] == '.csv':
                url = root + '/' + name
                p.apply_async(csv_to_xlsx, args=(url,))
    p.close()
    p.join()
    end = time.time()
    duration = end-start
    print('处理完成---------------------------------------'+str(duration))
```

c#代码
===

epplus版本
---
这个我只用了很少的代码，但是只花了18s左右！
```c#
var format = new ExcelTextFormat();
format.Delimiter = ',';
format.EOL = "\n";
var pck = new ExcelPackage(new FileInfo(@"/Users/kentxxq/xxxx.xlsx"));
var sheet = pck.Workbook.Worksheets.Add("Test1");
sheet.Cells["A1"].LoadFromText(new FileInfo(@"/Users/kentxxq/test.csv"), format,                                                      OfficeOpenXml.Table.TableStyles.None, false);
pck.Save();
```

最后对比
===
我还用wps手动导入了一次这个csv文件，然后光导入就用了36s。保存估计还要花几秒。而且我的wps是台式机的i3-8100+固态。

结果说明了python的性能确实不够。最好用的pyexcel需要120s很夸张。最快的pyexcelerate也要60s。**但我用python完成这些代码的过程最快，api好用**。

c#性能确实很强。代码量也不多，但是我花了最多的时间写出来。文档什么的都太差了。我有想这写一个桌面工具来转换，**我也肯定会用c#来处理**。

wps应该是c/c++写的，因为加上了gui等等原因，速度竟然不如c#，但还是会比python快不少。足以见得不是一个速度级别。

总结
===
各个语言都是有自己的优势。我的抉择是选python。**除非我要做GUI界面**。

我更喜欢用python来打造原型，完成功能。即使python最慢。现在流行云计算，可以去到云平台写函数，远程调用。