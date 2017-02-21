#!/bin/bash -x
exec > >(tee -a /var/tmp/artifactory-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

dlFile () {
    agentSendLogMessage  "Attempting to download $1"
    wget --no-check-certificate $1 -O $2
    if [ "$?" = "0" ]; then
        agentSendLogMessage  "${1} downloaded as ${2}"
    else
        agentSendLogMessage  "Error downloading ${1}"
        exit 1
    fi
}

defaultGitTag="artifactory"
if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

cd /tmp
dlFile https://bintray.com/jfrog/artifactory-rpms/rpm bintray-jfrog-artifactory-rpms.repo
sudo mv bintray-jfrog-artifactory-rpms.repo /etc/yum.repos.d/
sudo yum install jfrog-artifactory-oss