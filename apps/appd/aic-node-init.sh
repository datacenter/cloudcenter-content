#!/bin/bash -x
exec > >(tee -a /var/tmp/aic-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

yum install -y unzip

curl -o controller_linux.zip ${appd_installer_url}
curl -o response.varfile ${appd_response_file}
unzip controller_linux.zip
sudo chmod +x controller_64bit_linux-4.3.3.2.sh
sudo ./controller_64bit_linux-4.3.3.2.sh -q -varfile response.varfile