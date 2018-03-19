#!/bin/bash -x
exec > >(tee -a /var/tmp/kube_master-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

env

cd /tmp/

# https://kubernetes.io/docs/setup/independent/install-kubeadm/
sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.

# https://docs.docker.com/engine/installation/linux/docker-ce/centos/#install-docker-ce-1
prereqs="yum-utils device-mapper-persistent-data lvm2"
agentSendLogMessage "Installing prereqs: ${prereqs}"
sudo yum install -y ${prereqs}

agentSendLogMessage "Adding official docker repo."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

agentSendLogMessage "Doing yum update."
sudo yum update -y

agentSendLogMessage "Installing docker-ce"
sudo yum install -y docker-ce
sudo systemctl enable docker
sudo systemctl start docker

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
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
#agentSendLogMessage "Installing kubelet kubeadm kubectl"
#sudo yum install -y kubelet kubeadm kubectl
prereqs="kubelet kubeadm kubectl go git"
agentSendLogMessage "Installing prereqs: ${prereqs}"
sudo yum install -y ${prereqs}
#TODO: get crictl working
go get github.com/kubernetes-incubator/cri-tools/cmd/crictl
sudo systemctl enable kubelet
# sudo systemctl restart kubelet


sudo tee /etc/sysctl.d/k8s.conf <<-'EOF'
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
sudo swapoff -a
# Turn swap off permanently.
sudo sed -i.bak -e '/swap/d' /etc/fstab

# Need to set pod-network subnet, but this is Calico specific
join_command=$(sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | grep "kubeadm join")
echo ${join_command} > /home/cliqruser/join_command
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Using Calico for pod network, but other choices are available.
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml --validate=false

# Install Istio
# https://istio.io/docs/setup/kubernetes/quick-start.html
curl -L https://git.io/getLatestIstio | sh -
cd istio*
export PATH=$PWD/bin:$PATH

kubectl apply -f install/kubernetes/istio-auth.yaml

sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo cp /home/cliqruser/.kube/config /usr/share/nginx/html/config
sudo chmod 644 /usr/share/nginx/html/config

agentSendLogMessage "Kube config file: http://${CliqrTier_kube_master_PUBLIC_IP}/config"

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

sudo mv ~/cliqr.repo /etc/yum.repos.d/
