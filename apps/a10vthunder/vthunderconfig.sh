#!/bin/bash

# TODO: This whole script to auto-enable the web-ui.
#A10 External Service Script
. /utils.sh

defGitTag="a10"

vThunderIP=${CliqrTier_a10vthunder_PUBLIC_IP}

yum install -y openssh-clients

mkdir -p ~/.ssh/
touch ~/.ssh/known_hosts
ssh-keyscan ${vThunderIP} >> ~/.ssh/known_hosts
echo "${sshKey}" > key
chmod 400 key
ssh-keygen -y -f key > key.pub

# TODO: Make this work using expect:
# no web-service secure-server disable
# web-service secure-port 8443