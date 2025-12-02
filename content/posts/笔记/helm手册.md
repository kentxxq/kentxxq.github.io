---
title: helm手册
tags:
  - blog
  - helm
  - devops
  - k8s
date: 2025-11-26
lastmod: 2025-11-28
categories:
  - blog
description:
---

### 基础概念

- repo 是一个仓库
	- 相当于 github 的一个用户，下面有很多的应用
	- 比如有 bitnami  `https://charts.bitnami.com/bitnami`  ，minio  `https://operator.min.io`
- chart 是一个应用模板，包含模板，values 等内容
	- values. yaml 可配置的变量，安装时替换模板
- release 是一个 chart 发布到 k 8 s 后的实例

### 安装

1. [Releases · helm/helm](https://github.com/helm/helm/releases)
2. `tar xf xxx.tar.gz`
3. `mv helm /usr/local/sbin/helm`

### 基础操作

- repo 仓库管理 [Artifact Hub](https://artifacthub.io/)
	- 查询所有 repo  `helm repo ls`
	- 添加 `helm repo add bitnami https://charts.bitnami.com/bitnami`
	- 更新 `helm repo update`
- chart 应用列表
	- 搜索
		- `helm search hub mysql` 网上搜索公共的
		- `helm search repo mysql` 只搜索自己 repo 里的
		- 查看 repo 下的所有版本 `helm search repo -l csi-driver-nfs`
	- 拉取 `helm pull bitnami/mysql`
	- 安装
		- bitnami 仓库下的 mysql，并且自定义名称 `helm install my-mysql bitnami/mysql`
		- install 命令可以通过 `--set image.tag=latest` 或 `--values my-values.yaml` 修改默认值
		- 通过 template 渲染成 yaml ，修改 yaml 值
		- 通过 values 文件。**可以在本地修改 values。然后把 values 放到服务器执行**
			1. `helm show values csi-driver-nfs/csi-driver-nfs --namespace kube-system --version 4.12.1 > nfs-values.yaml`
			2. 修改 values
			3. `helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version 4.12.1 -f nfs-values.yaml`
	- 升级，就是把 `install` 改成 `upgrade` 即可
		- `helm upgrade csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version 4.12.1 -f nfs-values.yaml`
- release 部署情况
	- 部署了哪些应用 `helm ls -A`
	- 应用详情
		- `helm status my-mysql`
		- 查看渲染后的内容 `helm get manifest my-mysql -n <namespace>`
	- 删除 `helm uninstall my-mysql`

编写 helm 脚本:

|  说明   | 操作  |
|  ---  | ---  |
| 创建一个 helm 模板  | helm create `name` |
| 打包一个 helm 模板  | helm package `name` |

## 文件语法

使用内容

- `if如果`
- `ne不等于`
- `默认字符串value转int`

```yaml
{{- if .Values.service.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: backend-service-helm-service
  labels:
    name: backend-service-helm-service
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.port }}
      targetPort: {{ .Values.port }}
      protocol: TCP
      name: backend-service-helm-service-pod-{{ .Values.port }}
    {{- if ne (int .Values.grpc_port) 0 }}
    - port: {{ .Values.grpc_port }}
      targetPort: {{ .Values.grpc_port }}
      protocol: TCP
      name: backend-service-helm-service-pod-{{ .Values.grpc_port }}
    {{- end }}
  selector:
    name: backend-service-helm-pod
{{- end }}
```

写入格式化内容 (json 示例)

```yaml
apiVersion: v1
data:
  config.yaml: |
    {{- if eq .Values.deploy_env "dev" }}
    version: dev
    nacos:
      addr: 100.66.6.37
      dataId: backend-service-helm.yaml
      username: shini-dev
      password: pKb2NHSnRiR
      namespaceId: e2b13a92-d47b-4f9f-9d70-6eaa4beea75b
    {{- end }}
```
