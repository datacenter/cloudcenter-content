#!/bin/bash -x
# Utility script to run arbitrary script remotely with lifecycle action.
. /utils.sh

# Should be URL of script to download and execute on the node remotely.
script=$1

###########
# All this blob is just to get my own host index so I can pull my IP address from the list.

# The variable name that will hold the list of hostnames in this tier.
hostname_list_variable_name="CliqrTier_${cliqrAppTierName}_HOSTNAME"

# Set internal separator to ',' since they're comma-delimited lists.
temp_ifs=${IFS}
# Iterate through list of hosts to increment
host_index=0
for host in ${!hostname_list_variable_name} ; do
    let host_index=${host_index}+1
done
# Set internal separator back to original.
IFS=${temp_ifs}
############

if [ "${osName}" == "Linux" ]; then
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
    curl -o script.sh ${script}

    # Run the script.
    ssh -i key cliqruser@${node_ip} 'bash -s' < script.sh

else
    # Remote execution isn't supported on Windows right now.
    print_log "Not Linux, so skipping script."
fi
