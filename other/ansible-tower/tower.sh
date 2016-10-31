#!/usr/bin/env bash

. /utils.sh

env

yum install -y python-pip
pip install requests --upgrade

wget -N --no-cache https://raw.githubusercontent.com/datacenter/cloudcenter-content/ansible/other/ansible-tower/tower.py

python tower.py $1 $2 $3 $4 $5 --hostname $cliqrNodeHostname
