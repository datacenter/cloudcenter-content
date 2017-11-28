#!/bin/bash -x
exec > >(tee -a /var/tmp/amqp-node-init_$$.log) 2>&1

# . /usr/local/osmosix/etc/.osmosix.sh
# TODO: fix this so that it comes from env variable.
OSMOSIX_CLOUD="vmware"

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

# agentSendLogMessage  "Installing OS Prerequisits wget vim java-1.8.0-openjdk nmap"
sudo mv /etc/yum.repos.d/cliqr.repo ~
sudo mv /usr/local/osmosix/etc/userenv ~ # Move it back at end of script.

# Download necessary files
cd /tmp
agentSendLogMessage  "Downloading installer files."
dlFile ${baseUrl}/installer/core_installer.bin
dlFile ${baseUrl}/appliance/cco-installer.jar
dlFile ${baseUrl}/appliance/conn_broker-response.xml

# Set custom repo if desired
if [ -n "$cc_custom_repo" ]; then
    agentSendLogMessage  "Setting custom repo to ${cc_custom_repo}"
    export CUSTOM_REPO=${cc_custom_repo}
fi

# Remove list of installed modules and logs residual from worker installer.
sudo rm -f /root/cliqr_modules.log
sudo rm -f /etc/cliqr*
sudo rm -rf /usr/local/cliqr

# Install packages not present in cliqr repo.
# sudo yum install -y python-setuptools
# sudo yum install -y jbigkit-libs

sudo chmod +x core_installer.bin
agentSendLogMessage  "Running core installer"
sudo -E ./core_installer.bin centos7 ${OSMOSIX_CLOUD} rabbit

agentSendLogMessage  "Running jar installer"
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-sun/bin/java 1
sudo java -jar cco-installer.jar conn_broker-response.xml

agentSendLogMessage  "Running rabbit_config.sh"
sudo /usr/local/osmosix/bin/rabbit_config.sh

# Use "?" as sed delimiter to avoid escaping all the slashes
#sudo sed -i -e "s?dnsName=?dnsName=${CliqrTier_ccm_PUBLIC_IP}?g" /usr/local/osmosix/etc/gateway_config.properties
#sudo sed -i -e "s?gatewayHost=?gatewayHost=${CliqrTier_cco_PUBLIC_IP}?g" /usr/local/tomcatgua/webapps/access/WEB-INF/gua.properties

#sudo /etc/init.d/guacd start
#sudo -E /etc/init.d/tomcatgua restart
sudo systemctl start cliqr-connection-broker.service
sudo systemctl start cliqr-guacamole-client.service

rm -f core_installer.bin
rm -f cco-installer.jar
rm -f conn_broker-response.xml

sudo mv ~/userenv /usr/local/osmosix/etc/
sudo mv ~/cliqr.repo /etc/yum.repos.d/
