#!/bin/bash -x
exec > >(tee -a /var/tmp/aic-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# yum install -y unzip

cd /tmp
curl -o controller_linux.sh ${appd_installer_url}
sudo chmod +x controller_linux.sh

curl -o response.varfile ${appd_response_file}
echo -e "\nserverHostName=${cliqrNodeHostname}" >> response.varfile

sudo ./controller_linux.sh -q -varfile response.varfile

sudo curl -o /home/appduser/AppDynamics/Controller/license.lic ${appd_license}

sudo ./controller.sh start-events-service