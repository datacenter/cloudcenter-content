#!/bin/bash
#F5 External Service Script
. /utils.sh

# Print the env to the CCM UI for debugging. Remove this line for production.
# Ues with:
# sed -n '/718WPR53 ENV START/,/718WPR53 ENV END/p' /usr/local/cliqr/logs/gateway.log | \
# head -n-1 | tail -n+2 | grep '=' | grep -v '\\n' > envfile

echo "${parentJobName} ENV START"
print_log "$(env)"
echo "${parentJobName} ENV END"

cmd=$1
print_log "cmd: ${cmd}"
serviceStatus=""

defGitTag="f5ext"

if [ -n "${gitTag}" ]; then
    print_log  "Found gitTag parameter gitTag = ${gitTag}"
else
     print_log  "Didn't find custom parameter gitTag. Using gitTag=${defGitTag}"
     gitTag=${defGitTag}
fi

# yum install -y epel-release
yum install -y python-pip wget

pip install pip --upgrade
pip install setuptools --upgrade
pip install requests --upgrade
pip install bigsuds --upgrade
pip install six --upgrade
# pip install f5-sdk --upgrade
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/services/f5ext/f5.py -O f5.py

case ${cmd} in
    start)
        serviceStatus="Starting"
        python f5.py start

        serviceStatus="Started"
        ;;
    stop)
        serviceStatus="Stopping"
        python f5.py stop
        serviceStatus="Stopped"
        ;;
    update)
        serviceStatus="Updating"
        python f5.py reload
        serviceStatus="Updated"
        ;;
    *)
        serviceStatus="No Valid Script Argument"
        exit 127
        ;;
esac
