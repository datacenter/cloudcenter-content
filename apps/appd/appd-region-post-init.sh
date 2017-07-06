#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
. /utils.sh

env

if [ "${osName}" -e "Linux" ]; then
    yum install -y openssh-clients

    # Get SSH key of cliqruser on node from injected env and stick it in a file.
    echo "${sshKey}" > key
    chmod 400 key

    # Get the IP Address of the node from variable name that includes the name of the tier.
    tier_ip_varname=CliqrTier_${cliqrAppTierName}_IP
    node_ip=${!tier_ip_varname}

    # Add the node's ssh key to our list of known hosts to avoid being prompted.
    mkdir -p ~/.ssh/
    touch ~/.ssh/known_hosts
    ssh-keyscan ${node_ip} >> ~/.ssh/known_hosts

    # Download the script that you want to run.
    curl -o script.sh https://raw.githubusercontent.com/datacenter/cloudcenter-content/appd/apps/appd/appd-service-centos.sh

    # Run the script.
    ssh -i key cliqruser@${node_ip} 'bash -s' < script.sh

else
    # Remote execution isn't supported on Windows right now.
    print_log "Not Linux, so skipping appd agent install."
fi
