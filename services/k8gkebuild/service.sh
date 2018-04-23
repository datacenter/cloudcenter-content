#!/bin/bash
#K8GKEBuild

#For external-service
. /utils.sh

wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/k8gkebuild.sh
chmod u+x k8gkebuild.sh
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/k8gkedelete.sh
chmod u+x k8gkedelete.sh

print_log "$(env)"

env

cmd=$1
memberIPs=""



case $cmd in
	start)
		print_log "Executing Service.."
		./k8gkebuild.sh
		;;
	stop)
		print_log "Deleting Service.."
		./k8gkedelete.sh
		;;
	update)
		;;
	*)
		serviceStatus="No Valid Script Argument"
		exit 127
		;;
esac