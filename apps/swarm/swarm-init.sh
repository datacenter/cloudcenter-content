#!/bin/bash -x
exec > >(tee -a /var/tmp/swarm-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh
cd ~

env

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="swarm"
fi

sudo mv /etc/yum.repos.d/cliqr.repo ~

sudo yum update -y

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum install docker-engine -y

sudo systemctl enable docker.service

sudo systemctl start docker

IFS=','
ipArr=($CliqrTier_CentOS_1_NODE_ID) # Array of nodes in my tier.
master=${arr[0]} # Let the first node in the service tier be the master.






sudo docker swarm init