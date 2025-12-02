---
title: kube-prometheus手册
tags:
  - blog
date: 2025-10-30
lastmod: 2025-10-30
categories:
  - blog
description:
---

## 简介

基于 [[k8s]] 搭建的全套监控。

- [prometheus-operator](https://github.com/prometheus-operator/prometheus-operator) 是 prometheus 的部署工具，有 serviceMonitor，podMonitor 之类的
- [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) 是全家桶，集成了 alertmanager，blackbox，grafana 等等

## 内容

## 疑难杂症

### serviceMonitor 无法跨命名空间采集

解决方法: 编辑 `ClusterRole`，名字是 `prometheus-k8s`（k8s 中 prometheus 的实例名）。添加下面的 rules 部分内容

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-k8s
spec: {}
rules:
  - apiGroups:
    - ""
    resources:
    - services
    - endpoints
    - pods
    verbs:
    - get
    - list
    - watch
```
