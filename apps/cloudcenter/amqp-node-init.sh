#!/bin/bash -x
(

    . /usr/local/osmosix/etc/.osmosix.sh
    . /usr/local/osmosix/etc/userenv
    . /usr/local/osmosix/service/utils/cfgutil.sh

    env

    print_log "Username: $(whoami)" # Should execute as cliqruser
    print_log "Working Directory: $(pwd)"

    if [ ! -e $OSMOSIX_PROD_HOME/.cliqrRebootResumeInit ]; # First pass through this script.
    then
        if [ -n $ccmIP ]; then
            print_log "Found custom parameter ccmIP = ${ccmIP}"
        elif [ -n $CliqrTier_ccm_IP ]; then
            print_log "Didn't find custom parameter ccmIP, but found tier ccm with IP address = ${CliqrTier_ccm_IP}"
            ccmIP=$CliqrTier_ccm_IP
        else
             print_log "Didn't find custom parameter ccmIP or tier called ccm, so you'll have to configure that yourself by running /usr/local/osmosix/bin/cco_config_wizard.sh as root."
        fi

        if [ -n $cloud ]; then
            print_log "Found custom parameter cloud = ${cloud}"
        else
            print_log "Didn't find custom parameter cloudType. Exiting as failed."
            exit 1
        fi

        os="centos7"
        module="rabbit"

        cd /tmp
        sudo wget -N https://$dlUser:$dlPass@download.cliqr.com/dev-20160917.3/installer/core_installer.bin
        sudo wget -N https://$dlUser:$dlPass@download.cliqr.com/dev-20160917.3/appliance/cco-installer.jar
        sudo wget -N https://$dlUser:$dlPass@download.cliqr.com/dev-20160917.3/appliance/conn_broker-response.xml

        sudo chmod +x core_installer.bin

        sudo mv /etc/yum.repos.d/cliqr.repo . #Get our repo config out of the way so that docker installs properly.
        sudo ./core_installer.bin $os $cloud $module
        sudo yum install -y java
        sudo mv cliqr.repo /etc/yum.repos.d/ #Put the cliqr repo back

        sudo sed -i -e "s/\"rabbit_host\" value=\"default\"/\"rabbit_host\" value=\"${CliqrTier_amqp_PUBLIC_IP}\"/" \
            -e "s/\"conn_broker_host\" value=\"default\"/\"conn_broker_host\" value=\"${CliqrTier_amqp_PUBLIC_IP}\"/" \
            -e "s/\"cco_host\" value=\"default\"/\"cco_host\" value=\"${CliqrTier_cco_IP}\"/" \
            -e "s/\"ccm_host\" value=\"default\"/\"ccm_host\" value=\"${ccmIP}\"/" cco-response.xml

        sudo java -jar cco-installer.jar cco-response.xml



        # CloudCenter will read this file and trigger a reboot, putting the conents into the marker file $OSMOSIX_PROD_HOME/.cliqrRebootResumeInit
        sudo touch /tmp/.cliqrRebootResumeInit
        print_log "Triggering a reboot now..."
    else
        print_log "Reboot complete. Back online and ready."
    fi

) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | tee -a /var/tmp/cco-node-init_$$.log
