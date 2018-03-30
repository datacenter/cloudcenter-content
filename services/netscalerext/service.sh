#!/bin/bash
#Netscaler External Service Script

#For external-service
. /utils.sh

wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/netscalerext/SetupNetScaler.py

print_log "$(env)"

env

cmd=$1
memberIPs=""

# RUN EVERYTHING AS ROOT
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi


function setup_prereqs() {
  yum install -y epel-release
  yum -y install python34
  curl -O https://bootstrap.pypa.io/get-pip.py
  /usr/bin/python3.4 get-pip.py
  #yum install -y python-pip wget
  pip install requests --upgrade
  pip install jinja2
}

function getMembers() {
  for tier in $(echo $CliqrDependencies | tr "," "\n" )
  do
    members=CliqrTier_${tier}_IP
    for ip in $(echo ${!members} | tr "=" "\n" | tr "," "\n")
    do
      memberIPs=$memberIPs"\"$ip\","
    done
    export memberIPs=`echo $memberIPs |sed s'/.$//'`
  done
}

function executionStatus() {
 FILE="status.txt"
 status=`cat $FILE`
 print_log "$status"

if grep -q "Error" "$FILE"; then
   exit 1
fi

}

print_log "Installing pre requisites.."
setup_prereqs
print_log "Retrieving Members.."
getMembers
echo $memberIPs
print_log "Creating Netscaler Parameters"
#createNetscalerParams

case $cmd in
	start)
		print_log "Executing Service.."
		#sleep 3500
		python3 SetupNetScaler.py start >> status.txt
		#Call out to netscaler script to add nodes
		executionStatus
		;;
	stop)
		print_log "Deleting Service.."
		#Call out to netscaler script to remove nodes
		python3 SetupNetScaler.py stop >> status.txt
		#Call out to netscaler script to add nodes
		executionStatus
		;;
	update)
		print_log "Updating Service.."
		python3 SetupNetScaler.py update >> status.txt
		#Call out to netscaler script to update nodes
		;;
	*)
		serviceStatus="No Valid Script Argument"
		exit 127
		;;
esac