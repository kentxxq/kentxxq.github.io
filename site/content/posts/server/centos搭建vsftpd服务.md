---
title:  centos搭建vsftpd服务
date:   1993-07-06 00:00:00 +0800
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","yum","vsftpd","anonymous","配置"]
description: "centos搭建vsftpd服务"
---


> centos7默认最小安装中没有ftp服务。  [vsftpd配置文件官方文档](https://security.appspot.com/vsftpd/vsftpd_conf.html)

下载安装后自动运行
---
```bash
yum install vsftpd
```

配置文件路径
---
```bash
[root@centos1 vsftpd]# pwd
/etc/vsftpd
[root@centos1 vsftpd]# ls
ftpusers  user_list  vsftpd.conf  vsftpd_conf_migrate.sh
[root@centos1 vsftpd]#
```

注意事项
---
`ftpusers`是黑名单！所有名单中的用户名，都无法登陆ftp！  
关于`user_list`：  

1. userlist_enable Default: NO
2. userlist_deny   Default: YES  
默认`user_list`设置为不启用。一旦启用userlist_enable，则文件生效   
如果`user_list`生效，则userlist_deny则默认为YES，`user_list`变为一个**黑名单**！

默认安装后的目录
---
anonymous用户的默认根目录为`/var/ftp`,应该给予/var/ftp路径所有用户的写权限`chmod a+w /var/ftp`  
anonymous用户可以上传的目录`/var/ftp/pub`。  
如果用root用户登陆，则可以访问**任何路径**！  
只能下载不能上传，上传需要启用参数`anon_upload_enable=YES`和`anon_mkdir_write_enable=YES`  


快速创建可以匿名上传下载的ftp
---
编辑`/etc/vsftpd/vsftpd.conf`
```bash
修改默认端口
listen_port=2121
可以匿名创建文件夹
anon_mkdir_write_enable=YES
可以匿名上传
anon_upload_enable=YES
匿名上传的文件默认权限
anon_umask=011
匿名用户可以进行删除操作
anon_other_write_enable=yes
```

`chmod 777 /var/ftp/pub`
匿名的所有操作都是在下面这个文件夹中进行，/var/ftp目录只能进行读取

`在ftpusers和user_list中删除root`,方便root用户ftp登录进行管理操作

阿里云特殊设置
---
1. 在vsftpd.config中加入下面的参数
```bash
pasv_enable=YES
pasv_max_port=7000
pasv_min_port=6000
```

2. 安全组中，加入6000-7000端口