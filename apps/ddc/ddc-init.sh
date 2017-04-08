#!/bin/bash -x

exec > >(tee -a /var/tmp/ddc_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

export INSTALL=$componentName  
# componentName needs to be defined as a tier parameter in the app provile
# must be one of:
# 	ucp-controller
#	dtr-01
#	ucp-node-01

# set hostname
export HOSTNAME=$INSTALL
sudo hostname $HOSTNAME
sudo sed -i "s/localhost/$HOSTNAME/g" /etc/hosts
sudo sh -c 'echo $HOSTNAME | tee /etc/hostname'

sudo usermod -aG docker cliqruser
sudo systemctl restart docker

export USERNAME=admin
export PASSWORD=ddcpassword
  # need to create the variable containing the tier IP and then use it
export myIPvar=CliqrTier_${cliqrAppTierName}_PUBLIC_IP

### temporary:
touch /tmp/docker_subscription.lic

# install the ucp controller node
if [[ $INSTALL == "ucp-controller" ]]; then
	
	export UCP_CONTROLLER_IP=${!myIPvar} 

	sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v /home/docker/docker_subscription.lic:/tmp/docker_subscription.lic \
		-e UCP_ADMIN_PASSWORD=$PASSWORD \
		-e UCP_ADMIN_USER=$USERNAME \
		--name ucp docker/ucp \
		install --host-address $UCP_CONTROLLER_IP --san $UCP_CONTROLLER_IP 
		
fi

	
# need to get ucp controller fingerprint for install on other servers
if [[ $INSTALL != "ucp-controller" ]]; then

	export no_proxy=$no_proxy,$UCP_CONTROLLER_IP
	sudo curl --insecure https://$UCP_CONTROLLER_IP/ca > ca.pem
	export UCP_FINGERPRINT=`openssl x509 -in ca.pem -noout -sha256 -fingerprint | awk -F= '{ print $2 }'`

fi


# install ucp node
if [[ $INSTALL == "ucp-node-01" ]]; then

	sudo docker run --rm --name ucp \
		-e UCP_ADMIN_USER=$USERNAME \
		-e UCP_ADMIN_PASSWORD=$PASSWORD \
		-v /var/run/docker.sock:/var/run/docker.sock \
		docker/ucp install --url https://$UCP_CONTROLLER_IP \
		--fingerprint $UCP_FINGERPRINT 

fi


if [[ $INSTALL == "dtr-01" ]]; then

	export DTR_IP=${!myIPvar} 
	export UCP_CONTROLLER_IP=$CliqrTier_UCP_PUBLIC_IP # need to parameterize tier name

	sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v /home/docker/docker_subscription.lic:/tmp/docker_subscription.lic \
		-e UCP_ADMIN_PASSWORD=$PASSWORD \
		-e UCP_ADMIN_USER=$USERNAME \
		--name ucp docker/ucp \
		install --host-address $DTR_IP --san $DTR_IP 

	sudo docker run --rm docker/dtr install \
		--ucp-url https://$UCP_CONTROLLER_IP \
		--ucp-node dtr-01 --dtr-external-url $DTR_IP:443 \
		--ucp-username $USERNAME \
		--ucp-password $PASSWORD \
		--replica-http-port 81 --replica-https-port 444 \
		--ucp-insecure-tls # --replica-id 000000000001

fi
