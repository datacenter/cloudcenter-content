#!/bin/bash
. /utils.sh

env

cmd=$1
serviceStatus=""

if [ -n $gitTag ]; then
    tag=$gitTag
else
    tag="master"
fi

# Setup a bunch of prerequisits

pip install --upgrade pip
pip install --upgrade requests

wget -N https://raw.githubusercontent.com/datacenter/cloudcenter-content/$gitTag/services/swarm/deployToSwarm/swarm.py
python swarm.py $cmd