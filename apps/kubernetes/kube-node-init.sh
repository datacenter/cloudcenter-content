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

###########
# All this blob is just to get my own host index so I can pull my IP address from the list.

# The variable name that will hold the list of hostnames in this tier.
hostname_list_variable_name="CliqrTier_${cliqrAppTierName}_HOSTNAME"

# Set internal separator to ',' since they're comma-delimited lists.
temp_ifs=${IFS}
IFS=','

### Create arrays from command lists.
tier_ip_varname=CliqrTier_${cliqrAppTierName}_PUBLIC_IP
ipArr=(${!tier_ip_varname}) # Array of IPs in my tier.
tier_hostname_varname=CliqrTier_${cliqrAppTierName}_HOSTNAME
hostnameArr=(${!tier_hostname_varname}) # Array of hostnames in my tier.
tier_node_varname=CliqrTier_${cliqrAppTierName}_NODE_ID
nodeArr=(${!tier_node_varname}) # Array of hostnames in my tier.
###

# Iterate through list of hosts to increment
my_host_index=0
for host in ${!hostname_list_variable_name} ; do
    if [ ${host} = ${cliqrNodeHostname} ]; then
        # INDEX for this host is current position in array.
        echo "Index: ${my_host_index}"
        break
    fi
    let host_index=${my_host_index}+1
done

## host_index will be the index in the list of this particular host.

# Set internal separator back to original.
IFS=${temp_ifs}
############

node_ip=${ipArr[${my_host_index}]}
master=${nodeArr[0]} # Let the first node in the service tier be the master.

if [ "${master}" == "${cliqrNodeId}" ]; then
    # Master code
    agentSendLogMessage "Master"
    sudo swapoff -a
    join_command=$(sudo kubeadm init --pod-network-cidr=192.168.0.0/16 | grep "kubeadm join")
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml --validate=false

    # Get SSH key of cliqruser on node from injected env and stick it in a file.
    echo "${sshKey}" > key
    chmod 400 key

    for host in "${hostnameArr[@]}"; do
        # Add each host and IP to /etc/hosts file so Spark can SSH to them
        sudo su -c "echo '${ipArr[${host_index}]} ${host}.${domain}' >> /etc/hosts"

        # Add each host's key to known hosts so that we aren't prompted to add the key interactively.
        ssh-keyscan ${host}.${domain} >> ~/.ssh/known_hosts

        if [ ${host} != ${cliqrNodeHostname} ]; then
            ssh -i key cliqruser@${host} ${join_command}
        fi

        let host_index=${host_index}+1
    done
fi


sudo mv ~/cliqr.repo /etc/yum.repos.d/
