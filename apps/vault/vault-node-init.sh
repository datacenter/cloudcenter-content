#!/bin/bash -x
exec > >(tee -a /var/tmp/vault-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

cd /tmp
curl -O https://releases.hashicorp.com/vault/0.7.3/vault_0.7.3_linux_amd64.zip
unzip vault_0.7.3_linux_amd64.zip
rm vault_0.7.3_linux_amd64.zip

curl -O https://releases.hashicorp.com/consul/0.8.4/consul_0.8.4_linux_amd64.zip
unzip consul_0.8.4_linux_amd64.zip
rm consul_0.8.4_linux_amd64.zip

mkdir -p ~/bin
mv vault ~/bin
mv consul ~/bin