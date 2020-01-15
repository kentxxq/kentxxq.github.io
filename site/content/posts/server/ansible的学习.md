---
title:  ansible的学习
date:   2020-01-11 23:46:00 +0800
categories: ["笔记"]
tags: ["server"]
keywords: ["ansible"]
description: "ansible是一个比较流行的服务器集群管理软件。在之前我有对比过监控软件，所以了解到ansible。但是因为监控较弱，加上网上所说的性能问题，没有继续研究下去。只知道基于ssh。所以不需要被控端多做操作。正好面试的公司现在是基于ansible运维，所以肯定要学学了"
---


> ansible是一个比较流行的服务器集群管理软件。在之前我有对比过监控软件，所以了解到ansible。
> 
> 但是因为监控较弱，加上网上所说的性能问题，没有继续研究下去。只知道基于ssh。所以不需要被控端多做操作。
>
> 正好面试的公司现在是基于ansible运维，所以肯定要学学了。


## ansible概览

ansible优点
- 基于python。我也比较熟。
- 基于ssh实现服务，所以被控端不需要做操作。
- 有官方的维护，人数使用也多。所以社区庞大，各种模块更加好用。


## 安装

安装其实还是比较简单的。使用默认linux的包管理器就好。

其中macOS也可以使用brew安装。但是需要指出的是配置文件默认是没有的。

在linux下，默认配置文件都放在`/etc/ansible/ansible.cfg`目录下。

而macOS则默认没有。可以自建`.ansible.cfg`文件放到用户目录下。而在文件内有一句`inventory = /path/hosts`，就是用来指定主机列表的文件。

如果设定没有问题。你就可以使用`ansible --version`验证配置。

## 编写hosts文件

这个文件是用来存放主机清单的，其中`a=1`代表一个变量。是这个主机独享的变量。也可以设置组变量。

```bash
[webservers]
1.1.1.1 a=1
1.1.1.2

[webservers:vars]
b=2

[dbservers]
2.2.2.1
2.2.2.2
```

## 指定主机

第一个参数通常用来指定使用主机。
1. all代表所有主机
2. dbservers则代表数据库下面的所有主机清单
3. 其中`:`代表与，`&`代表或，`!`代表非。也可以使用通配符和正则表达式。

## 常用命令

1. ansible代表主程序，最常用。
2. ansible-doc查看文档。
3. ansible-playbook运行脚本。

## 常用模块

通过`-m`参数可以指定使用的模块。

`ansible -m ping all`可以验证主机是否能联通。

1. `command`是默认模块，但是对通配符或者管道符不好。
2. `shell`代表使用shell模块。通常shell命令用这个。
3. `script`代表脚本模块。在本地写好一个shell文件，然后通过此模块在远程主机上执行，但是要注意目标版本是否和脚本兼容。
4. `copy`代表拷贝文件。其中src参数指定文件或目录，dest代表远程目录，mode=000代表权限，owner代表文件所有者。
5. `fetch`代表提取文件，相当于反向拷贝。
6. `file`可以操作文件。path指定文件路径。state=link配合src和dest则可以设置软连接，absent递归删除，touch文件，directory代表文件夹。
7. `cron`代表linux自己的定时任务。job指定命令，name指定名称且禁用的时候必须指定，默认新增、disabled=true可以关掉。
8. `yum`安装包。通过name指定包名(可以是被控端的本地rpm)且可以逗号隔开。state默认安装、absent卸载。
9. `service`管理服务。
10. `user`管理用户。

## playbook

前面所说的都是通过单独的命令进行操作，而playbook则属于脚本。完成一系列的操作。

```yml
---
- hosts: all
  remote_user: root

  tasks:
  -  name: install some package
     yum: name=sl state=latest
     notify: updated some package
     when: ansible_distribution_major_version == "8"
     name: start some service
     service: name=nginx state=started

  handlers:
  -  name: updated some package
     shell: echo "updated sl package"
```

上面包含了一个基本的playbook，采用的是yml语法。

1. 对所有主机进行操作
2. 远程操作的用户名是root
3. 有2个任务，一个是安装最新sl软件包。一个是启动nginx服务
4. 如果使用新的sl版本，则会通知handler，进行对应的操作。
5. when字段代表符合一定条件的情况下，才会执行此task。

## roles的使用

roles其实就是playbook的模块化版本。参考`https://github.com/ansible/ansible-examples/blob/master/lamp_simple`，大概模式如下:


```bash
$ tree -L 3               
.
├── LICENSE.md
├── README.md
├── group_vars
│   ├── all
│   └── dbservers
├── hosts
├── roles
│   ├── common
│   │   ├── handlers
│   │   ├── tasks
│   │   └── templates
│   ├── db
│   │   ├── handlers
│   │   ├── tasks
│   │   └── templates
│   └── web
│       ├── handlers
│       ├── tasks
│       └── templates
└── site.yml

14 directories, 6 files
```

1. 新建一个项目文件夹lamp_simple，代表一个项目
2. 二级目录存放`group_vars`文件夹用来存放全局变量、`site.xml`存放一个触发role方案脚本、`roles`内存放各个部分的执行方案(前端、后端)
3. 方案内部存放tasks，templates，handlers。其中最主要的是要有main.yml文件，使用include来包含各个task文件，确保执行顺序。
4. 模板文件其实就是一个普通的配置文件，通过j2文件结尾，在内部加上jinja2的语法，通过变量进行替换。


## 总结

暂时就写成这样吧。操作还是很简单的，关键就看实际工作中如何用好它了。

如果遇到难搞的需求，通过2次开发，应该也是一件很轻松的事情，毕竟ansible的模块化做的很好。

