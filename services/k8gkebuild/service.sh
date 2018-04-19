#!/bin/bash
#K8GKEBuild

#For external-service
. /utils.sh

wget http://cliqrdemo-repo.s3.amazonaws.com/joey/k8gkebuild/service/k8gkebuild.sh
chmod u+x k8gkebuild.sh
wget http://cliqrdemo-repo.s3.amazonaws.com/joey/k8gkebuild/service/k8gkedelete.sh
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