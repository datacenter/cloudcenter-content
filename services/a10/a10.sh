#!/bin/bash
#A10 External Service Script
. /utils.sh

#print_log "$(env)"

cmd=$1
serviceStatus=""

defGitTag="a10."

if [ -n "$a10_gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${a10_gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=${defGitTag}"
     a10_gitTag=${defGitTag}
fi

print_log "Installing pip and acos_client"
yum install -y python-pip
pip install pip --upgrade
pip install acos_client
print_log "Done installing pip and acos_client"

wget --no-check-certificate https://raw.githubusercontent.com/datacenter/cloudcenter-content/${a10_gitTag}/services/a10/a10.py
python a10.py ${cmd}
