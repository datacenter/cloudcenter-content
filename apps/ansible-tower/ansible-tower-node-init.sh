#!/bin/bash -x
exec > >(tee -a /var/tmp/ansible-tower-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

cd /tmp
tower_url=http://172.16.201.244:8081/artifactory/example-repo-local/ansible-tower-setup-latest.tar.gz

agentSendLogMessage  "Downloading setup tar.gz file from ${tower_url}"
tower_gz_file="tower.tar.gz"
curl -o ${tower_gz_file} ${tower_url}

# Get the name of the subdirectory inside the tar.gz file.
ansible_dir=`tar -tf ${tower_gz_file} | head -n1`

agentSendLogMessage  "Extracting tower tar.gz file."
tar -xzvf ${tower_gz_file}
rm -f ${tower_gz_file}

agentSendLogMessage  "Configuring inventory file."
cd /tmp/${ansible_dir}
sed -i.bak -e "s%admin_password=''%admin_password='${tower_admin_password}'%g" \
-e "s%pg_password=''%pg_password='${tower_db_password}'%g" \
-e "s%rabbitmq_password=''%rabbitmq_password='${tower_rabbit_password}'%g" \
inventory

# Move our cliqr repo out of the way.
sudo mv /etc/yum.repos.d/cliqr.repo /tmp/

agentSendLogMessage  "Running installer."
sudo mkdir -p /var/log/tower
sudo ./setup.sh
agentSendLogMessage  "Tower installation complete."

# Put our cliqr repo back.
sudo mv /tmp/cliqr.repo /etc/yum.repos.d/
