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

consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1 &

# Note, disabling mlock is insecure as it allows memory to be swapped to disk
# which may contain secrets. It's disabled here to avoid running as root.
cat > example.hcl <<-'EOF'
backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault"
}

listener "tcp" {
 address = "127.0.0.1:8200"
 tls_disable = 1
}

disable_mlock = true
EOF
export VAULT_ADDR=http://127.0.0.1:8200
vault server -config=example.hcl &
vault init > vault_init_log
agentSendLogMessage $(grep "Unseal Key" vault_init_log)
agentSendLogMessage $(grep "Initial Root Token" vault_init_log)