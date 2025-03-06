---
title: AI搭建
tags:
  - blog
date: 2025-02-11
lastmod: 2025-02-11
categories:
  - blog
description: 
---

## 简介

经常刷抖音会刷到搭建 ai 之类的, 一直不想看. 觉得自己不会搭建, 结果今天公司就说要搭建一个试试...

初步了解:

- [ollama](https://github.com/ollama/ollama) 是一个工具, 快速运行 ai 开源的模型
- [omdd](https://github.com/amirrezaDev1378/ollama-model-direct-download) 帮助下载模型

## 搭建

下载 [Releases · ollama/ollama](https://github.com/ollama/ollama/releases), `tar xf ollama-linux-amd64.tgz` 解压后 `mv bin/ollama /usr/bin/ollama`

使用守护进程启动 `vim /etc/systemd/system/ollama.service`

```toml
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
ExecStart=/usr/bin/ollama serve
User=root
Group=root
Restart=always
RestartSec=3
Environment="PATH=$PATH"

[Install]
WantedBy=default.target
```

开机运行 `systemctl daemon-reload ; systemctl enable ollama --now`

理论上来说只需要运行 `ollama run deepseek-r1:7b` 即可在控制台使用模型,  但是有网络问题

## omdd 使用

1. 下载 [omdd](https://github.com/amirrezaDev1378/ollama-model-direct-download/releases)
2. `omdd get qwen2.5-coder:3b` 拿到链接, 把 `manifest` 和 `所有layer` 都下载下来, 这时候在文件夹里有了 `sha256:aa` 和 `manifest` 文件
3. 执行安装 `omdd install --model=mymodel --blobsPath=./`
    - layer 文件安装后的格式 `sha256-40fb844194b25e429204e5163fb379ab462978a262b86aadd73d8944445c09fd`
    - 模型可能存在放在 `/root/.ollama/models` 和 `/usr/share/ollama/.ollama/models`
4. `ollama run mymodel:latest`

>  其实就是通过 omdd 把 layer 和 manifest 下载下来, 然后放到 ollama 的目录下, ollama 就能检测并运行起来
> 关键目录 /root/.ollama/models   /usr/share/ollama/.ollama/models

## ollama 导入 gguf 模型

1. 创建一个目录, 把下载的 [GGUF](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF) 模型放在这里
2. `vim Modelfile`, 写上 `FROM ./mymodel.gguf`
3. `ollama create mymodel` 创建
4. `ollama run mymodel:latest`

## 调用 gpu

1. 在机器上安装 nvdia 和 cuda 驱动
2. 运行模型 `ollama run dr7:latest`
3. 查看 `ollama ps` 的 `PROCESSOR`, `100% CPU` 代表全是 cpu 计算
4. 如果使用了 gpu, 可以用 `nvidia-smi` 查看 gpu 利用率
