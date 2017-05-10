#!/bin/bash
. /utils.sh

print_log "$(env)"

cmd=$1
serviceStatus=""

if [ -n "${gitTag}" ]; then
    tag="${gitTag}"
else
    tag="kube"
fi

dep_name="${kube_dep_name}"
image="${kube_image}"
public_port="${kube_public_port}"
config="${kube_config}"
reps="${kube_reps}"

# Copied from https://kubernetes.io/docs/tasks/kubectl/install/
print_log "Installing kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

mkdir -p ~/.kube
echo "${config}" > ~/.kube/config

case ${cmd} in
    start)
        serviceStatus="Starting"

        ./kubectl run ${dep_name} --image ${image} --replicas=${reps}
        ./kubectl expose deployments ${dep_name} --port=${public_port} --type=LoadBalancer

        agentSendLogMessage  "Waiting for service to start."
        export COUNT=0
        export MAX=50
        export SLEEP_TIME=5
        export ERR=0

        pub_ip=`./kubectl get service nginx | sed -n 2p | awk {'print $3'}`

        while [ ${pub_ip} == "<pending>" ]; do
          sleep ${SLEEP_TIME}
          let "COUNT++"
          echo ${COUNT}
          if [ ${COUNT} -gt 50 ]; then
            ERR=1
            break
          fi
          pub_ip=`./kubectl get service nginx | sed -n 2p | awk {'print $3'}`
        done

        print_log "URL: http://${pub_ip}:${public_port}"
        print_log "Service Started."

        serviceStatus="Started"
        ;;
    stop)
        serviceStatus="Stopping"

        ./kubectl delete service ${dep_name}
        ./kubectl delete deployment ${dep_name}
        print_log "Service Stopped."

        serviceStatus="Stopped"
        ;;
    update)
        serviceStatus="Updating"
        serviceStatus="Updated"
        ;;
    *)
        serviceStatus="No Valid Script Argument"
        exit 127
        ;;
esac
