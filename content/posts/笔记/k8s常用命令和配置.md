---
title: k8s常用命令和配置
tags:
  - blog
  - k8s
date: 2023-08-15
lastmod: 2025-11-28
categories:
  - blog
description: "记录 [[笔记/point/k8s|k8s]] 的常用命令和配置"
---

## 简介

记录 [[笔记/point/k8s|k8s]] 的常用命令

## 命令

### 资源简写

`kubectl api-resources` 可以查看资源简写。常用如下:

| name                   | alias  | apiversion             | namespace | lkind                 |
| ---------------------- | ------ | ---------------------- | --------- | --------------------- |
| namespaces             | ns     | `v1`                   | false     | Namespace             |
| deployments            | deploy | `apps/v1`              | true      | Deployment            |
| ingresses              | ing    | `networking.k8s.io/v1` | true      | Ingress               |
| configmaps             | cm     | `v1`                   | true      | ConfigMap             |
| services               | svc    | `v1`                   | true      | Service               |
| serviceaccounts        | sa     | `v1`                   | true      | ServiceAccount        |
| nodes                  | no     | `v1`                   | false     | Node                  |
| persistentvolumeclaims | pvc    | `v1`                   | true      | PersistentVolumeClaim |
| persistentvolumes      | pv     | `v1`                   | false     | PersistentVolume      |

> 如果你安装了 [[笔记/lstio|lstio]] 这样有自定义资源的组件，一样也会出现在这里

### label

```shell
# 打 label
kubectl label nodes master1 mylabel=example
# 覆盖
kubectl label nodes master1 mylabel=newvalue --overwrite
# 删除 label
kubectl label nodes master1 mylabel-

# 查询label
kubectl get nodes --show-labels
```

### 污点

```shell
# key=value 自定义污点
# 不容忍时  
# NoSchedule 不调度  
# PreferNoSchedule 尽量不调度  
# NoExecute 已在节点上的 Pod 也会被驱逐
kubectl taint nodes master1 key=value:NoSchedule

# 删除污点
kubectl taint nodes master1 key:NoSchedule-

# 查看污点
kubectl describe node master1 | grep -i taint -A2
```

### 查询信息

```shell
# 获取实时deployment信息
kubectl get --watch deployments

# 查询所有ingressClassName
kubectl get ingressclasses

# 查询具体权限
kubectl describe ClusterRole tzedu:developer
```

### 日志查询

```shell
kubectl logs <pod-name> -c <container-name>

# 容器名 9-787df6fcc-c42x9 单容器可以省略-c
# --previous 查看上一个
kubectl logs 9-787df6fcc-c42x9

# 通过label查询多个容器的日志
kubectl logs -f -n kube-system -l k8s-app=calico-node
```

### 清理

#### 清理 containerd 磁盘空间

```shell
# 发现这个文件夹很大
# /var/lib/containerd/io.containerd.snapshotter.v1.overlayfs
crictl rmi --prune
```

#### 清理残存容器

强制删除 pod, 其他资源同参数也可以删除.

```shell
kubectl delete pod pod名称 -n 命名空间 --force --grace-period=0
```

#### 清理自建 registry 镜像

https://stackoverflow.com/a/55456150/8546363

```shell
docker exec local_registry bin/registry garbage-collect /etc/docker/registry/config.yml
```

### 创建用户和 token

创建这个 yaml

- 创建用户 admin-user
- 创建 clusterrolebindding，绑定权限到 cluster-admin（权限很高）

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

临时 token：

```shell
kubectl -n kubernetes-dashboard create token admin-user
```

长期 token：

```yml
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
```

获取长期 token

```shell
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```

