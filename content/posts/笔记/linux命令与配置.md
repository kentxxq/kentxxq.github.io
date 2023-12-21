---
title: linux命令与配置
tags:
  - blog
  - linux
date: 2023-06-29
lastmod: 2023-12-17
categories:
  - blog
description: "这里记录 [[笔记/point/linux|linux]] 的命令与配置, 通常都是某种情况下的处理方法."
---

## 简介

这里记录 [[笔记/point/linux|linux]] 的命令与配置, 通常都是某种情况下的处理方法.

## 常见依赖

### c/c++ 项目依赖

```shell
# 安装编译需要用的依赖
apt install libpcre3 libpcre3-dev openssl libssl-dev build-essential -y
```

## 常用配置

### 免密 sudo

```shell
vim /etc/sudoers
# 找到下面这部分内容
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
kentxxq ALL=(ALL)    NOPASSWD: ALL  # 加入此行
```

### 安装 deb/chrome

```shell
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install ./google-chrome-stable_current_amd64.deb

google-chrome -v
```

### 挂载磁盘

已知新盘 (有数据) 的分区类型,

```shell
# fdisk -l 
# Disk /dev/vdb 是硬盘
# Device /dev/vdb1 是分区
# mount挂载的是分区
mount -t exfat /dev/vdb1 /mnt/exfat
```

新盘 (无数据):

```shell
# 创建一个目录,后续把新盘挂载到这里
mkdir -p /data/new-data
# 查看并发现新磁盘 /dev/sdb
fdisk -l 

# 进行格式化, y继续.会变成一个分区
mkfs -t ext4 /dev/sdb
# 查看格式化后的磁盘, 记录UUID
blkid
# 追加UUID, 按照对应的格式加入到 /etc/fstab
echo 'UUID=你的UUID /data/new-data ext4 defaults 0 0'
# 生效
mount -a
```

