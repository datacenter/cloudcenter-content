#!/bin/bash -x
exec > >(tee -a /var/tmp/spark-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh


sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.


agentSendLogMessage "Doing yum update"
sudo yum update -y
pre_reqs="java-1.8.0-openjdk"
agentSendLogMessage "Installing pre-reqs: ${pre_reqs}"
sudo yum install -y ${pre_reqs}

cd /tmp
spark_file="spark.tgz"
agentSendLogMessage "Downloading ${spark_package}"
curl -o ${spark_file} "${spark_package}"
spark_folder=`tar -tzf ${spark_file} | head -n1`
tar -xvf ${spark_file} -C ~
rm -f ${spark_file}

ln -s ~/${spark_folder} ~/spark

echo "export JAVA_HOME=/usr/lib/jvm/jre-1.8.0" >> ~/.bashrc
echo "export SPARK_HOME=~/spark" >> ~/.bashrc
echo 'export PATH=${SPARK_HOME}/bin:${PATH}' >> ~/.bashrc
source ~/.bashrc

###########
# All this blob is just to get my own host index so I can pull my IP address from the list.

# The variable name that will hold the list of hostnames in this tier.
hostname_list_variable_name="CliqrTier_${cliqrAppTierName}_HOSTNAME"

# Set internal separator to ',' since they're comma-delimited lists.
temp_ifs=${IFS}
IFS=','

### Create arrays from command lists.
tier_ip_varname=CliqrTier_${cliqrAppTierName}_PUBLIC_IP
ipArr=(${!tier_ip_varname}) # Array of IPs in my tier.
tier_hostname_varname=CliqrTier_${cliqrAppTierName}_HOSTNAME
hostnameArr=(${!tier_hostname_varname}) # Array of hostnames in my tier.
tier_node_varname=CliqrTier_${cliqrAppTierName}_NODE_ID
nodeArr=(${!tier_node_varname}) # Array of hostnames in my tier.
###

# Iterate through list of hosts to increment
my_host_index=0
for host in ${!hostname_list_variable_name} ; do
    if [ ${host} = ${cliqrNodeHostname} ]; then
        # INDEX for this host is current position in array.
        echo "Index: ${my_host_index}"
        break
    fi
    let host_index=${my_host_index}+1
done

## host_index will be the index in the list of this particular host.

# Set internal separator back to original.
IFS=${temp_ifs}
############

node_ip=${ipArr[${my_host_index}]}
master=${nodeArr[0]} # Let the first node in the service tier be the master.

# Added the SSH fingerprint of all the other nodes. To avoid being prompted for this.
host_index=0
domain=`hostname -d`
for host in "${hostnameArr[@]}"; do
    # Add each host and IP to /etc/hosts file so Spark can SSH to them
    sudo su -c "echo '${ipArr[${host_index}]} ${host}.${domain}' >> /etc/hosts"

    # Add each host's key to known hosts so that we aren't prompted to add the key interactively.
    ssh-keyscan ${host}.${domain} >> ~/.ssh/known_hosts

    if [ "${master}" == "${cliqrNodeId}" ]; then
        # I'm the master
        agentSendLogMessage "Master"
        echo "${host}" >> $SPARK_HOME/conf/slaves
    fi

    let host_index=${host_index}+1
done

if [ "${master}" == "${cliqrNodeId}" ]; then
    # I'm the master
    $SPARK_HOME/sbin/start-all.sh
fi





sudo mv ~/cliqr.repo /etc/yum.repos.d/
