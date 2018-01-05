#!/bin/bash -x

exec > >(tee -a /var/tmp/apache-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

temp_ifs=${IFS}
IFS=','
nodeArr=(${CliqrTier_siwapp_mariadb_NODE_ID}) # Array of nodes in my tier.
ipArr=(${CliqrTier_siwapp_mariadb_PUBLIC_IP}) # Array of IPs in my tier.
master=${nodeArr[0]} # Let the first node in the service tier be the master.
master_addr=${ipArr[0]} # Let the first node in the service tier be the master.

IFS=${temp_ifs}

if [ "${master}" == "${cliqrNodeId}" ]; then
    sed -i "s/safe_to_bootstrap.*/safe_to_bootstrap: 1/" /var/lib/mysql/grastate.dat
    systemctl set-environment _WSREP_NEW_CLUSTER='--wsrep-new-cluster' && systemctl start mariadb && systemctl set-environment _WSREP_NEW_CLUSTER=''

else
    echo  "Waiting for master node to be initialized..."
    COUNT=0
    MAX=50
    SLEEP_TIME=5
    ERR=0

    # Keep checking for port 3306 on the master to be open
    until $(mysql -h $master_addr -u root -p"${GALERA_DB_ROOT_PWD}" -e ""); do
      sleep ${SLEEP_TIME}
      let "COUNT++"
      echo ${COUNT}
      if [ ${COUNT} -gt ${MAX} ]; then
        ERR=1
        break
      fi
    done
    if [ ${ERR} -ne 0 ]; then
        echo "Failed to find port 3306 open on master node, so guessing something is wrong."
        exit 1
    else
        echo "starting slave"
        systemctl start mariadb
    fi
fi