> 如果是阿里云, 参考 [[笔记/阿里云操作#新加硬盘]]

### 环境变量

```shell
# export 会话生效,或者加入到 ~/.bashrc 中
PATH=~/opt/bin:$PATH
# 或者
PATH=$PATH:~/opt/bin
```

### alias

#### 补全

```shell
# 通常已经安装了
# apt install bash-completion -y
# 下载文件
curl https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias -o ~/.complete_alias
# 编辑配置文件
vim /root/.bash_completion
. /root/.complete_alias

# 设置alias
vim ~/.bashrc
alias sc='systemctl'
# 尾部添加
vim /root/.complete_alias 
complete -F _complete_alias sc

# 如果.bashrc文件没有启用.必须退出,重新登录后生效!
# 默认是注释的
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
#    . /etc/bash_completion
#fi
```

#### 常用配置

```shell
# 查看日志
alias tailf='tail -f'

# 查看出口ip
alias myip = 'curl -L test.kentxxq.com/ip'

# 全部代理配置
alias vpn='export all_proxy=http://1.1.1.1:7890;'
# 清空
alias novpn='unset all_proxy;'

# 当前会话代理
alias vpn='export http_proxy=http://1.1.1.1:7890; export https_proxy=http://1.1.1.1:7890;'
# 带密码代理
alias vpn='export http_proxy=http://user1:pass1@1.1.1.1:7890; export https_proxy=http://user1:pass1@1.1.1.1:7890;'
# 清空
alias novpn='unset http_proxy; unset https_proxy;'
```

### 免密 ssh

```shell
# 生成公钥和秘钥
ssh-keygen -t rsa
# 拷贝公钥到远程机器,需要输入密码
ssh-copy-id root@1.1.1.1
# 测试效果
ssh root@1.1.1.1

# 如果目标ip重装过,需要c清理本地的拷贝记录
ssh-keygen -R 1.1.1.1
```

### 允许 root 远程登录

```shell
vim /etc/ssh/sshd_config
# 把参数值改成yes
PermitRootLogin yes

# 设置密码
passwd root
# 重启ssh服务
systemctl restart ssh
```

### 安装字体

一般来说合同都要使用宋体, [[附件/simsun.ttc|simsun]]

```shell
# 创建字体文件夹，放入字体文件
mkdir -p /usr/share/fonts/simsun
cd /usr/share/fonts/simsun
rz sumsun.ttc

# 安装字体工具
apt install xfonts-utils fontconfig -y
# 字体操作
mkfontscale
mkfontdir
# 刷新缓存
fc-cache –fv
# 字体查询
fc-list :lang=zh
```

### 挂载 windows 共享盘

```shell
mount -t cifs -o username=Administrator,password=密码 //共享机器的ip地址/data /mnt/pythondata

# 另一个示例
mkdir /mnt/win
mount -t cifs -o username="Everyone" //192.168.2.100/vm_share  /mnt/win
```

### 配置 limit

```shell
# 先确保/etc/security/limits.d没有覆盖的配置
vim /etc/security/limits.conf
# hard硬限制 不会超过
# soft软限制 告警

# nofile 每个进程可以打开的文件数
root soft nofile 65535
root hard nofile 65535
* soft nofile 65535
* hard nofile 65535

# nproc 操作系统级别对每个用户创建的进程数
root soft nproc 65535
root hard nproc 65535
* soft nproc 65535
* hard nproc 65535
```

### 温度传感器

```shell
apt install lm-sensors
# 观察模式
watch sensors

# 如果不是ubuntu系统
cat /sys/class/thermal/thermal_zone0/temp
# 摄氏度
echo $[$(cat /sys/class/thermal/thermal_zone0/temp)/1000]°
```

### 安装 snap-store

```shell
sudo snap install snap-store
```

### wifi 工具

```shell
sudo apt install wireless-tools
# 查看wifi设备信息
iwconfig
```

### 关闭防火墙

```shell
ufw disable
```

### 安装桌面

```shell
# 安装一个小工具
sudo apt install tasksel
# 看可以装哪些版本
tasksel --list-tasks
# 安装桌面套件
sudo tasksel install ubuntu-desktop
# 重启生效
reboot
```

### 关闭 selinux

```shell
apt install selinux-utils policycoreutils -y

# 当前生效
setenforce 0
# 永久生效
vim /etc/selinux/config
SELINUX=disabled
```

### 定时任务 crontab

1. **推荐使用**系统配置文件 `/etc/crontab`
2. 文档**不建议使用** `/etc/cron.d` 系统配置目录, 这个目录留给应用程序放自己的配置. 例如安装 [[笔记/point/mysql|mysql]] 后, 程序自带一个定时备份.
3. `crontab -e` 等命令都是操作 `/var/spool/cron/crontabs/用户名`

> 重要!!!
> 1 和 2 属于系统级别配置文件, 允许指定用户名字段
> 3 属于用户级别配置文件, **用户名字段会是命令的一部分, 导致报错!!!**

```shell
vim /etc/crontab
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

# 凌晨5点和6点的时候,每10分钟执行
*/10 5,6 * * * root /bin/bash /root/backup.sh
```

- 特定值：使用具体的数值表示，如 `5` 表示第 5 分钟、`10` 表示 10 点。
- 通配符（`*`）：表示匹配任意值，如 `*` 表示每分钟、每小时、每天等。
- 范围值：使用 `-` 表示范围，如 `2-5` 表示 2 到 5 之间的值。
- 枚举值：使用逗号 `,` 表示枚举多个值，如 `1,3,5` 表示 1、3 和 5。
- 步长值：使用 `*/n` 表示步长，如 `*/15` 表示每隔 15 个单位执行一次。

### openssl 验证问题

在部署服务的时候, 发现无法发送邮件. 因为 ssl 验证不通过, 可以尝试配置.

```
openssl_conf = openssl_init

[openssl_init]
ssl_conf = ssl_config

[ssl_config]
system_default = tls_defaults

[tls_defaults]
CipherString = @SECLEVEL=2:kEECDH:kRSA:kEDH:kPSK:kDHEPSK:kECDHEPSK:-aDSS:-3DES:!DES:!RC4:!RC2:!IDEA:-SEED:!eNULL:!aNULL:!MD5:-SHA384:-CAMELLIA:-ARIA:-AESCCM8
Ciphersuites = TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256:TLS_AES_128_CCM_SHA256
MinProtocol = TLSv1.2
```

### 时间同步

```shell
apt install ntp ntpdate -y
# 同步时间
ntpdate ntp.aliyun.com
0 * * * * /usr/sbin/ntpdate ntp.aliyun.com
# 写入系统
hwclock -w

# 查看当前时间和配置
timedatectl
# 查询可用的时区
timedatectl list-timezones | grep -i shang
# 设置时区
timedatectl set-timezone Asia/Shanghai
```

### 配置中文

```shell
export LANG=zh_CN.UTF-8


# 查看当前shell环境locale
locale

# 查看系统locale
localectl
# 查看系统有的字符集
localectl list-locales
# 如果有中文字体
localectl set-locale LANG=zh_CN.UTF-8
# 默认英文
localectl set-locale LANG=en_US.UTF-8

# 没有效果? 重启生效
vim /etc/locale.conf
LANG=zh_CN.UTF-8
LC_ALL="zh_CN.UTF-8"
# 或者
vim .bashrc
export LANG=zh_CN.UTF-8
export LC_ALL="zh_CN.UTF-8"

# 搜索所有语言包
apt search language-pack*
# 搜索中文包
apt search language-pack-zh*
# 建议选用
apt install language-pack-zh-hans -y
```

### 开启 bbr

bbr 是一种浪费网络资源，提升网络速度和稳定性的通讯手段。

```shell
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
# 生效
sysctl -p
# 验证
lsmod | grep bbr
```

### 修改登录后的提示信息

```shell
vim /etc/motd

Welcome to Alibaba Cloud Elastic Compute Service !
```

## 常见操作

### jq 处理 json

[jq官网文档](https://jqlang.github.io/jq/manual/#basic-filters)

```shell
# 计算每个remote_addr请求每个host主机的次数
cat kentxxq.com.log | jq '.["@fields"] | .remote_addr + " " + .host' | sort | uniq -c | sort -k1n

# 条件过滤
'select(.["@timestamp"] <= $end_time and .["@fields"].remote_addr == $target_remote_addr)'

# 在上面的基础上,限制时间不能早于11点,晚于13点
jq -r 'select(.["@timestamp"] >= "2023-10-09T11:00:05+0800" and .["@timestamp"] <= "2023-10-09T13:00:05+0800" ) | .["@fields"] | .remote_addr + " " + .host' kentxxq.com.log | sort | uniq -c | sort -k1n
# 效果,性能差不多. 但可以用tail -f xxx来监控
cat kentxxq.com.log | jq -c 'select(.["@timestamp"] >= "2023-10-09T11:00:05+0800" and .["@timestamp"] <= "2023-10-09T13:00:05+0800" ) | .["@fields"] | .remote_addr + " " + .host' | sort | uniq -c | sort -k1n

# 输出到新文件
jq --arg start "2023-10-09T00:00:00+08:00" --arg end "2023-10-09T23:59:59+08:00" 'select(.["@timestamp"] >= $start and .["@timestamp"] <= $end)' log.json > filtered_log.json
# tail -f 版本
tail -f log.json | jq --arg start "2023-10-09T00:00:00+08:00" --arg end "2023-10-09T23:59:59+08:00" 'select(.["@timestamp"] >= $start and .["@timestamp"] <= $end)' > filtered_log.json
```

### curl

```shell
# -X 指定请求方式 大写
# -H 设置请求头，可以多个-H
# -d 指定payload的数据
curl -X POST -H "Accept: application/json" -H "Content-type: application/json" -d '{"post_data":"i_love_immvp.com"}' localhost:8096/api/answer/checkAnswer

# 忽略证书
curl -k https://127.0.0.1:5001/

# 下载 -C - 断点续传,记得多一个中杠 -O 指定名称
curl -C - https://dl.min.io/server/minio/release/linux-amd64/archive/minio_20230711212934.0.0_amd64.deb -O minio.deb

# 模拟跨域
curl -vvv 'https://kentxxq.com/Count' -H 'Origin: http://localhost:3000'

# 请求es
curl -H "Content-Type: application/json"  -XPUT --user elastic:password   es-cn-oew1whnk60023e4s9.elasticsearch.aliyuncs.com:9200/flow_user_index/_settings -d '{"index.mapping.total_fields.limit":0}'
结果 {"acknowledged":true}

# 计时 https://susam.net/blog/timing-with-curl.html
curl -L -w "time_namelookup: %{time_namelookup}
time_connect: %{time_connect}
time_appconnect: %{time_appconnect}
time_pretransfer: %{time_pretransfer}
time_redirect: %{time_redirect}
time_starttransfer: %{time_starttransfer}
time_total: %{time_total}
" https://example.com/
```

报错

- `curl: (35) error:0A000172:SSL routines::wrong signature type`

    ```shell
    # 修改文件
    vim /etc/ssl/openssl.cnf
    
    [system_default_sect]
    CipherString = DEFAULT:@SECLEVEL=0
    ```

### 代理 apt

```shell
# 临时
-o Acquire::http::proxy="https://user1:pass1@a.kentxxq.com:17890" -o Acquire::https::proxy="https://user1:pass1@a.kentxxq.com:17890"

# 永久,文件不存在就创建
vim /etc/apt/apt.conf.d/95proxy.conf
Acquire::http::proxy "https://user1:pass1@a.kentxxq.com:17890";
Acquire::https::proxy "https://user1:pass1@a.kentxxq.com:17890";
```

### tcpdump

```shell
# -nn 不解析域名-加速
# -w 175.6.6.238.pcap 指定文件名
# 指定网络接口
# host 175.6.6.238 捕获ip地址为 xxx , 可以src host或者dst host
# port 8088 捕获端口为 8088,可以 src port或者dst host
tcpdump -i eth0 src host 175.6.6.238 and dst port 80 -nn

# 协议
tcpdump icmp
tcpdump tcp
tcpdump 'ip && tcp'
```

### 校验 sha 256

```shell
curl -Lo tempo_2.1.1_linux_amd64.deb https://github.com/grafana/tempo/releases/download/v2.1.1/tempo_2.1.1_linux_amd64.deb
# 校验输出tempo_2.1.1_linux_amd64.deb: OK
echo 6e031625b2046d360cf8c4897614523869f45b52286e4fb69e25811d2509b651 \
  tempo_2.1.1_linux_amd64.deb | sha256sum -c
```

### 系统安装时间

```shell
# 根路径的创建时间
stat / | awk '/Birth: /{print $2 " " substr($3,1,5)}'
# 文件系统的创建时间
fsname=$(df / | tail -1 | cut -f1 -d' ') && tune2fs -l $fsname | grep 'created'
```

### 清除历史记录

```shell
# 清除指定id
history -d 123
# 清除所有历史记录
history -c

# 清理系统记录
echo > /var/log/lastlog ;
echo >   /var/log/utmp ;
cat /dev/null >  /var/log/secure ;
cat /dev/null >  /var/log/message ;
echo > /var/log/btmp ;
echo > /var/log/wtmp ;
```

### dpkg 软件包查找

```shell
# 查看列表,过滤列表
dpkg -l | grep kubelet
# 查看kubelet相关的文件
dpkg -L kubelet
```

### 用户会话处理

```shell
# 查看会话
w
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
root     pts/0    175.9.140.51     Thu14    1.00s  0.08s  0.00s w
root     pts/1    tmux(368975).%7  09Aug23 29days  0.10s  0.10s -bash

# 杀死指定会话
pkill -KILL -t pts/1
```

### 大版本升级

```shell
apt install update-manager-core -y
do-release-upgrade -d
```

### 跑分

```shell
wget http://soft.vpser.net/test/unixbench/unixbench-5.1.2.tar.gz
tar zxvf unixbench-5.1.2.tar.gz
cd unixbench-5.1.2/

vim Makefile
# GRAPHIC_TESTS = defined

make
./Run
```

### 软链接 ln

```shell
# ln -s 现有文件/目标文件 链接文件
# 创建/usr/local/nginx/sbin/nginx的快捷方式到/usr/local/bin/nginx
# 软连接的目标文件可以被替换,替换后会链接到新文件
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx

# 查看软链接的实际路径
readlink -f /lib/systemd/system/nginx.service
/usr/lib/systemd/system/nginx.service
```

### 命令手册 man

```shell
# 查看手册有哪些章节
man -k crontab
# 查看手册,默认是章节1
man crontab
# 查看特定章节.文档中cron(8)/crontab(5),代表对应的文档(章节)
man 5 crontab
```

### 配置主机名

```shell
hostnamectl set-hostname master1
```

### shell 退出码

```shell
# 正常退出
ls
EXCODE=$?
echo $EXCODE # 0
# 异常错误
ls ---
EXCODE=$?
echo $EXCODE # 2

# shell脚本
EXCODE=$?
if [ "$EXCODE" != "0" ]; then
    echo "有问题！"
    exit 1;
fi
```

### 用户, 组, 加入组, 权限

```shell
# 创建组dba,组号6001
groupadd -g 6001 dba

# 创建用户sam,同时指定主目录
useradd –d /home/sam -m sam
# 设置密码
passwd sam

#把sam加入dba组
usermod -a -G dba sam

# 修改目录拥有者:组
chown -R sam:dba file/folder
# 放开权限给所有用户
chmod 777 file/folder
```

### 安装/卸载软件

```shell
# 安装deb包
dpkg -i minio.deb

# 搜索查看已安装的包
dpkg --list

# 查看正则匹配的包
# 查看以dotnet-开头的包
dpkg --list 'dotnet-*'

# 卸载匹配的包
sudo apt-get --purge remove <programname>

# 按照正则卸载匹配的包
# 卸载以dotnet-开头的包
sudo apt-get --purge remove 'dotnet-*'

# 如果不想自己手动输入Y确认的话则使用
echo "Y" |sudo apt-get --purge remove 'dotnet-*'
```

### 端口状态检查

```shell
# 端口正常为0，否则状态码/退出码为1
nc -zv 127.0.0.1 6443
echo $?

nc -zv 127.0.0.1 6444
echo $?
```

### 查看文件

```shell
# less 只读超大文件
# 输入F可以滚动输出,刷新当前屏幕,不刷屏.也可以手动输入G,移到底部
# q输出 /搜索
less file.txt

# head 文件尾部
head -n 10 file.txt

# tail 文件尾部
# tail -f 滚动输出
# 配合 |grep 过滤
tail -f file.txt
# 末尾10行
tail -n 10 file.txt
```

### 删除 x 天前的文件

```shell
find /data/weblog/ -name '*.log.*' -type f -mtime +7 -exec rm -f {} \;
```

### 清空文件

```shell
# 快速清空
>file.txt
# 截断任意文件
truncate -s 0 file.txt
```

### 查看进程启动时间

```shell
ps -eo pid,lstart,etime | grep 1310
1310 Sat Aug 10 10:21:25 2019 242-07:26:58
# 前面是启动时间，后面是启动了242天又7小时
```

### 压缩/解压 tar

```shell
# z是使用gzip
# v是查看细节
# f是指定文件
# --strip-components=1 去掉一层解压目录

# 查看文件内容
tar -tf xxx.tar.gz

# 打包
tar -czvf dist.tgz dist/

# 解压
tar -xzvf dist.tgz
# 解压到指定文件夹
tar Cxzvf /dist dist.tgz

# 打包隐藏文件
# 通过 . 可以打包到隐藏文件
tar -czvf dist.tgz /dad/path/.
# 通过上级目录来打包
tar -czvf dist.tgz /data/path
# 如果是在当前目录，可以手动指定
tar -czvf dist.tgz tar -zcvf dist.tgz .[!.]* *
```

### 拷贝文件

#### scp

简单高效, 日常使用.

```shell
# 本地到远程
scp /path/thing root@10.10.10.10:/path/thing
# 远程到本地
# -r遍历
# -C压缩
sshpass -p 密码 -o StrictHostKeyChecking=no scp -Cr root@10.10.10.10:/path/folder /path/folder

# 使用sshpass免密一条命令
# scp支持所有ssh的参数
# StrictHostKeyChecking 第一次连接会需要输入yes,禁用掉它.
# UserKnownHostsFile 这次的配置丢弃掉,表示临时使用.避免安全问题.
/usr/bin/sshpass -p 密码 /usr/bin/scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@1.1.1.1:/tmp/t1/1 /tmp/t1/1
```

#### rsync

通常用于**增量传输**.

```shell
# 把1这个文件/文件夹 拷贝到远程的/tmp/t1/下面
# at保持文件信息不变
# VP先是进度
# -z 可以开启压缩
rsync -atvP /tmp/t1/1 root@1.1.1.1:/tmp/t1/

# 也支持sshpass
/usr/bin/sshpass -p 密码 rsync -atvP -e "ssh -o StrictHostKeyChecking=no" /tmp/t1/1 root@1.1.1.1:/tmp/t1/
```

### 筛选替换

```shell
# -r遍历 当前目录,筛选所有带有kentxxq的文件
# 替换old-a成new-b
sed -i 's/old-a/new-b/g' `grep kentxxq -rl ./`

# 文件替换
sed -i 's#/etc/nginx/ssl/kentxxq.key#/usr/local/nginx/conf/ssl/kentxxq.key#g' *
```

## 系统监控

### 信息查询

```shell
# 系统信息
lsb_release -a
LSB Version: :core-4.1-amd64:core-4.1-noarch
Distributor ID: CentOS
Description: CentOS Linux release 8.0.1905 (Core)
Release: 8.0.1905
Codename: Core
# cpu信息
cat /proc/cpuinfo
# 内存信息,2个16g代表32gb内存,双通道
# 或 cat /proc/meminfo
# 或 dmidecode -t memory
dmidecode | grep -A16 "Memory Device" | grep "Size" |sed 's/^[ \t]*//'
# 磁盘信息
fdisk -l


# 系统os错误代码查询
perror 24
OS error code 24: Too many open files
# 服务器型号
dmidecode | grep 'Product Name'
# 主板序列号
dmidecode | grep 'Serial Number'
# 系统序列号
dmidecode -s system-serial-number
# oem信息
dmidecode -t 11
```

### 状态监控

#### 整体概况

```shell
top
htop
```

#### 文件与进程 lsof

```shell
# 查看指定用户
lsof -u root | less
# 查看除指定用户外
lsof -u ^root 
# 查看指定目录
lsof +D /usr/local/
# 查看某进程
lsof -p 3738
# 查看所有网络
lsof -i
# 查看所有tcp
lsof -i tcp

# 排序句柄  数量-pid
lsof -n |awk '{print $2}'|sort|uniq -c |sort -nr|less
```

#### 内存

```shell
# 查看内存使用状态
free -m
# 查看内存变化 vmstat 间隔 监控次数
vmstat 2 2
```

#### 硬盘

```shell
# 磁盘分区等情况
fdisk -l
# 硬盘监控
# -o 只显示活动中的
# -P 显示进程相关,而不是线程
iotop -oP
```

#### 网络

```shell
# 用来进行查看各个网卡的总流量
nload
# 用来监控各个进程的流量使用情况
nethogs
# 图形化的工具，可以查看具体的端口情况
iptraf-ng


# 各状态tcp连接统计
netstat -n | awk '/^tcp/ {++state[$NF]} END {for(key in state) print key,"\t",state[key]}'
# 外部ip连接最多的20条记录
netstat -ant | awk '/^tcp/ {split($5, a, ":"); count[a[1]]++} END {for (ip in count) print ip "\t" count[ip]}' | sort -nrk2 | head -n 20
```
