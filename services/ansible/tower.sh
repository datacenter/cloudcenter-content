#!/usr/bin/env bash

. /utils.sh

env

yum install -y python-pip
pip install ansible-tower-cli

eval IP="\$CliqrTier_${cliqrAppName}_PUBLIC_IP"

case "$5" in
	create)
		./dnsimple.py $cliqrNodeHostname $IP
		tower-cli host create -h $1 -u $2 -p $3 -i $4 -n $cliqrNodeHostname
		#tower-cli host associate -h $1 -u $2 -p $3 --host $cliqrNodeHostname --group $6
		;;
	delete)
		#./dnsimple.py $cliqrNodeHostname $IP
		tower-cli host delete -h $1 -u $2 -p $3 -i $4 -n $cliqrNodeHostname
		;;
esac