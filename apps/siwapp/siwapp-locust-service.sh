#!/usr/bin/env bash
exec > >(tee -a /var/tmp/load-simulator-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

nohup /usr/bin/python2 /usr/bin/locust --locustfile=/usr/share/systemd/siwapp-locust-file.py --host=http://${CliqrTier_siwapp_haproxy_app_PUBLIC_IP} &>/dev/null &
sleep 5
nohup curl -X POST -F "locust_count=300" -F "hatch_rate=5" http://localhost:8089/swarm &>/dev/null &
while :
do
    true
done
