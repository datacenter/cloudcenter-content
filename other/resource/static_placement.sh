#!/bin/bash

. /utils.sh

env

gitTag="resource"

# Setup a bunch of prerequisits
#print_log "Installing pip and requests"
#yum install -y python-pip
#pip install --upgrade pip
#pip install requests
#print_log "Done installing pip and requests"

wget --no-check-certificate https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/other/resource/static_placement.py
python static_placement.py
