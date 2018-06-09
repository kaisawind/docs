# Kubernetes集群搭建

## 1. docker

### 1.1 安装

```bash
sudo apt-get install docker.io
```

或

```bash
sudo snap install docker
```

### 1.2 版本查看

```bash
sudo docker version
```

```text
Client:
 Version: 17.12.1-ce
 API version: 1.35
 Go version: go1.10.1
 Git commit: 7390fc6
 Built: Wed Apr 18 01:23:11 2018
 OS/Arch: linux/amd64

Server:
 Engine:
  Version: 17.12.1-ce
  API version: 1.35 (minimum version 1.12)
  Go version: go1.10.1
  Git commit: 7390fc6
  Built: Wed Feb 28 17:46:05 2018
  OS/Arch: linux/amd64
  Experimental: false
```

## 2. Registry

### 2.1 下载registry镜像

```bash
sudo docker pull registry
```

### 2.2 启动registry

```bash
sudo docker run -d -p 5000:5000 --restart always registry
```

### 2.3 配置docker参数

```bash
sudo vi /etc/default/docker
```

修改DOCKER_OPTS

```bash
DOCKER_OPTS = "$DOCKER_OPTS --insecure-registries=192.168.1.13:5000"
```

```bash
sudo touch /etc/docker/daemon.json
sudo vi /etc/docker/daemon.json
```

修改daemon.json

```bash
{"insecure-registries": ["192.168.1.13:5000"]}
```

### 2.4 测试registry

```bash
sudo docker push 192.168.1.13:5000/ubuntu
```

## 3. kubeadm 部署kubernetes

### 3.1 安装kubectl kubelet kubeadm

```bash
curl -s https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
```

```bash
sudo apt-get update & apt-get install -y apt-transport-https curl
sudo touch /etc/apt/sources.list.d/kubernetes.list
sudo vi /etc/apt/sources.list.d/kubernetes.list
```

追加阿里云软件包地址
追加地址时需要到阿里云去看看最新的版本是哪个。

https://mirrors.aliyun.com/kubernetes/apt/dists/

```text
Index of /kubernetes/apt/dists/
../
kubernetes-jessie/                                 07-Mar-2018 02:51                   -
kubernetes-jessie-unstable/                        07-Mar-2018 02:51                   -
kubernetes-lucid/                                  07-Mar-2018 02:51                   -
kubernetes-lucid-unstable/                         07-Mar-2018 02:51                   -
kubernetes-precise/                                07-Mar-2018 02:51                   -
kubernetes-precise-unstable/                       07-Mar-2018 02:51                   -
kubernetes-squeeze/                                07-Mar-2018 02:51                   -
kubernetes-squeeze-unstable/                       07-Mar-2018 02:51                   -
kubernetes-stretch/                                07-Mar-2018 02:51                   -
kubernetes-stretch-unstable/                       07-Mar-2018 02:51                   -
kubernetes-trusty/                                 07-Mar-2018 02:51                   -
kubernetes-trusty-unstable/                        07-Mar-2018 02:51                   -
kubernetes-wheezy/                                 07-Mar-2018 02:51                   -
kubernetes-wheezy-unstable/                        07-Mar-2018 02:51                   -
kubernetes-xenial/                                 07-Mar-2018 02:51                   -
kubernetes-xenial-unstable/                        07-Mar-2018 02:51                   -
kubernetes-yakkety/                                07-Mar-2018 02:51                   -
kubernetes-yakkety-unstable/                       07-Mar-2018 02:51                   -
minikube-jessie/                                   07-Mar-2018 02:51                   -
minikube-lucid/                                    07-Mar-2018 02:51                   -
minikube-precise/                                  07-Mar-2018 02:51                   -
minikube-squeeze/                                  07-Mar-2018 02:51                   -
minikube-trusty/                                   07-Mar-2018 02:51                   -
minikube-wheezy/                                   07-Mar-2018 02:51                   -
```

```bash
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
```

```bash
sudo apt-get update
sudo apt-get install -y kubectl kubeadm kubelet
```

### 3.2 部署master

#### 3.2.1 准备google镜像

通过github和dockerhub的关联获取墙外google服务器上的镜像

- 在github上建立代码库

```text
┍googlecontainer
┝fluentd-elasticsearch
┝...
```

- 在dockerhub上建立镜像库

create auto-build(github)

build-setting选项里面选择要build的github库路径

- docker pull

- docker tag kaisawind/kube-scheduler-amd64 k8s.gcr.io/kube-scheduler-amd64

#### 3.2.2 kubeadm init需要的镜像

通过/etc/kubernetes/manifests/下的yml能够获取配置的yaml，从而能够获取镜像的版本

```text
REPOSITORY                                 TAG                 IMAGE ID            CREATED             SIZE
kaisawind/kube-scheduler-amd64             v1.10.4             a72b2358835b        10 minutes ago      50.4MB
k8s.gcr.io/kube-scheduler-amd64            v1.10.4             a72b2358835b        10 minutes ago      50.4MB
kaisawind/kube-controller-manager-amd64    v1.10.4             bbbe4196e77b        13 minutes ago      148MB
k8s.gcr.io/kube-controller-manager-amd64   v1.10.4             bbbe4196e77b        13 minutes ago      148MB
kaisawind/kube-apiserver-amd64             v1.10.4             f4dae26f9b59        17 minutes ago      225MB
k8s.gcr.io/kube-apiserver-amd64            v1.10.4             f4dae26f9b59        17 minutes ago      225MB
kaisawind/etcd-amd64                       3.1.12              f3d7556a4007        21 minutes ago      193MB
k8s.gcr.io/etcd-amd64                      3.1.12              f3d7556a4007        21 minutes ago      193MB
registry                                   latest              d1fd7d86a825        5 months ago        33.3MB
```

