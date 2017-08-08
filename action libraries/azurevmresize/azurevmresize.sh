#!/bin/bash

# Azure Resize VM


#Install CLI 2.0 (python based)
	yum makecache fast
	yum check-update
	yum install -y gcc libffi-devel python-devel openssl-devel
	yum install -y expect

	wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/action%20libraries/azurevmresize/azcli2.py -O /tmp/azcli2.py
	chmod 755 /tmp/azcli2.py
	python /tmp/azcli2.py

	/home/cliqruser/bin/az login -u $CliqrCloudAccountName -p $CliqrCloudAccountPwd
	if [ $? -ne 0 ];
	then
		echo "Azure Login failed";
	else
		echo "Azure Login Successful";
	fi


	/home/cliqruser/bin/az vm stop -g $resourceGroup -n $hostname
	echo "VM Successfully Stopped";
	/home/cliqruser/bin/az vm deallocate -g $resourceGroup -n $hostname
	echo "VM Successfully Deallocated";
	/home/cliqruser/bin/az vm resize -g $resourceGroup -n $hostname --size $instancesize
	echo "VM Successfully Resized";
	/home/cliqruser/bin/az vm start -g $resourceGroup -n $hostname
	echo "VM Successfully Started";

	echo "VM Successfully Resized";

    sleep 30s # Waits 30 seconds.

