#!/bin/bash -x

exec > >(tee -a /var/tmp/ddc_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

export INSTALL=ucp-controller

# set hostname
export HOSTNAME=$INSTALL
sudo hostname $HOSTNAME
sudo sed -i "s/localhost/$HOSTNAME/g" /etc/hosts
sudo sh -c 'echo $HOSTNAME | tee /etc/hostname'

# install docker-engine

# check if docker is already installed, before installing
docker --version | grep "Docker version"
#if [[ `docker --version | grep "Docker version"` ]]; then
if [[ $? -ne 0 ]]; then
	# packages in the cliqr repo interfere with the docker install
	sudo mv /etc/yum.repos.d/cliqr.repo /tmp/cliqr.repo.bak
	sudo curl -fsSL https://get.docker.com/ | sh
	#sudo curl -SLf https://packages.docker.com/1.13/install.sh  | sh
	sudo mv /tmp/cliqr.repo.bak /etc/yum.repos.d/cliqr.repo
fi
sudo usermod -aG docker cliqruser
sudo usermod -aG docker root
sudo systemctl restart docker

# if $http_proxy is defined, need to configure docker for it
if [[ -n "$http_proxy" ]]; then
	cd /etc/systemd/system
	sudo mkdir docker.service.d
	cd docker.service.d
	sudo sh -c 'echo "[Service]" >> http-proxy.conf'
	sudo sh -c 'echo "Environment="\""HTTP_PROXY="$0\" "\""HTTPS_PROXY="$0"\" >> http-proxy.conf' $http_proxy
	sudo systemctl daemon-reload
	sudo systemctl restart docker
fi

#check that firewalld is installed 
if ! [ -x "$(command -v firewall-cmd)" ]; then
	sudo yum -y install firewalld
	sudo systemctl unmask firewalld
	sudo systemctl enable firewalld
	sudo systemctl start firewalld
fi

# open needed ports
sudo firewall-cmd --permanent --zone=public --add-port=4789/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12376/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12379/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12380/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12381/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12382/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12383/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12384/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12385/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12386/tcp
sudo firewall-cmd --permanent --zone=public --add-port=12387/tcp
sudo firewall-cmd --permanent --zone=public --add-port=2376/tcp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
sudo firewall-cmd --reload


# install the ucp controller node
export USERNAME=admin
export PASSWORD=ddcpassword
  # need to create the variable containing the tier IP and then use it
export myIPvar=CliqrTier_${cliqrAppTierName}_PUBLIC_IP 
export UCP_CONTROLLER_IP=${!myIPvar} 
#export UCP_CONTROLLER_IP=10.95.34.215   ###  need to make IP a parameter

### temporary:
touch /tmp/docker_subscription.lic

if [[ $INSTALL == "ucp-controller" ]]; then

	sudo docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-v /home/cliqruser/docker_subscription.lic:/docker_subscription.lic \
		-e UCP_ADMIN_PASSWORD=$PASSWORD \
		-e UCP_ADMIN_USER=$USERNAME \
		--name ucp docker/ucp \
		install --host-address $UCP_CONTROLLER_IP --san $UCP_CONTROLLER_IP 
	#  -v /home/docker/docker_subscription.lic:/docker_subscription.lic \
		
fi

