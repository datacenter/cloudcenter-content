#!/bin/bash -x
exec > >(tee -a /var/tmp/aic-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# yum install -y unzip

curl -o controller_linux.sh ${appd_installer_url}
curl -o response.varfile ${appd_response_file}
#unzip controller_linux.zip
sudo chmod +x controller_linux.sh

echo "serverHostName=${cliqrNodeHostname}" >> response.varfile

sudo ./controller_linux.sh -q -varfile response.varfile

curl -o /home/appduser/AppDynamics/Controller/license.lic ${appd_license}