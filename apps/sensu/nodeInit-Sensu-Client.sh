#!/bin/bash -x
(
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh

echo '[sensu]
name=sensu
baseurl=http://repositories.sensuapp.org/yum/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo

sudo yum install sensu -y

echo '{
  "rabbitmq": {
    "host": "52.39.201.20",
    "vhost": "/sensu",
    "user": "sensu",
    "password": "secret"
  }
}' | sudo tee /etc/sensu/config.json

sudo /etc/init.d/sensu-client start


) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | tee -a /var/tmp/nodeInitSensu_$$.log
