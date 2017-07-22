#!/bin/bash
. /utils.sh


if [ -n "$gitTag" ]; then
    print_log  "Found gitTag parameter gitTag = ${gitTag}"
else
    print_log  "Didn't find custom parameter gitTag. Using gitTag=master"
    gitTag="netscalerext"
fi

cmd=$1

yum install -y python-pip
pip install pip --upgrade
pip install nsnitro

wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/services/netscalerext/netscaler.py
python netscaler.py ${cmd}