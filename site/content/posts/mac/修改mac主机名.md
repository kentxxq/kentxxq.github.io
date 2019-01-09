---
title:  修改mac主机名
date:   2017-07-19 00:00:00 +0800
categories: ["笔记"]
tags: ["mac"]
---



> 问题出现的原因是，我从城市A回到城市B的时候，打开我的mac终端，发现我前缀居然发生了变化
```bash
192:~ kentxxq$ 
```

很遗憾，之前是什么我都给忘了，应该是类似kentxxq's macbookpro类似的。肯定不是这个192,类似ip第一个占位的数字  
通过下面的语句进行修正
```bash
sudo -scutil --set HostName 'kent’s MacBook Pro'
```

重启后效果为
```bash
kent’s MacBook Pro:~ kentxxq$ 
```




延伸部分
---
```bash
# 启用root用户并且创建密码
sudo -i
```