/etc/kubernetes/manifests/etcd.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    component: etcd
    tier: control-plane
  name: etcd
  namespace: kube-system
spec:
  containers:
  - command:
    - etcd
    - --peer-client-cert-auth=true
    - --cert-file=/etc/kubernetes/pki/etcd/server.crt
    - --key-file=/etc/kubernetes/pki/etcd/server.key
    - --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
    - --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
    - --advertise-client-urls=https://127.0.0.1:2379
    - --client-cert-auth=true
    - --data-dir=/var/lib/etcd
    - --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
    - --listen-client-urls=https://127.0.0.1:2379
    image: k8s.gcr.io/etcd-amd64:3.1.12
    livenessProbe:
      exec:
        command:
        - /bin/sh
        - -ec
        - ETCDCTL_API=3 etcdctl --endpoints=127.0.0.1:2379 --cacert=/etc/kuberne                                                                                                                                                                                                                                                                                               tes/pki/etcd/ca.crt
          --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kube                                                                                                                                                                                                                                                                                               rnetes/pki/etcd/healthcheck-client.key
          get foo
      failureThreshold: 8
      initialDelaySeconds: 15
      timeoutSeconds: 15
    name: etcd
    resources: {}
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd-data
    - mountPath: /etc/kubernetes/pki/etcd
      name: etcd-certs
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki/etcd
      type: DirectoryOrCreate
    name: etcd-certs
  - hostPath:
      path: /var/lib/etcd
      type: DirectoryOrCreate
    name: etcd-data
status: {}
```

/etc/kubernetes/manifests/kube-apiserver.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --insecure-port=0
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --requestheader-username-headers=X-Remote-User
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-allowed-names=front-proxy-client
    - --service-cluster-ip-range=10.96.0.0/12
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    - --secure-port=6443
    - --enable-bootstrap-token-auth=true
    - --allow-privileged=true
    - --requestheader-group-headers=X-Remote-Group
    - --advertise-address=192.168.1.16
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --authorization-mode=Node,RBAC
    - --etcd-servers=https://127.0.0.1:2379
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    image: k8s.gcr.io/kube-apiserver-amd64:v1.10.4
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 192.168.1.16
        path: /healthz
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 15
      timeoutSeconds: 15
    name: kube-apiserver
    resources:
      requests:
        cpu: 250m
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
status: {}
```

/etc/kubernetes/manifests/kube-controller-manager.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    component: kube-controller-manager
    tier: control-plane
  name: kube-controller-manager
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-controller-manager
    - --use-service-account-credentials=true
    - --controllers=*,bootstrapsigner,tokencleaner
    - --service-account-private-key-file=/etc/kubernetes/pki/sa.key
    - --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
    - --address=127.0.0.1
    - --leader-elect=true
    - --kubeconfig=/etc/kubernetes/controller-manager.conf
    - --root-ca-file=/etc/kubernetes/pki/ca.crt
    - --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
    - --allocate-node-cidrs=true
    - --cluster-cidr=10.244.0.0/16
    - --node-cidr-mask-size=24
    image: k8s.gcr.io/kube-controller-manager-amd64:v1.10.4
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10252
        scheme: HTTP
      initialDelaySeconds: 15
      timeoutSeconds: 15
    name: kube-controller-manager
    resources:
      requests:
        cpu: 200m
    volumeMounts:
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/kubernetes/controller-manager.conf
      name: kubeconfig
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/kubernetes/controller-manager.conf
      type: FileOrCreate
    name: kubeconfig
status: {}
```

/etc/kubernetes/manifests/kube-scheduler.yaml

```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    component: kube-scheduler
    tier: control-plane
  name: kube-scheduler
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-scheduler
    - --leader-elect=true
    - --kubeconfig=/etc/kubernetes/scheduler.conf
    - --address=127.0.0.1
    image: k8s.gcr.io/kube-scheduler-amd64:v1.10.4
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 127.0.0.1
        path: /healthz
        port: 10251
        scheme: HTTP
      initialDelaySeconds: 15
      timeoutSeconds: 15
    name: kube-scheduler
    resources:
      requests:
        cpu: 100m
    volumeMounts:
    - mountPath: /etc/kubernetes/scheduler.conf
      name: kubeconfig
      readOnly: true
  hostNetwork: true
  volumes:
  - hostPath:
      path: /etc/kubernetes/scheduler.conf
      type: FileOrCreate
    name: kubeconfig
status: {}
```

#### 3.2.3 kubeadm init

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chwon $(id -u):$(id -g) $HOME/.kube/config
```

```bash
kubeadm join 192.168.1.16 --token kmau6d.g5057mxjhx2uy760 --discovery-token-ca-cert-hash sha256:4163fe5c8fc00829bc4fb09ccaee5757896a32b1bda9ffe33ec8c55eb9234ea1
```
