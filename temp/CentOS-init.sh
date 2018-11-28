#!/bin/bash

# update repo
sudo cp ./CentOS-Base.repo /etc/yum.repos.d/
sudo cp ./kubernetes.repo /etc/yum.repos.d/
sudo yum clean all
sudo yum -y makecache

# update OS 
sudo yum -y update

sudo su -

cd /boot/efi/EFI/redhat/
cp grubx64.efi ../centos/

exit

sudo yum remove docker \
                   docker-client \
                   docker-client-latest \
                   docker-common \
                   docker-latest \
                   docker-latest-logrotate \
                   docker-logrotate \
                   docker-selinux \
                   docker-engine-selinux \
                   docker-engine

# install Docker CE 18.06 from Docker's CentOS repositories:

## Install prerequisites.
sudo yum -y install yum-utils device-mapper-persistent-data lvm2
## Add docker repository.
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
## Install docker.
sudo yum update && sudo yum -y install docker-ce-18.06.1.ce

# Setup daemon.
sudo mkdir /etc/docker/
sudo cp ./daemon.json /etc/docker/

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl daemon-reload
sudo systemctl restart docker

sudo usermod -aG dockerroot pana
sudo usermod -aG docker pana
sudo systemctl restart docker
sudo systemctl enable docker
sudo chmod a+rw /var/run/docker.sock

sudo cp ./k8s.conf /etc/sysctl.d/
sudo sysctl --system

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Stop firewall
sudo systemctl disable firewalld && systemctl stop firewalld

sudo yum install -y kubelet-1.10.1 kubeadm-1.10.1 kubectl-1.10.1 --disableexcludes=kubernetes
sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo su -
swapoff -a
kubeadm join 192.168.1.118:6443 --token odzcnh.x44zgpppdmedd68x --discovery-token-ca-cert-hash sha256:01eff498e77f61a41e8d27af7b348c35153adfcba3b899e09b21eb2bc8be4937

sudo systemctl stop kubelet
sudo iptables --flush
sudo iptables -tnat --flush
sudo systemctl start kubelet

sudo yum install -y rpc-bind nfs-utils
sudo systemctl enable nfs
sudo systemctl enable rpcbind
sudo systemctl start rpcbind
sudo systemctl start nfs

# master
# docker run -d -p 5000:5000 --restart=always --name registry registry

# sudo sysctl net.bridge.bridge-nf-call-iptables=1
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml