#!/usr/bin/env bash
exec > >(tee -a /var/tmp/load-simulator-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

agentSendLogMessage  "Waiting for website to be reachable..."
COUNT=0
MAX=100
SLEEP_TIME=10
ERR=0

# Keep checking for haproxy to give proper 401 return to login
until [ "$(curl --write-out %{http_code} --silent --output /dev/null ${CliqrTier_siwapp_haproxy_app_PUBLIC_IP})" -eq "401" ]; do
    sleep ${SLEEP_TIME}
    let "COUNT++"
    echo ${COUNT}
    if [ ${COUNT} -gt ${MAX} ]; then
        ERR=1
        break
    fi
done
if [ ${ERR} -ne 0 ]; then
    agentSendLogMessage "Failed to get proper response from haproxy, so guessing something is wrong."
    exit 1
fi

nohup /usr/bin/python2 /usr/bin/locust --locustfile=/usr/share/systemd/siwapp-locust-file.py --host=http://${CliqrTier_siwapp_haproxy_app_PUBLIC_IP} &>/dev/null &
sleep 5
nohup curl -X POST -F "locust_count=30" -F "hatch_rate=10" http://localhost:8089/swarm &>/dev/null &
while :
do
    true
done
