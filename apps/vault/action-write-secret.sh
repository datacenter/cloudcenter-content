#!/bin/bash -x
exec > >(tee -a /var/tmp/action-write-secret_$$.log) 2>&1

. /usr/local/osmosix/service/utils/agent_util.sh

env

export VAULT_ADDR=http://127.0.0.1:8200
vault auth ${vault_token}
vault write ${secret_path} ${vault_secrets}
agentSendLogMessage  "Secret Written."
