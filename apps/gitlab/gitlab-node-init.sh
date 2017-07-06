#!/bin/bash -x
exec > >(tee -a /var/tmp/gitlab-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

sudo yum install -y curl policycoreutils openssh-server openssh-clients
sudo systemctl enable sshd
sudo systemctl start sshd
sudo yum install -y postfix
sudo systemctl enable postfix
sudo systemctl start postfix

sudo yum install -y firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld

agentSendLogMessage "Downloading and installing gitlab. 1GB, so may take a while."
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
sudo yum install -y gitlab-ce

agentSendLogMessage "Configuring and starting gitlab."
sudo gitlab-ctl reconfigure