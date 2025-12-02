---
title: dell服务器手册
tags:
  - blog
  - server
  - 服务器
date: 2025-11-25
lastmod: 2025-11-25
categories:
  - blog
description:
---

## 简介

这里记录一下 dell 服务器的操作

## perccli

可以查看磁盘，电源，raid，配置热备盘。

### pve 安装 perccli

1. 下载 [LINUX PERCCLI Utility For All Dell HBA/PERC Controllers | Driver Details | Dell US](https://www.dell.com/support/home/en-us/drivers/driversdetails?driverId=J91YG)
2. 解压
3. 安装 `dpkg -i perccli_007.1623.0000.0000_all.deb`
4. `cd /opt/MegaRAID/perccli/`
5. `./perccli64 /c0 show`

### esxi 安装 perccli

1. 下载安装包 [PERCCLI Utility supporting VMWare for 5.5 and 6.0 | 驱动程序详情 | Dell 中国](https://www.dell.com/support/home/zh-cn/drivers/driversdetails?driverid=ncwyh)
2. 解压出来，把 `vib` 文件复制到 esxi 存储上
3. `esxcli software vib install -v /vmfs/volume/datastore1/vmware-esx-perccli.vib --no-sig-check` 安装
4. 进入目录 `cd /opt/lsi/perccli`
5. `./perccli show`

### 命令

- 磁盘概念
    - raid 0 就是 `controller0/c0`，是物理卡
        - dg 0 硬盘组，物理盘可以加入组。使用不同的 raid 方案，这里用 raid 5
            - vd 0 虚拟出来的普通盘，虚拟机挂载
            - vd 1
        - dg 1 这里用 raid 10
            - vd 2
- 查看磁盘信息。`c0` 代表第一块 raid 控制卡
    - `./perccli /c0/vall show all` 查看所有虚拟磁盘，**概览**
    - `./perccli /c0/eall/sall show all` 所有物理磁盘信息，**很详细的信息**
    - `./perccli /c0/v0 show all` 查看 raid 组的信息
        - `/c0/v0` 代表第一个 raid 下的第一个虚拟磁盘
    - `./perccli /c0 /eall /sall show` 查看 `c0` 下所有的磁盘和 raid 信息 **常用**
        - 可以看到那些盘是 online，ugood，jbod
- 设置磁盘状态。 `/e32` 是背板 id，有的机器只有一个背板。`/s3` 是 3 号物理盘插槽
    - `./perccli /c0/e32/s3 show all` 查看磁盘的详细信息，特别是检查 state 部分的 `Shield Counter`，`Media Error Count` 等参数，**磁盘很可能已经不堪重负**
    - 恢复磁盘使用
	    - 如果 DG 状态是 F，清理 foreign 即可 `./perccli /c0/fall delete`
	    - ubad 改 ugood
		    - `./perccli /c0/e32/s3 set good` 改状态
		    - `./perccli /c0/e32/s3 start initialization` 尝试初始化磁盘，全盘写入验证
		    - `./perccli /c0/e32/s3 show initialization` 查看初始数进度
		    - `./perccli /c0/eall/sall show` 查看是否正常
	    - `./perccli /c0/e32/s3 set good force` 强制设置为 good 状态，**会丢失盘内数据，仅用于误报坏盘或者更换盘后强制加入阵列**。建议先用新盘把 raid 恢复过来，在看老盘是不是仅逻辑损坏
- 添加热备盘，坏了的话就会自动加入整列
    - `./perccli /c0/e32/s1 add hotsparedrive` 全局热备
    - `./perccli /c0 /e32/s3 add hotsparedrive DGs=0` 专用热备
    - 加入热备盘以后，盘坏了会自动修复 raid，可以从查看命令，查看磁盘是否 rebuild 完成
