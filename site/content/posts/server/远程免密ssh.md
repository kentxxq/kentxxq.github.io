---
title:  远程免密ssh
date:   1993-07-06 00:00:00 
categories: ["笔记"]
tags: ["centos"]
keywords: ["centos","ssh-keygen","远程免密","ssh","ssh-copy-id"]
description: "远程免密ssh"
---



```bash
# 生成公钥和密钥
kent’s MacBook Pro:bin kentxxq$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/user/.ssh/id_rsa): #回车
Enter passphrase (empty for no passphrase): #密码
Enter same passphrase again: #密码
Your identification has been saved in /Users/user/.ssh/id_rsa.
Your public key has been saved in /Users/user/.ssh/id_rsa.pub.
The key-s fingerprint is:
SHA256:4/PI3lPzkOvli9Vvaz0WRAd8WE4m6gtVW7ARILmeLU0 kentxxq@kent’s MacBook Pro
The keys randomart image is:
+---[RSA 2048]----+
|          ...oB*=|
|          .. oo@o|
|           .o +.o|
|          .oE  . |
|        S..=...  |
|       . .+.B. o |
|        o  o.=o +|
|       . =. .=.++|
|       .+ ooo =++|
+----[SHA256]-----+

#拷贝公钥到远程的机器，这个过程需要远程机器的密码

kent’s MacBook Pro:bin kentxxq$ ssh-copy-id root@192.168.22.222
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@192.168.0.222-s password: 

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh 'root@192.168.0.222'"
and check to make sure that only the key(s) you wanted were added.

# 测试是否正常使用
kent’s MacBook Pro:bin kentxxq$ ssh root@192.168.22.222
Last login: Tue Jul  4 20:57:34 2017 from 192.168.22.102
[root@centos1 ~]# 
```


如果目标ip进行过重装，因为本机存在拷贝记录，会告警提示，且需要重新设置
```bash
ssh-keygen -R 192.168.22.222
# 之后按照之前的步骤，可以重新生成操作
```