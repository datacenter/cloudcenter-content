#!/bin/bash
. /utils.sh

# Azure Create App Service


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

	# Create an App Service plan in `FREE` tier.
	/home/cliqruser/bin/az appservice plan create --name $webappname --resource-group $resourceGroup --sku FREE
	if [ $? -ne 0 ];
	then
		print_log "Plan Create failed";
	else
		print_log "Plan Create Successful";
	fi

	# Create a web app.
	/home/cliqruser/bin/az webapp create --name $webappname --plan $webappname --resource-group $resourceGroup
	if [ $? -ne 0 ];
	then
		print_log "AppService Create failed";
	else
		print_log "AppService Create Successful";
	fi

	# Deploy code from a public GitHub repository.
	/home/cliqruser/bin/az webapp deployment source config --name $webappname --resource-group $resourceGroup --repo-url $gitrepo --branch master --manual-integration
	if [ $? -ne 0 ];
	then
		print_log "Deploy failed";
	else
		print_log "Deploy Successful";
	fi

	# List the web app(s).
	weburlout=`/home/cliqruser/bin/az webapp list | grep $webappname | grep defaultHostName`
	print_log $weburlout;