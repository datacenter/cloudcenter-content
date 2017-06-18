#!/bin/bash
exec > >(tee -a /var/tmp/action-write-secret_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

export VAULT_ADDR=http://127.0.0.1:8200
vault write ${secret_path}