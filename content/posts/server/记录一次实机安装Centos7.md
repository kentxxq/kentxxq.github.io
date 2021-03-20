---
title:  记录一次实机安装Centos7
date:   2019-04-15 11:59:00 +0800
categories: ["笔记"]
tags: ["centos"]
keywords: ["Centos7","grub2","timeout","rufus","UEFI","BIOS","GNOME","sudo","内核","fdisk","mkfs.xfs","blkid"]
description: "之前安装centos，都是在阿里云，虚拟机，还有hp-gen6-380的服务器上面安装。也就是说实体机的操作经验，只有一个比较老的hp服务器。而这次使用普通pc机来安装，遇到了不少的问题。重装了大概有50次以上吧，特意来记录一下"
---

> 之前安装centos，都是在阿里云，虚拟机，还有hp-gen6-380的服务器上面安装。
>
> 也就是说实体机的操作经验，只有一个比较老的hp服务器。而这次使用普通pc机来安装，遇到了不少的问题。重装了大概有50次+吧，特意来记录一下。


## 安装经验

交代一下安装linux的经验

1. 阿里云，虚拟机(这两个都属于虚拟环境了)
2. hp-gen6-380(比较老的服务器机型)
3. 家用e3v3+gpu750ti+华硕gaming主板(安装的是的fedora29，所有的组件都很新，问题也不少)

而这次安装在普通pc上，却遇到了问题。让我觉得还是很有必要系统性的了解一下。

## 遇到的问题

### grub2-timeout问题

启动了开机按钮以后，一直卡住在这个界面，需要手动操作才能完成点击。

![内核卡住界面](/images/server/内核卡住界面.jpg)

解决方案:

把超时时间设置为0，直接跳过内核选择界面。**进入默认选中的第一个内核**
```bash
### 路径
[root@YHcentos7 default]# pwd
/etc/default
### 查看配置文件
[root@YHcentos7 default]# cat grub 
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
### bios系统生成boot配置
[root@YHcentos7 default]# grub2-mkconfig -o /boot/grub2/grub.cfg
GRUB_DISABLE_RECOVERY="true"
### uefi系统生成boot配置
[root@YHcentos7 default]# grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
### 重启
[root@YHcentos7 default]# reboot
```

---

**如果你想知道为什么不能启用timeout进入指定的内核，请看下面**

在重装了差不多5次以后，我其中的一次安装后，居然没有问题！导致我后续重装了大概50次，找到了原因。

