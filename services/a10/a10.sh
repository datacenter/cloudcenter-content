#!/bin/bash
#A10 External Service Script
. /utils.sh

#print_log "$(env)"

cmd=$1
serviceStatus=""

defGitTag="a10."

print_log $(env)

if [ -n "$a10_git_tag" ]; then
    print_log  "Found gitTag parameter gitTag = ${a10_git_tag}"
else
     print_log  "Didn't find custom parameter gitTag. Using gitTag=${defGitTag}"
     a10_git_tag=${defGitTag}
fi

print_log "Installing pip and acos_client"
yum install -y python-pip
pip install pip --upgrade
pip install a10sdk
print_log "Done installing pip and acos_client"

wget --no-check-certificate https://raw.githubusercontent.com/datacenter/cloudcenter-content/${a10_git_tag}/services/a10/a10.py
python a10.py ${cmd}
