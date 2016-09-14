#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo, or as root"
    exit 1
fi

grep -i 'ubuntu\|debian' /etc/issue > /dev/null 2>&1
issue=$?
if [ $issue -ne 0 ]; then
    echo "This script must be run on Ubuntu or Debian only"
    exit 1
fi

# update apt, install depenedencies
echo "Installing dependencies..."
apt-get install -y curl > /dev/null


install_core ()
{
    echo "...installing the Sensu Core software repository..."
    wget -q http://repositories.sensuapp.org/apt/pubkey.gpg -O- | apt-key add - > /dev/null 2>&1
    echo "deb     http://repositories.sensuapp.org/apt sensu main" | tee /etc/apt/sources.list.d/sensu.list > /dev/null 2>&1
    echo "SUCCESS!"
    success=1
}


if [ -e /etc/apt/sources.list.d/sensu.list ]; then
read -r -p "A repository definition already exists at /etc/apt/sources.list.d/sensu.list, do you want to overwrite it? (y/N): " core_exists
core_exists=${core_exists,,}
	if [[ $core_exists =~ ^(yes|y)$ ]]; then
    install_core
else
    echo "...skipping installation of the Sensu Core software repository..."
fi
else
install_core
fi

if [[ $success -eq 1 ]]; then
   echo "Thank you for using Sensu! #monitoringlove"
fi
