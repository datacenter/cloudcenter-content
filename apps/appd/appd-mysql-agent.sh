#!/bin/bash -x
# Place this script into your "Post VM Init" and "Pre VM Stop" external lifecycle actions for MySQL
# with a 'add' or 'remove' argument accordingly.

. /utils.sh

print_log "$(env)"

cmd=$1
serviceStatus=""

if [ -n "${appd_db_git_tag}" ]; then
    tag="${appd_db_git_tag}"
else
    tag="appd1.1"
fi

# Setup a bunch of prerequisits

pip install --upgrade pip
pip install --upgrade requests

script_file="appd-mysql-agent.py"

#wget -N $serviceDef -O /serviceDef.json
curl -o ${script_file} https://raw.githubusercontent.com/datacenter/cloudcenter-content/${tag}/apps/appd/appd-mysql-agent.py
python ${script_file} ${cmd}