> 文档地址在 [这里](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)，来自/适用于 [kubernetes/dashboard](https://github.com/kubernetes/dashboard)

### 更换镜像 statefulSet

用于替换 statefulSet 的镜像

`./kubectl set image statefulset/apinto-gateway-stateful apinto-gateway-stateful=shini-uat-cn-shanghai.cr.volces.com/shini-dev/apinto-dev:18b097e-10 -n apinto  --kubeconfig qs-dev-kube.conf.shishi --v=6`

## 配置

### 命令补全

加入到 `~/.bashrc` 中，然后 `source` 生效

```shell
source <(kubectl completion bash)
source <(kubeadm completion bash)
```

### 应用挂起

有的时候程序总是自动退出, 无法查看到 stdout, 也无法进入容器. 这时候需要挂起程序不退出

- `command: ["/bin/sh", "-c", "/app/myApp start; tail -f /dev/null"]`
- `containers.image` 同级

### 应用示例

#### deployment

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    name: nginx-deployment
    type: demo
spec:
  # 发布策略
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 34%
  # 亲和性
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: name
                  operator: In
                  values:
                    - nginx-pod
            namespaces:
              - default
            topologyKey: topology.kubernetes.io/zone
        - weight: 1
          podAffinityTerm:
            labelSelector:
              matchExpressions:
                - key: name
                  operator: In
                  values:
                    - nginx-pod
            namespaces:
              - default
            topologyKey: kubernetes.io/hostname
  # 分片数
  replicas: 1
  selector:
    matchLabels:
      app: nginx-pod
  template:
    metadata:
      # annotations:
        # 火山发布到VCI
        # vke.volcengine.com/burst-to-vci: enforce
      labels:
        app: nginx-pod
    spec:
      # 拉取镜像仓库凭证
      # imagePullSecrets:
      #   - name: image-pull-secrets
      # 挂载configmap
      # volumes:
      #   - configMap:
      #       defaultMode: 420
      #       name: nginx-configmap
      #     name: config
      containers:
        - name: nginx-pod
          image: nginx:latest
          ports:
            - name: port
              containerPort: 80
              protocol: TCP
          # 资源限制
          resources:
            limits:
              cpu: 500m
              memory: 1000Mi
            requests:
              cpu: 10m
              memory: 100Mi
          # 挂载到容器路径
          # volumeMounts:
          #   - mountPath: /tmp/config.yaml
          #     name: config
          #     readOnly: true
          #     subPath: config.yaml
          # 健康检查
          startupProbe:
            initialDelaySeconds: 5
            exec:
              command:
                - ls
          readinessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 1
            failureThreshold: 30
            periodSeconds: 5
            timeoutSeconds: 2
          livenessProbe:
            httpGet:
              path: /
              port: 80
            initialDelaySeconds: 1
            failureThreshold: 30
            periodSeconds: 5
            timeoutSeconds: 2
```

#### service

```yml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

#### ingress

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
```

#### configmap

```yml
apiVersion: v1
data:
  config.yaml: |
    version: v1
    kk:
      a: b
kind: ConfigMap
metadata:
  name: nginx-configmap
  namespace: default
```

#### secret

确认命名空间有没有设置默认拉取镜像的 secret

`kubectl get serviceaccount default -n <namespace> -o yaml`

创建拉取镜像的 secret

```shell
kubectl create secret docker-registry nexus-secret \
  --docker-server=my-registry.example.com \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com \
  -n default \
  --dry-run=client -o yaml > nexus-secret.yaml
```

编辑 `kubectl edit sa default` 绑定默认的 secret, 

```shell
apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
  namespace: default
imagePullSecrets:
  - name: nexus-secret
```

### 自定义开发者权限

```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: 'msb_developer'
rules:
  - apiGroups:
      - ''
    resources:
      - pods
      - pods/portforward
      - pods/proxy
    verbs:
      - get
      - list
      - watch
      - create
      - delete
  - apiGroups:
      - ''
    resources:
      - pods/attach
      - pods/exec
    verbs:
      - create
      - get
      - list
      - watch
  - apiGroups:
    - ''
    resources:
      - configmaps
      - endpoints
      - persistentvolumeclaims
      - replicationcontrollers
      - replicationcontrollers/scale
      - secrets
      - serviceaccounts
      - services
      - services/proxy
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - ''
    resources:
      - events
      - namespaces/status
      - replicationcontrollers/status
      - pods/log
      - pods/status
      - componentstatuses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - ''
    resources:
      - namespaces
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - apps
    resources:
      - daemonsets
      - deployments
      - deployments/rollback
      - deployments/scale
      - replicasets
      - replicasets/scale
      - statefulsets
    verbs:
      - get
      - list
      - watch
      - patch
  - apiGroups:
    - autoscaling
    resources:
      - horizontalpodautoscalers
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - batch
    resources:
      - cronjobs
      - jobs
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - extensions
    resources:
      - daemonsets
      - deployments
      - deployments/rollback
      - deployments/scale
      - ingresses
      - replicasets
      - replicasets/scale
      - replicationcontrollers/scale
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - networking.k8s.io
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - servicecatalog.k8s.io
    resources:
      - clusterserviceclasses
      - clusterserviceplans
      - clusterservicebrokers
      - serviceinstances
      - servicebindings
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - alicloud.com
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - policy
    resources:
      - poddisruptionbudgets
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - networking.istio.io
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - config.istio.io
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - rbac.istio.io
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - istio.alibabacloud.com
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - authentication.istio.io
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - log.alibabacloud.com
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - monitoring.kiali.io
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
  - apiGroups:
    - eventing.knative.dev
    resources:
      - '*'
    verbs:
      - get
      - list
      - watch
```
