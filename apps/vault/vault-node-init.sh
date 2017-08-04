#!/bin/bash -x
exec > >(tee -a /var/tmp/vault-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

cd /tmp

sudo yum install -y wget unzip

wget https://releases.hashicorp.com/vault/0.7.3/vault_0.7.3_linux_amd64.zip
unzip vault_0.7.3_linux_amd64.zip
rm vault_0.7.3_linux_amd64.zip

wget https://releases.hashicorp.com/consul/0.8.4/consul_0.8.4_linux_amd64.zip
unzip consul_0.8.4_linux_amd64.zip
rm consul_0.8.4_linux_amd64.zip

sudo mv vault /usr/bin
sudo mv consul /usr/bin

# Note, disabling mlock is insecure as it allows memory to be swapped to disk
# which may contain secrets. It's disabled here to avoid running as root.
# Also the vault listener is set to listen on ALL IP ADDRESSES, WHICH IS A
# SECURITY ISSUE IN PRODUCTION SCENARIO.
cat > example.hcl <<-'EOF'
backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault"
}

listener "tcp" {
 address = "0.0.0.0:8200"
 tls_disable = 1
}

disable_mlock = true
EOF
sudo mv example.hcl /etc/vault.conf

cat > consul.service <<-'EOF'
[Unit]
Description=Consulserverprocess
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/bin/consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1
EOF
sudo mv consul.service /etc/systemd/system/
sudo systemctl start consul.service
sudo systemctl enable consul

# TODO: Verify this isn't needed.
# consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul -bind 127.0.0.1 &
# Wait 10 seconds to give consul a chance to start
sleep 10

cat > vault.service <<-'EOF'
[Unit]
Description=vault server
Requires=network-online.target consul.service
After=network-online.target consul.service

[Service]
Restart=on-failure
ExecStart=/usr/bin/vault server -config=/etc/vault.conf
EOF
sudo mv vault.service /etc/systemd/system/
sudo systemctl start vault.service
sudo systemctl enable vault

# TODO: Verify this isn't needed.
# Wait 10 seconds to give vault a chance to start
sleep 10

echo "export VAULT_ADDR=http://127.0.0.1:8200" >> ~/.bash_profile
export VAULT_ADDR=http://127.0.0.1:8200
vault init > vault_init_log
agentSendLogMessage $(grep "Unseal Key" vault_init_log)
agentSendLogMessage $(grep "Initial Root Token" vault_init_log)

# TODO: Enable logging. This doesn't work yet as command requires vault to be unsealed first.
# sudo -E vault audit-enable file file_path=/var/log/vault_audit.log