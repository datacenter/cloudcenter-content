#!/bin/bash -x
exec > >(tee -a /var/tmp/swarm-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh
cd ~

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="swarmapp0.1"
fi

sudo mv /etc/yum.repos.d/cliqr.repo ~

# agentSendLogMessage "Running yum update. This make take a while..."
# sudo yum update -y

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum install -y nmap docker-engine
sudo systemctl enable docker.service



IFS=','
nodeArr=(${CliqrTier_swarm_NODE_ID}) # Array of nodes in my tier.
# ipArr=(${CliqrTier_swarm_PUBLIC_IP}) # Array of IPs in my tier.
master=${nodeArr[0]} # Let the first node in the service tier be the master.


sudo mkdir /etc/systemd/system/docker.service.d -p
sudo tee /etc/systemd/system/docker.service.d/docker.conf <<-'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -D -H tcp://0.0.0.0:2376
EOF

# Added the SSH fingerprint of all the other nodes. To avoid being prompted for this.
for node in "${nodeArr[@]}"; do
    ssh-keyscan ${node} >> ~/.ssh/known_hosts
done

sudo systemctl daemon-reload
sudo systemctl start docker

if [ "${master}" == "${cliqrNodeId}" ]; then
    # I'm the master
    agentSendLogMessage "Master"
    agentSendLogMessage "Initializing swarm..."
    sudo docker -H localhost:2376 swarm init
else
    agentSendLogMessage  "Waiting for master swarm to be initialized..."
    COUNT=0
    MAX=50
    SLEEP_TIME=5
    ERR=0

    # Keep checking for port 2377 on the master to be open
    until $(nmap -p 2377 "${master}" | grep "open" -q); do
      sleep ${SLEEP_TIME}
      let "COUNT++"
      echo ${COUNT}
      if [ ${COUNT} -gt ${MAX} ]; then
        ERR=1
        break
      fi
    done
    if [ ${ERR} -ne 0 ]; then
        agentSendLogMessage "Failed to find port 2377 open on master node, so guessing something is wrong."
    else
        # I'm not the master
        agentSendLogMessage "Not Master"
        # Use SSH to grab the token from the swarm master.
        join_token=`ssh ${master} docker -H localhost:2376 swarm join-token worker -q`
        # Use the token to join the swarm using the master.
        docker -H localhost:2376 swarm join --token ${join_token} ${master}:2377
    fi
fi
