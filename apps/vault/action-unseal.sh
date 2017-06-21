#!/bin/bash
exec > >(tee -a /var/tmp/action-unseal_$$.log) 2>&1

. /usr/local/osmosix/service/utils/agent_util.sh

export VAULT_ADDR=http://127.0.0.1:8200
vault unseal ${vault_key}

agentSendLogMessage "Unseal Progress: "
