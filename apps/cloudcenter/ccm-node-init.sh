#!/bin/bash -x
(
    . /usr/local/osmosix/etc/.osmosix.sh
    . /usr/local/osmosix/etc/userenv
    . /usr/local/osmosix/service/utils/cfgutil.sh

    env

    echo "Username: $(whoami)" # Should execute as cliqruser
    echo "Working Directory: $(pwd)"

    cd /tmp
    sudo wget -N http://$dlUser:dlPass@download.cliqr.com/dev-20160917.3/installer/core_installer.bin
    sudo wget -N http://$dlUser:dlPass@download.cliqr.com/dev-20160917.3/appliance/ccm-installer.jar
    sudo wget -N http://$dlUser:dlPass@download.cliqr.com/dev-20160917.3/appliance/ccm-response.xml




) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | tee -a /var/tmp/ccm-node-init_$$.log
