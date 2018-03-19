#!/bin/bash

. /utils.sh

gitTag="tn1.1"

# Setup a bunch of prerequisits
print_log "Installing pip and requests"
yum install -y python-pip
pip install --upgrade pip
pip install requests
print_log "Done installing pip and requests"

wget --no-check-certificate https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/other/resource/turbo_placement.py
python turbo_placement.py
