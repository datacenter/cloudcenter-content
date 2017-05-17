#!/bin/bash -x
exec > >(tee -a /var/tmp/mon-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

check_error()
{
        status=$1
        msg=$2
        exit_status=$3

        if [[ ${status} -ne 0 ]]; then
                agentSendLogMessage "${msg}"
                exit ${exit_status}
        fi

        return 0
}

dlFile () {
    agentSendLogMessage  "Attempting to download $1"
    if [ -n "$dlUser" ]; then
        agentSendLogMessage  "Found user ${dlUser} specified. Using that and specified password for download auth."
        wget --no-check-certificate --user $dlUser --password $dlPass $1
    else
        agentSendLogMessage  "Didn't find username specified. Downloading with no auth."
        wget --no-check-certificate $1
    fi
    if [ "$?" = "0" ]; then
        agentSendLogMessage  "$1 downloaded"
    else
        agentSendLogMessage  "Error downloading $1"
        exit 1
    fi
}

agentSendLogMessage "Username: $(whoami)" # Should execute as cliqruser
agentSendLogMessage "Working Directory: $(pwd)"

#agentSendLogMessage  "Installing OS Prerequisits wget vim java-1.8.0-openjdk nmap"
sudo mv /etc/yum.repos.d/cliqr.repo ~
#sudo yum update -y
#sudo yum install -y wget
#sudo yum install -y vim
#sudo yum install -y java-1.8.0-openjdk
#sudo yum install -y nmap

# Download necessary files
cd /tmp
agentSendLogMessage  "Downloading installer files."
dlFile ${baseUrl}/installer/core_installer.bin
dlFile ${baseUrl}/appliance/monitor-installer.jar
dlFile ${baseUrl}/appliance/monitor-response.xml

# Set custom repo if desired
if [ -n "$cc_custom_repo" ]; then
    agentSendLogMessage  "Setting custom repo to ${cc_custom_repo}"
    export CUSTOM_REPO=${cc_custom_repo}
fi

# Remove list of installed modules residual from worker installer.
sudo rm -f /etc/cliqr_modules.conf

# Install packages not present in cliqr repo.
sudo yum install -y python-setuptools
sudo yum install -y jbigkit-libs

sudo chmod +x core_installer.bin
agentSendLogMessage  "Running core installer"
sudo -E ./core_installer.bin centos7 ${OSMOSIX_CLOUD} monitor

agentSendLogMessage  "Running jar installer"
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-sun/bin/java 1
sudo java -jar monitor-installer.jar monitor-response.xml

agentSendLogMessage  "Kibana URL: http://${CliqrTier_monitor_PUBLIC_IP}:8882"

rm -f core_installer.bin
rm -f monitor-installer.jar
rm -f monitor-response.xml

sudo mv ~/cliqr.repo /etc/yum.repos.d/

