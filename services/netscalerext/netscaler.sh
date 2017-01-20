#!/usr/bin/env bash


if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="netscalerext"
fi


yum install -y python-pip
pip install pip --upgrade
pip install nsnitro

wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/services/netscalerext/netscaler.py
python netscaler.py