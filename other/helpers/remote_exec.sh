#!/bin/bash -x
# Utility script to run arbitrary script remotely with lifecycle action.
. /utils.sh

# Should be URL of script to download and execute on the node remotely.
script=$1
print_log "Script for remote execution: ${script}"

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

if [ -z "${node_ip}" ]; then
    print_log "Node IP not found. Exiting normally without running script."
    exit 0
else
    print_log "Node IP found: ${node_ip}"
fi

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
    print_log "Downloading script: ${script}"
    curl -o script.sh ${script}
    cat script.sh

    # Run the script, passing in the command line arguments from this script, minus the first one
    # which was the URL of this script to run.
    echo "Node IP: ${node_ip}"
    ssh -i key cliqruser@${node_ip} 'bash -s' < script.sh "${@:2}"

elif [ "${osName}" == "Windows" ]; then
    if [ -z "${cliqrWindowsPassword}" ];
    then
            print_log "Password for user 'cliqr' not found (cliqrWindowsPassword).
                Perhaps you are running this script to early in the VM lifecycle.
                The password is assigned during node init, so try that or later."
            exit -1
    fi
    prereqs="glibc zlib glibc.i686 which zlib.i686 unzip"
    print_log "Installing prereqs: ${prereqs}"
    yum install -y ${prereqs}

    # Get prebuilt winexe from this zip file.
    wget http://cdn.cliqr.com/release-4.8.1.2-20171117.2/bundle/actions/agent-lite-action.zip
    unzip agent-lite-action.zip
    chmod a+x winexe

    echo "username=cliqr" > authfile
    echo "password=${cliqrWindowsPassword}" >> authfile
    chmod a+x authfile

    wincommand="powershell -ExecutionPolicy bypass -noninteractive -noprofile -Command pwd; \
    Invoke-WebRequest -Uri ${script} -OutFile script.ps1; ./script.ps1; rm script.ps1"
    print_log "Command to be executed on the Windows server: ${wincommand}"
    ./winexe --authentication-file=authfile //${node_ip} "${wincommand}"
    if [ $? -ne 0 ];
    then
        echo "Failed to execute winexe command. Please check to ensure that smb ports 139 and 445 are
        allowed on the guest OS. Try running
        'netsh advfirewall firewall add rule name=winexe dir=in action=allow protocol=TCP localport=\"139,445\"' on your template VM."
        exit -1
    fi
else
    print_log "No supported osName found. Only Windows and Linux are valid."
fi
