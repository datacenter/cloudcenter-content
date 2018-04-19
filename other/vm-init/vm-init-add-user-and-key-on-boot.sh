#!/bin/bash
# Title		: vm-init.sh
# Description	: A script to do some CloudCenter node initialization stuff, e.g. create user, add keys, etc.
# Author	: jasgrimm
# Date		: 2018-04-16
# Version	: 0.9
# Usage		: bash vm-init.sh - create global paramaters in app profile for username and public key input
# External Vars	: Read in at run time via global paramater - $MY_USER, $MY_KEY
# Internal Vars	: Initialized within srcipt - $CLIQR_HOME

# Source some cliqr variables and scripts
CLIQR_HOME=/usr/local/osmosix
. $CLIQR_HOME/etc/.osmosix.sh
. $CLIQR_HOME/etc/userenv
. $CLIQR_HOME/service/utils/cfgutil.sh
. $CLIQR_HOME/service/utils/install_util.sh
. $CLIQR_HOME/service/utils/os_info_util.sh

# Functions
## Create new user
createUser() {
sudo agentSendLogMessage "Creating new user..."
if [ -f /home/$MY_USER/.ssh/authorized_keys ]; then
	sudo agentSendLogMessage "$MY_USER already exists."
else
	sudo adduser -m -d /home/$MY_USER $MY_USER
	sudo mkdir /home/$MY_USER/.ssh
	sudo chown $MY_USER:$MY_USER /home/$MY_USER/.ssh
	sudo chmod 700 /home/$MY_USER/.ssh

	sudo touch /home/$MY_USER/.ssh/authorized_keys
	sudo chown $MY_USER:$MY_USER /home/$MY_USER/.ssh/authorized_keys
	sudo chmod 600 /home/$MY_USER/.ssh/authorized_keys
	sudo agentSendLogMessage "New user $MY_USER created."
fi
}

## Add user to sudoers
sudoersAdd() {
sudo agentSendLogMessage "Adding $MY_USER to sudoers..."
sudo usermod -aG wheel $MY_USER
sudo -i bash -c "echo \"$MY_USER  ALL= NOPASSWD: ALL\" >> /etc/sudoers"
}

## Insert keys for new user
insertKeys() {
sudo agentSendLogMessage "Adding a new key to $MY_USER authorized_keys..."
sudo bash -c "echo \"## Dynamically inserted key ##\" >> /home/$MY_USER/.ssh/authorized_keys"
sudo bash -c "echo $MY_KEY >> /home/$MY_USER/.ssh/authorized_keys"
}

# Main
sudo agentSendLogMessage "### STARTING VM POST-INIT ###"
createUser
sudoersAdd
insertKeys
sudo agentSendLogMessage "### VM POST-INIT COMPLETE ###"

# Exit
exit 0