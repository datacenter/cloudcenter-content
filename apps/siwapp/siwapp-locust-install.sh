#!/usr/bin/env bash
exec > >(tee -a /var/tmp/load-simulator-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

sudo mv /etc/yum.repos.d/cliqr.repo ~

sudo yum -y update
sudo yum install -y epel-release
sudo yum install -y python-pip
sudo yum install -y python-devel gcc
sudo pip install pip --upgrade
sudo pip install locustio lxml requests

sudo curl -o /usr/share/systemd/siwapp-locust-file.py https://raw.githubusercontent.com/datacenter/cloudcenter-content/${siwapp_git_tag}/apps/siwapp/siwapp-locust-file.py
sudo curl -o /usr/share/systemd/siwapp-locust-service.sh https://raw.githubusercontent.com/datacenter/cloudcenter-content/${siwapp_git_tag}/apps/siwapp/siwapp-locust-service.sh

sudo su -c "echo $'
[Unit]
Description=siwapp-simulator

[Service]
Type=simple
User=root
ExecStart=/usr/bin/bash /usr/share/systemd/siwapp-locust-service.sh
Restart=on-abort


[Install]
WantedBy=multi-user.target'\
>> /etc/systemd/system/siwapp-simulator.service
" 
sudo systemctl daemon-reload
sudo systemctl enable siwapp-simulator
sudo systemctl start siwapp-simulator

sudo mv ~/cliqr.repo /etc/yum.repos.d/