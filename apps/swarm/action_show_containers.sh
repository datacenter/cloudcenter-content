#!/bin/bash -x
exec > >(tee -a /var/tmp/action_show_containers_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh
cd ~

docker -H localhost:2376 ps -a