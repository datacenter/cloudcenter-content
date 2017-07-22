#!/bin/bash -x
exec > >(tee -a /var/tmp/jasper-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh


agentSendLogMessage "Username: $(whoami)" # Should execute as cliqruser
agentSendLogMessage "Working Directory: $(pwd)"

defaultGitTag="jasper"
if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

wget  --no-check-certificate https://downloads.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%206.3.0/jasperreports-server-cp-6.3.0-linux-x64-installer.run?r=http%3A%2F%2Fcommunity.jaspersoft.com%2Fproject%2Fjasperreports-server%2Freleases&ts=1488328500&use_mirror=svwh -O jasperreports-server-cp-6.3.0-linux-x64-installer.run
