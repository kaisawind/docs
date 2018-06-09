# Kubernetes集群搭建


## docker

### 安装

```bash
sudo apt-get install docker.io
```
或
```bash
sudo snap install docker
```

### 版本查看

```bash
sudo docker version
```

```
Client:
 Version:	17.12.1-ce
 API version:	1.35
 Go version:	go1.10.1
 Git commit:	7390fc6
 Built:	Wed Apr 18 01:23:11 2018
 OS/Arch:	linux/amd64

Server:
 Engine:
  Version:	17.12.1-ce
  API version:	1.35 (minimum version 1.12)
  Go version:	go1.10.1
  Git commit:	7390fc6
  Built:	Wed Feb 28 17:46:05 2018
  OS/Arch:	linux/amd64
  Experimental:	false
```

## Registry

### 下载registry镜像

```bash
sudo docker pull registry
```

### 启动registry

```bash
sudo docker run -d -p 5000:5000 --restart always registry
```

### 配置docker参数

```bash
sudo vi /etc/default/docker
```

修改DOCKER_OPTS
```
DOCKER_OPTS = "$DOCKER_OPTS --insecure-registries=192.168.1.13:5000"
```

```bash
sudo touch /etc/docker/daemon.json
sudo vi /etc/docker/daemon.json
```

修改daemon.json
```
{"insecure-registries": ["192.168.1.13:5000"]}
```

### 测试registry

```bash
sudo docker push 192.168.1.13:5000/ubuntu
```

### kubeadm 部署kubernetes

#### 安装kubectl kubelet kubeadm

```bash
sudo apt-get update & apt-get install -y apt-transport-https curl
sudo touch /etc/apt/sources.list.d/kubernetes.list
sudo vi /etc/apt/sources.list.d/kubernetes.list
```
追加阿里云软件包地址
```

```

```bash
sudo apt-get update
sudo apt-get install -y kubectl kubeadm kubelet
```

#### 部署master

```bash
sudo kubeadm init
```
