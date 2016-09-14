#!/bin/bash
(
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/agent_util.sh

# Install Sensu
if [ -e /etc/redhat-release ]
then
	agentSendLogMessage "redhat-release detected. Adding sensu repo to yum."
	echo '[sensu]
name=sensu
baseurl=http://repositories.sensuapp.org/yum/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo
	agentSendLogMessage "Using yum to install sensu"
	sudo yum install sensu -y
else
	wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
	echo "deb     http://repositories.sensuapp.org/apt sensu main" | sudo tee /etc/apt/sources.list.d/sensu.list
	sudo apt-get update
	sudo apt-get install sensu -y
fi

agentSendLogMessage "Downloading rabbitmq.json and client.json from env.cliqrtech.com"
sudo wget -O /etc/sensu/conf.d/rabbitmq.json http://env.cliqrtech.com/sensu/client/rabbitmq.json
sudo wget -O /etc/sensu/conf.d/client.json http://env.cliqrtech.com/sensu/client/client.json

agentSendLogMessage "Configuring json files."
sudo sed -i "s/%SENSU_SERVER_IP%/$SENSU_SERVER_IP/g" /etc/sensu/conf.d/rabbitmq.json
sudo sed -i "s/%TIER_NAME%/$cliqrNodeId/g" /etc/sensu/conf.d/client.json
sudo sed -i "s/%TIER_IP%/$OSMOSIX_PUBLIC_IP/g" /etc/sensu/conf.d/client.json

agentSendLogMessage "Installing Sensu Gems."
sudo /opt/sensu/embedded/bin/gem install sensu-plugins-disk-checks --no-ri --no-RDoc
sudo /opt/sensu/embedded/bin/gem install sensu-plugins-process-checks --no-ri --no-RDoc

agentSendLogMessage "Starting Sensu"
sudo /etc/init.d/sensu-client start
) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | sudo tee -a /var/log/sensu-setup.log