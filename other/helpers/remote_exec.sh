#!/bin/bash -x
# Utility script to run arbitrary script remotely with lifecycle action.
. /utils.sh

env

# Should be URL of script to download and execute on the node remotely.
script=$1

###########
# All this blob is just to get my own host index so I can pull my IP address from the list.

# The variable name that will hold the list of hostnames in this tier.
hostname_list_variable_name="CliqrTier_${cliqrAppTierName}_HOSTNAME"
print_log "Hostname List Variable: ${hostname_list_variable_name}"
print_log "Hostname List: ${!hostname_list_variable_name}"
if [ "${hostname_list_variable_name}" == "" ]; then
    print_log "Hostname list variable appears empty, not running script. Exiting normally anyway."
    exit 0
fi

# Set internal separator to ',' since they're comma-delimited lists.
temp_ifs=${IFS}
IFS=','
# Iterate through list of hosts to increment
host_index=0
for host in ${!hostname_list_variable_name} ; do
    if [ ${host} = ${cliqrNodeHostname} ]; then
        # INDEX for this host is current position in array.
        echo "Index: ${host_index}"
        break
    fi
    let host_index=${host_index}+1
done

tier_ip_varname=CliqrTier_${cliqrAppTierName}_PUBLIC_IP
ipArr=(${!tier_ip_varname}) # Array of IPs in my tier.
node_ip=${ipArr[${host_index}]}

# Set internal separator back to original.
IFS=${temp_ifs}
############


if [ "${osName}" == "Linux" ]; then
    yum install -y openssh-clients

    # Get SSH key of cliqruser on node from injected env and stick it in a file.
    echo "${sshKey}" > key
    chmod 400 key

    # Get the IP Address of the node from variable name that includes the name of the tier.

    # Add the node's ssh key to our list of known hosts to avoid being prompted.
    mkdir -p ~/.ssh/
    touch ~/.ssh/known_hosts
    ssh-keyscan ${node_ip} >> ~/.ssh/known_hosts

    # Download the script that you want to run.
    curl -o script.sh ${script}

    # Run the script, passing in the command line arguments from this script, minus the first one
    # which was the URL of this script to run.
    ssh -i key cliqruser@${node_ip} 'bash -s' < script.sh "${@:2}"

else
    # Remote execution isn't supported on Windows right now.
    print_log "Not Linux, so skipping script. This helper script does not support Windows (yet)."
fi
