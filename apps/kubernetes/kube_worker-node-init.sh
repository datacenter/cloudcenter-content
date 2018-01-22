#!/bin/bash -x
# https://kubernetes.io/docs/setup/independent/install-kubeadm/
exec > >(tee -a /var/tmp/kube_worker-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

env

cd /tmp/

#prereqs=""
#agentSendLogMessage  "Installing OS Prerequisits ${prereqs}"
sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.
#sudo yum install -y docker-engine

prereqs="yum-utils device-mapper-persistent-data lvm2"
agentSendLogMessage "Installing prereqs: ${prereqs}"
sudo yum install -y "${prereqs}"

agentSendLogMessage "Adding official docker repo."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

agentSendLogMessage "Installing docker-ce"
sudo yum install -y docker-ce

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl enable docker
sudo systemctl restart docker

sudo tee /etc/yum.repos.d/kubernetes.repo <<-'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo setenforce 0
agentSendLogMessage "Installing kubelet kubeadm kubectl"
sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet
sudo systemctl restart kubelet

sudo tee /etc/sysctl.d/k8s.conf <<-'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

ssh-keyscan ${CliqrTier_kube_master_IP} >> ~/.ssh/known_hosts
scp cliqruser@${CliqrTier_kube_master_IP}:/home/cliqruser/join_command join_command
sudo swapoff -a
cat join_command | sudo bash
mkdir -p $HOME/.kube
scp cliqruser@${CliqrTier_kube_master_IP}:/home/cliqruser/.kube/config $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



sudo mv ~/cliqr.repo /etc/yum.repos.d/
