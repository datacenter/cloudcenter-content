#!/usr/bin/env bash

. /utils.sh

env

yum install -y python-pip
pip install requests --upgrade

wget -N https://raw.githubusercontent.com/datacenter/cloudcenter-content/ansible/other/ansible-tower/tower.py

python tower.py $1 $2 $3 $4 --add --hostname xyz