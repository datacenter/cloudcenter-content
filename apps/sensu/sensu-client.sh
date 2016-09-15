#!/bin/bash

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv

# Install Repo
echo '[sensu]
name=sensu
baseurl=http://repositories.sensuapp.org/yum/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo

# Install Sensu
sudo yum install sensu -y

sudo wget -O /etc/sensu/conf.d/rabbitmq.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/rabbitmq.json
sudo wget -O /etc/sensu/conf.d/client.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/client.json

sudo sed -i "s/%SENSU_SERVER_IP%/$SENSU_SERVER_IP/g" /etc/sensu/conf.d/rabbitmq.json
sudo sed -i "s/%TIER_NAME%/$cliqrNodeId/g" /etc/sensu/conf.d/client.json
sudo sed -i "s/%TIER_IP%/$OSMOSIX_PUBLIC_IP/g" /etc/sensu/conf.d/client.json
sudo sed -i "s/%SUBS%/$1/g" /etc/sensu/conf.d/client.json

sudo /opt/sensu/embedded/bin/gem install sensu-plugins-disk-checks --no-ri --no-RDoc
sudo /opt/sensu/embedded/bin/gem install sensu-plugins-process-checks --no-ri --no-RDoc

sudo /etc/init.d/sensu-client start
