#!/bin/bash -x
exec > >(tee -a /var/tmp/jasper-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# http://community.jaspersoft.com/wiki/running-jasperreports-server-bundled-installer-silent-mode

agentSendLogMessage "Username: $(whoami)" # Should execute as cliqruser
agentSendLogMessage "Working Directory: $(pwd)"

defaultGitTag="jasper"
if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

cd /tmp
curl -o installer.run ${jasper_installer}
chmod +x insaller.run

cat > options <<-'EOF'
mode=unattended
installer-language=en
jasperLicenseAccepted=yes
prefix=/opt/jrs63
EOF

sudo ./installer.run --optionfile options
