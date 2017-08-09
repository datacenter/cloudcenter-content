#!/bin/bash
. /utils.sh

# Azure Delete App Service


#Install CLI 2.0 (python based)
	yum makecache fast
	yum check-update
	yum install -y gcc libffi-devel python-devel openssl-devel
	yum install -y expect

	wget https://cliqrdemo-repo.s3.amazonaws.com/joey/azurevmresize/azcli2.py -O /tmp/azcli2.py
	chmod 755 /tmp/azcli2.py
	python /tmp/azcli2.py

	/home/cliqruser/bin/az login -u $CliqrCloudAccountName -p $CliqrCloudAccountPwd
	if [ $? -ne 0 ];
	then
		print_log "Azure Login failed";
	else
		print_log "Azure Login Successful";
	fi


	# Replace the following URL with a public GitHub repo URL
	gitrepo=https://github.com/Azure-Samples/php-docs-hello-world
	# webappname=mywebapp$RANDOM


	# Delete App Service
	/home/cliqruser/bin/az webapp delete --name $webappname --resource-group $resourceGroup
	if [ $? -ne 0 ];
	then
		print_log "Web App Delete failed";
	else
		print_log "Web App Delete Successful";
	fi

	az appservice plan delete --name
                          --resource-group
                          [--yes]

	# Delete Plan
	/home/cliqruser/bin/az appservice plan delete --name $webappname --resource-group $resourceGroup --yes
	if [ $? -ne 0 ];
	then
		print_log "Plan Delete failed";
	else
		print_log "Plan Delete Successful";
	fi