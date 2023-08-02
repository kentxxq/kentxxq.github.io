---
title: Containerd
aliases:
  - containerd
tags:
  - point
  - Containerd
date: 2023-08-02
lastmod: 2023-08-02
categories:
  - point
---

`Containerd` 是一个 daemon 进程用来管理和运行容器. 它通过调用 runc 来创建和运行容器.

要点:

- [[笔记/point/docker|docker]] 从 1.11 版本开始使用 [[笔记/point/Containerd|Containerd]] 和 [[笔记/point/runc|runc]], 所以和 [[笔记/point/k8s|k8s]] 等生态是完全兼容的.
- 免费开源