我的u盘启动盘，是用[rufus](https://rufus.ie/)制作的。用的[centos](https://www.centos.org/download/)dvd版本的镜像。

插入u盘后，引导设备如下

![主板引导图](/images/server/主板引导图.jpg)

可以看到，除了128gb的硬盘，还有**2个可选项**！

选择第一个，也就是`UEFI启动`，在后续的系统分区中，你必须给`/boot/efi`指定分区。分区文件类型为efi。如果没有的话，会报错`no valid bootloader target device found centos 7 for a uefi installation`

选择第三个，也就是`BIOS启动`，则可以不用建立/boot/efi分区，成功timeout后进入系统。

下图就是bios启动，安装系统后的分区结构。

```bash
### sda2用做了swap
[root@YHcentos7 ~]# df -h
文件系统        容量  已用  可用 已用% 挂载点
/dev/sda3       110G  4.0G  107G    4% /
devtmpfs        7.7G     0  7.7G    0% /dev
tmpfs           7.8G     0  7.8G    0% /dev/shm
tmpfs           7.8G  9.6M  7.7G    1% /run
tmpfs           7.8G     0  7.8G    0% /sys/fs/cgroup
/dev/sda1       497M  199M  298M   41% /boot
tmpfs           1.6G   12K  1.6G    1% /run/user/42
tmpfs           1.6G     0  1.6G    0% /run/user/0
```

`UEFI启动`只能按照之前的办法来跳过(我没有找到解决办法)。

`BIOS启动`则可以正常显示timeout，进入默认选中的内核。


### 安装GNOME桌面

```bash
### 安装命令
yum groupinstall "GNOME Desktop" -y
### 切换系统环境
# 开启桌面
systemctl set-default graphical.target 
# 关闭桌面
systemctl set-default multi-user.target 
# 切换桌面 3为命令行 5为桌面
init 3 
init 5
### 查看gnome版本
yum list installed |grep gnome
### 查看使用的是x window还是wayland
# 查看已经登陆的session
loginctl
# 把桌面的那个填到下面去即可
loginctl show-session <SESSION_ID> -p Type
### 卸载命令
yum groupremove "GNOME Desktop"
```

### 开启远程桌面

```bash
### 安装xrdp
yum -y install xrdp
### 启动服务
systemctl start xrdp.service
### 验证端口
netstat -ltn
### 如果不能远程访问，关闭防火墙
systemctl stop firewalld.service
```

### 自动挂载磁盘

```bash
### fdisk分区硬盘后用xfs格式来格式化
mkfs.xfs /dev/sdb1
### 挂载到/data目录
mkdir /data
mount /dev/sdb1 /data
### 查看磁盘uuid
blkid
### 在/etc/fstab下加上这个
UUID=15f87ab4-176a-46a3-bc07-60ef5f2a4129 /                       xfs     defaults        0 0
UUID=adfb7be3-85ce-49c7-992b-e5a0f299f3dd swap                    swap    defaults        0 0
UUID=cd51618b-2615-4d6e-9abc-3a091c8fb820 /data                   xfs     defaults        0 0
### 测试一下有没有问题
mount -a
### 没问题重启一下肯定也没问题了
reboot
```


## 知识拓展

[grub2的配置文档](https://www.gnu.org/software/grub/manual/grub/html_node/Simple-configuration.html)

### efi和bios启动流程

Boot Process under BIOS

1. System switched on - Power On Self Test, or POST process
2. After POST BIOS initializes the necessary system hardware for booting (disk, keyboard controllers etc.)BIOS launches the first 440 bytes (MBR boot code region) of the first disk in the BIOS disk order
3. The MBR boot code then takes control from BIOS and launches its next stage code (if any) (mostly bootloader code)
4. The launched (2nd stage) code (actual bootloader) then reads its support and config files
5. Based on the data in its config files, the bootloader loads the kernel and initramfs into system memory (RAM) and launches the kernel

Boot Process under UEFI

1. System switched on - Power On Self Test, or POST process.
2. UEFI firmware is loaded. 
3. Firmware initializes the hardware required for booting.Firmware then reads its Boot Manager data to determine which UEFI application to be launched and from where (i.e. from which disk and partition).
4. Firmware then launches the UEFI application as defined in the boot entry in the firmware's boot manager.
5. The launched UEFI application may launch another application (in case of UEFI Shell or a boot manager like rEFInd) or the kernel and initramfs (in case of a bootloader like GRUB) depending on how the UEFI application was configured.


### 验证efi还是bios

```bash
### 进入/sys/firmware
cd /sys/firmware
### 如果有efi文件夹，就是efi。否则就是bios
```

### 指定用户sudo免密码

```bash
vi /etc/sudoers
### 加到root用户下面
your_user_name ALL=(ALL) NOPASSWD: ALL

### ubuntu 20.04 LTS
# 加在这个位置
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
kentxxq ALL=(ALL)    NOPASSWD: ALL
```

## 总结

UEFI可以有无限的分区。可以识别2TB以上的硬盘。

bios只能弄一个拓展分区，然后无限拓展。一旦上层出现错误，就会导致不可用。不过够用了。

以后专门的存储服务器，就用uefi来安装。反正也不需要升级什么的，直接关闭掉内核的选择。

bios的就通过nfs直接挂载存储服务器磁盘。
