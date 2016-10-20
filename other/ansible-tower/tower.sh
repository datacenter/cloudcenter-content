#!/usr/bin/env bash

. /utils.sh

env

wget -N https://raw.githubusercontent.com/datacenter/cloudcenter-content/ansible/other/ansible-tower/tower.py

python tower.py $1 $2 $3