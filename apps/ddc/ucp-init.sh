export INSTALL=ucp-controller

# set hostname
export HOSTNAME=$INSTALL
hostname $HOSTNAME
sed -i "s/localhost/$HOSTNAME/g" /etc/hosts
echo $HOSTNAME | tee /etc/hostname

# install docker-engine
curl -SLf https://packages.docker.com/1.13/install.sh  | sh
systemctl restart docker

# configure proxy
cd /etc/systemd/system
mkdir docker.service.d
cd docker.service.d
export http_proxy="http://proxy.esl.cisco.com:8080" 
echo "[Service]" >> http-proxy.conf
echo "Environment="\""HTTP_PROXY="$https_proxy\" "\""HTTPS_PROXY="$http_proxy"\" >> http-proxy.conf
systemctl daemon-reload
systemctl restart docker

export USERNAME=admin
export PASSWORD=ddcpassword
export UCP_CONTROLLER_IP=10.95.34.215   ###  need to make IP a parameter

# install the ucp controller node
if [[ $INSTALL == "ucp-controller" ]]; then

	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		-e UCP_ADMIN_PASSWORD=$PASSWORD \
		-e UCP_ADMIN_USER=$USERNAME \
		--name ucp docker/ucp \
		install --host-address $UCP_CONTROLLER_IP --san $UCP_CONTROLLER_IP 
	#  -v /home/docker/docker_subscription.lic:/docker_subscription.lic \
		
fi

