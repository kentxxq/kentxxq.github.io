---
title: mysql_hugepages配置
tags:
  - blog
  - mysql
date: 1993-07-06
lastmod: 2023-07-11
categories:
  - blog
keywords:
  - mysql
  - hugepages
description: "在linux中，内存一般是2kb-4kb每页，如果是大内存，那么pagetables将会非常大。cpu在查找使用内存的时候，会比较慢。使用hugepages，一个内存页可以设置为2MB-1GB。从而可以加快对内存的访问速度。2MB-4MB，是适用于100GB一下的内存。1GB则适用于TB级别的内存容量"
---

## 简介

在 [[笔记/point/linux|linux]] 中，内存一般是 2kb-4kb 每页，如果是大内存，那么 pagetables 将会非常大。[[笔记/point/mysql|mysql]] 在查找使用内存的时候，会比较慢。使用 hugepages，一个内存页可以设置为 2MB-1GB。从而可以加快对内存的访问速度。2MB-4MB，是适用于 100GB 一下的内存。   1GB 则适用于 TB 级别的内存容量。

### 开始配置 mysql 适用 hugepages

```bash
[mysql@centos1 ~]$ cat /proc/meminfo 
MemTotal:        1016460 kB
MemFree:          557140 kB
MemAvailable:     551864 kB
Buffers:             948 kB
Cached:           121004 kB
SwapCached:            0 kB
Active:           313228 kB
Inactive:          83928 kB
Active(anon):     275372 kB
Inactive(anon):     6524 kB
Active(file):      37856 kB
Inactive(file):    77404 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:        839676 kB
SwapFree:         839676 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:        275228 kB
Mapped:            28304 kB
Shmem:              6692 kB
Slab:              35700 kB
SReclaimable:      14504 kB
SUnreclaim:        21196 kB
KernelStack:        2208 kB
PageTables:         4344 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     1347904 kB
Committed_AS:    1719888 kB
VmallocTotal:   34359738367 kB
VmallocUsed:        5468 kB
VmallocChunk:   34359730176 kB
HardwareCorrupted:     0 kB
AnonHugePages:      4096 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       32704 kB
DirectMap2M:     1015808 kB
```

上面可以看出没有启用 hugepages，默认 hugepages 每页大小为**2mb**。

而当前的 pagetables 为**4344kB**

### centos 系统设置

禁用 thp，在各个数据库的官方文档中都明确指出了透明大页有可能出现各种问题。

设置 hugepages 的个数。加入 mysql 所在的组 (1000)

因为是虚拟机，mac 硬盘休眠，就会造成时间上面的不准确。所以加上了一个时间同步的命令

```bash
vi /etc/rc.d/rc.local

# 尾部加入
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi
if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi

# 设置2mb一个的hugepage，400个，就是800m。
# 在mysql的启动日志中，会有记录需要的内存数量：Initializing buffer pool, total size = 768M  略大即可
echo 410 > /proc/sys/vm/nr_hugepages
# mysql所在的用户组
echo 1000 > /proc/sys/vm/hugetlb_shm_group

/usr/sbin/ntpdate ntp.shu.edu.cn >> /var/log/rc.log
/usr/sbin/hwclock -w >> /var/log/rc.log
```

### centos 开启 hugepages 后的内存

pagetables 减小不明显，但是确实减小了。我在看的时候，发现系统用到了 swap 内存，可能我的内存还是设置过大了

在 mysql 日志中有初始化内存的大小显示。那就是要用到的 hugepage 大小

```bash
[root@centos1 ~]# cat /proc/meminfo 
MemTotal:        1016460 kB
MemFree:           69104 kB
MemAvailable:      11624 kB
Buffers:               0 kB
Cached:            16892 kB
SwapCached:        14032 kB
Active:            35168 kB
Inactive:          38428 kB
Active(anon):      28708 kB
Inactive(anon):    28676 kB
Active(file):       6460 kB
Inactive(file):     9752 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:        839676 kB
SwapFree:         642936 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         48832 kB
Mapped:             6296 kB
Shmem:               604 kB
Slab:              32648 kB
SReclaimable:      11772 kB
SUnreclaim:        20876 kB
KernelStack:        2160 kB
PageTables:         3688 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      938304 kB
Committed_AS:     757564 kB
VmallocTotal:   34359738367 kB
VmallocUsed:        5468 kB
VmallocChunk:   34359730176 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
HugePages_Total:     400
HugePages_Free:      385
HugePages_Rsvd:      385
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       32704 kB
DirectMap2M:     1015808 kB
```

### 验证是否成功

如果报错，没有成功使用大页,错误日志中会有 warning

```bash
2017-07-12T14:47:00.662616Z 0 [Warning] InnoDB: Failed to allocate 138412032 bytes. errno 12
2017-07-12T14:47:00.697358Z 0 [Warning] InnoDB: Using conventional memory pool
```
