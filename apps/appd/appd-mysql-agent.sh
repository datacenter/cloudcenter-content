#!/bin/bash -x
# Place this script into your "Post VM Init" and "Pre VM Stop" external lifecycle actions for MySQL
# with a 'add' or 'remove' argument accordingly.

. /utils.sh

cmd=$1
print_log "Command: ${cmd}"
serviceStatus=""

if [ -n "${appd_db_git_tag}" ]; then
    tag="${appd_db_git_tag}"
else
    tag="appd1.1"
fi
print_log "Using appd_git_tag ${tag}"
# Setup a bunch of prerequisits

print_log "Installing pip and requests"
pip install --upgrade pip
pip install --upgrade requests

script_file="appd-mysql-agent.py"
script_url="https://raw.githubusercontent.com/datacenter/cloudcenter-content/${tag}/apps/appd/appd-mysql-agent.py"
print_log "Downloading script: ${script_url}"
curl -o ${script_file} ${script_url}
python ${script_file} ${cmd}