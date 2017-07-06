#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
. /utils.sh

env

yum install -y openssh-clients

echo "${sshKey}" > key
chmod 400 key

tier_ip_varname=CliqrTier_${cliqrAppTierName}_IP
node_ip=${!tier_ip_varname}

mkdir -p ~/.ssh/
touch ~/.ssh/known_hosts
ssh-keyscan ${node_ip} >> ~/.ssh/known_hosts

curl -o https://raw.githubusercontent.com/datacenter/cloudcenter-content/appd/apps/appd/appd-service-centos.sh

ssh -i key cliqruser@${node_ip} 'bash -s' < appd-service-centos.sh