#!/bin/bash -x
exec > >(tee -a /var/tmp/cco-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

env

agentSendLogMessage  "Username: $(whoami)" # Should execute as cliqruser
agentSendLogMessage  "Working Directory: $(pwd)"

if [ ! -e $OSMOSIX_PROD_HOME/.cliqrRebootResumeInit ]; # First pass through this script.
then
    if [ -n "$ccmIP" ]; then
        agentSendLogMessage  "Found custom parameter ccmIP = ${ccmIP}"
    elif [ -n "$CliqrTier_ccm_IP" ]; then
        agentSendLogMessage  "Didn't find custom parameter ccmIP, but found tier ccm with IP address = ${CliqrTier_ccm_IP}"
        ccmIP=$CliqrTier_ccm_IP
    else
         agentSendLogMessage  "Didn't find custom parameter ccmIP or tier called ccm, so you'll have to configure that yourself by running /usr/local/osmosix/bin/cco_config_wizard.sh as root."
    fi

    if [ -n "$cloud" ]; then
        agentSendLogMessage  "Found custom parameter cloud = ${cloud}"
    else
        agentSendLogMessage  "Didn't find custom parameter cloud. Exiting as failed."
        exit 1
    fi

    if [ -z "$dlUser" ]; then
        agentSendLogMessage  "Didn't find custom parameter dlUser. Exiting as failed."
        exit 1
    fi

    if [ -z "$dlPass" ]; then
        agentSendLogMessage  "Didn't find custom parameter dlPass. Exiting as failed."
        exit 1
    fi

    os="centos7"
    module="rabbit"

    cd /tmp
    sudo wget -N https://$dlUser:$dlPass@download.cliqr.com/dev-20160917.3/installer/core_installer.bin
    if [ $? -ne 0 ]; then
        agentSendLogMessage  "Failed downloading core_installer.bin"
    fi

    sudo wget -N https://$dlUser:$dlPass@download.cliqr.com/dev-20160917.3/appliance/cco-installer.jar
    if [ $? -ne 0 ]; then
        agentSendLogMessage  "Failed downloading cco-installer.jar"
    fi

    sudo wget -N https://$dlUser:$dlPass@download.cliqr.com/dev-20160917.3/appliance/conn_broker-response.xml
    if [ $? -ne 0 ]; then
        agentSendLogMessage  "Failed downloading cco-response.xml"
    fi

    sudo chmod +x core_installer.bin

    sudo mv /etc/yum.repos.d/cliqr.repo . #Get our repo config out of the way so that docker installs properly.
    sudo ./core_installer.bin $os $cloud $module
    if [ $? -ne 0 ]; then
        agentSendLogMessage  "Failed running core_installer.bin"
    fi

    sudo yum install -y java
    if [ $? -ne 0 ]; then
        agentSendLogMessage  "Failed yum install -y java"
    fi

    sudo mv cliqr.repo /etc/yum.repos.d/ #Put the cliqr repo back

    sudo sed -i -e "s/\"rabbit_host\" value=\"default\"/\"rabbit_host\" value=\"${CliqrTier_amqp_PUBLIC_IP}\"/" \
        -e "s/\"conn_broker_host\" value=\"default\"/\"conn_broker_host\" value=\"${CliqrTier_amqp_PUBLIC_IP}\"/" \
        -e "s/\"cco_host\" value=\"default\"/\"cco_host\" value=\"${CliqrTier_cco_IP}\"/" \
        -e "s/\"ccm_host\" value=\"default\"/\"ccm_host\" value=\"${ccmIP}\"/" conn_broker-response.xml

    #sudo java -jar cco-installer.jar conn_broker-response.xml



    # CloudCenter will read this file and trigger a reboot, putting the conents into the marker file $OSMOSIX_PROD_HOME/.cliqrRebootResumeInit
    #sudo touch /tmp/.cliqrRebootResumeInit
    #print_log "Triggering a reboot now..."
else
    agentSendLogMessage  "Reboot complete. Back online and ready."
fi

