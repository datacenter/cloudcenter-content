#!/bin/bash
. /utils.sh

# Use for debugging only!
print_log "$(env)"

cmd=$1
serviceStatus=""

if [ -n "${gitTag}" ]; then
    tag="${gitTag}"
else
    tag="kube"
fi

error () {
    print_log "${1}"
    exit 1
}

prereqs="nmap"
print_log "Installing prereqs: ${prereqs}"
yum install -y ${prereqs}

# Input env variables used by this service.
image="${kube_image}"
# Public port on load balancer to access service
public_port="${kube_public_port}"
# Port exposed on containers/pods that LB points to
target_port="${kube_target_port}"
config="${kube_config}"
reps="${kube_reps}"

dep_name="dep${parentJobName}"
namespace="ns${parentJobName}"
service_name="svc${parentJobName}"

# Copied from https://kubernetes.io/docs/tasks/kubectl/install/
print_log "Installing kubectl"
msg=$(curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl) || \
            error "Failed to install kubectl: ${msg}"
chmod +x kubectl
mv kubectl /usr/local/bin/
print_log "kubectl installed"

mkdir -p ~/.kube
echo "${config}" > ~/.kube/config

# kubectl config set-context $(kubectl config current-context) --namespace=${namespace}

case ${cmd} in
    start)

        # Create namespace
        msg=$(kubectl create namespace ${namespace}) || \
            error "Failed to create namespace: ${msg}"
        print_log "Namespace ${namespace} created"

        # Create deployment
        msg=$(kubectl run --namespace ${namespace} ${dep_name} --image ${image} --replicas=${reps}) || \
            error "Failed to create the deployment: ${msg}"
        print_log "Deployment created"

        # Create service
        msg=$(kubectl expose --namespace=${namespace} deployment ${dep_name} --port=${public_port} \
        --target-port=${target_port} --type=LoadBalancer --name=${service_name}) || \
            error "Failed to expose the deployment: ${msg}"
        print_log "Deployment exposed on port ${public_port}"

        print_log "Waiting for service to start."
        COUNT=0
        MAX=50
        SLEEP_TIME=5
        ERR=0

        pub_ip=`kubectl describe --namespace=${namespace} service ${service_name} | grep "LoadBalancer Ingress:" | awk '{print $3}'`

        while [ "${pub_ip}" = "<pending>" -o  "${pub_ip}" = "" ]; do
          sleep ${SLEEP_TIME}
          let "COUNT++"
          echo ${COUNT}
          if [ ${COUNT} -gt 50 ]; then
            error "Never got IP address for service."
            break
          fi
          pub_ip=`kubectl describe --namespace=${namespace} service ${service_name} | grep "LoadBalancer Ingress:" | awk '{print $3}'`
        done

        print_log "Load Balancer Service Endpoint: ${pub_ip}:${public_port}"

        print_log  "Waiting for service to start by checking for port ${public_port} open on ${pub_ip}."
        COUNT=0
        MAX=50
        SLEEP_TIME=5
        ERR=0

        until $(nmap -p "${public_port}" "${pub_ip}" | grep "open" -q); do
          sleep ${SLEEP_TIME}
          let "COUNT++"
          echo $COUNT
          if [ $COUNT -gt 50 ]; then
            ERR=1
            break
          fi
        done

        print_log "Service Started."

        ;;
    stop)
        print_log "Deleting namespace ${namespace} and all resources in it."

        msg=$(kubectl delete namespace ${namespace}) || \
            error "Failed to delete the resources: ${msg}"

        print_log "Waiting for namespace to terminate."
        COUNT=0
        MAX=50
        SLEEP_TIME=5
        ERR=0

        #status=`kubectl get namespace | grep ${namespace} | awk '{print $2}'`
        while bash -c "kubectl get namespace | grep '${namespace}'"; do
          sleep ${SLEEP_TIME}
          let "COUNT++"
          echo ${COUNT}
          if [ ${COUNT} -gt 50 ]; then
            error "Never got IP address for service."
            break
          fi
        done
        print_log "Service Stopped."
        ;;
    update)
        ;;
    *)
        exit 127
        ;;
esac
