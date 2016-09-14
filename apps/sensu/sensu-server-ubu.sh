#!/bin/bash
# Mostly borrowed from https://sensuapp.org/docs/latest/the-five-minute-install
(

OSSVC_HOME=/usr/local/osmosix/service
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. $OSSVC_HOME/utils/cfgutil.sh
. $OSSVC_HOME/utils/install_util.sh
. $OSSVC_HOME/utils/os_info_util.sh
. /usr/local/osmosix/service/utils/agent_util.sh

if [ -e /etc/redhat-release ]
then
	agentSendLogMessage "redhat-release detected. Not implimented. Skipping"
else
	agentSendLogMessage "redhat-release not detected. Assumng Ubuntu 14.04"
	#Install the Sensu software repositories:
	#Script modified to remove Sensu Enterprise and all prompts:
	sudo wget https://cliqrdemo-repo.s3.amazonaws.com/apps/SensuServer/install.sh
	sudo bash install.sh
	sudo apt-get update

	#Install Redis (>= 1.3.14) from the distribution repository:
	sudo apt-get -y install redis-server curl jq

	#Install the Redis init scripts using the update-rc.d utility, and start Redis:
	sudo update-rc.d redis-server defaults
	sudo /etc/init.d/redis-server start

	#Install Sensu

	sudo apt-get install sensu

	#Configure Sensu by downloading this example configuration file:
	sudo wget -O /etc/sensu/config.json https://sensuapp.org/docs/0.23/files/simple-sensu-config.json

	#Configure the Sensu client by downloading this example configuration file:
	sudo wget -O /etc/sensu/conf.d/client.json https://sensuapp.org/docs/0.23/files/simple-client-config.json

	#Configure a Sensu dashboard by downloading this example configuration file:
	sudo wget -O /etc/sensu/dashboard.json https://sensuapp.org/docs/0.23/files/simple-dashboard-config.json

	#Make sure that the sensu user owns all of the Sensu configuration files:
	sudo chown -R sensu:sensu /etc/sensu

	#Start the Sensu services
	sudo /etc/init.d/sensu-server start
	sudo /etc/init.d/sensu-api start
	sudo /etc/init.d/sensu-client start

	#Verify that your installation is ready to use by querying the
	#Sensu API using the curl utility (and piping the result to the jq utility):
	curl -s http://127.0.0.1:4567/clients | jq .

	#wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
	#echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

	sudo apt-get install uchiwa -y
	sudo wget -O /etc/sensu/uchiwa.json http://env.cliqrtech.com/sensu/uchiwa.json

	# Enable start uichwa
	sudo /etc/init.d/uchiwa start


fi


) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | sudo tee -a /var/log/sensu-setup.log