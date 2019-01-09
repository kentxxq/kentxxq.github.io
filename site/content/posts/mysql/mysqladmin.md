---
title:  mysqladmin
date:   2017-07-19 00:00:00 +0800
categories: ["笔记"]
tags: ["mysql"]
---


> 这是一个非常好用的mysql工具，可以查看各种状态。

查看当前mysql数据库的运行状况
---
```bash
mysqladmin -u root -p status
Uptime: 1368  
Threads: 3  
Questions: 85  
Slow queries: 0  
Opens: 116  
Flush tables: 1  
Open tables: 109  
Queries per second avg: 0.062
```