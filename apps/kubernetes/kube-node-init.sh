#!/bin/bash -x
# https://kubernetes.io/docs/setup/independent/install-kubeadm/
exec > >(tee -a /var/tmp/kube-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

env

#prereqs=""
#agentSendLogMessage  "Installing OS Prerequisits ${prereqs}"
sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.
sudo yum install -y docker-engine

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl enable docker
sudo systemctl start docker

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
sudo systemctl start kubelet

sudo tee /etc/sysctl.d/k8s.conf <<-'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

IFS=','
nodeArr=(${CliqrTier_kube_NODE_ID}) # Array of nodes in my tier.
ipArr=(${CliqrTier_kube_PUBLIC_IP}) # Array of IPs in my tier.
master=${nodeArr[0]} # Let the first node in the service tier be the master.
master_ip=${ipArr[0]}

if [ "${master}" == "${cliqrNodeId}" ]; then
    # Master code
    agentSendLogMessage "Master"
    sudo swapoff -a
    join_command=$(sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | grep "kubeadm join")
    echo ${join_command} > /home/cliqruser/join_command
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml --validate=false
else
    # Slave code
    agentSendLogMessage "Slave"
    sleep 30

    ssh-keyscan ${master_ip} >> ~/.ssh/known_hosts
    scp cliqruser@${master_ip}:/home/cliqruser/join_command join_command
    cat join_command | sudo bash
fi


sudo mv ~/cliqr.repo /etc/yum.repos.d/
