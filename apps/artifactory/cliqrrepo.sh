#!/bin/bash -x
exec > >(tee -a /var/tmp/cliqrreposetup_$$.log) 2>&1

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

sudo mv /etc/yum.repos.d/cliqr.repo ~

cd /tmp
curl -fL https://getcli.jfrog.io | sh

wget --no-check-certificate --user=${dlUser} --password=${dlPass} https://download.cliqr.com/release-4.7.3-20170420.1/bundle/bundle_artifacts.zip


sudo sudo mv ~/cliqr.repo /etc/yum.repos.d/