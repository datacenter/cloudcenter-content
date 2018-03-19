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
yaml_url="${kube_yaml}"
# Public port on load balancer to access service
public_port="${kube_public_port}"
# Port exposed on containers/pods that LB points to
target_port="${kube_target_port}"
config="${kube_config}"
reps="${kube_reps}"

dep_name="dep${parentJobName}"
# A valid namespace must consist only of LOWER CASE, digits and hyphens.
# First use tr to delete everything buy alphanumeric and hyphens
# then to change upper to lower.
namespace=$(echo "ns${parentJobName}" | tr -dc '[:alnum:]-' | tr '[:upper:]' '[:lower:]')
service_name="svc${parentJobName}"

# Copied from https://kubernetes.io/docs/tasks/kubectl/install/
print_log "Installing kubectl"
msg=$(curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl 2>&1) || \
            error "Failed to install kubectl: ${msg}"
chmod +x kubectl
mv kubectl /usr/local/bin/
print_log "kubectl installed"

mkdir -p ~/.kube
echo "${config}" > ~/.kube/config

# kubectl config set-context $(kubectl config current-context) --namespace=${namespace}

case ${cmd} in
    start)
        print_log "Creating namespace ${namespace}."
        msg=$(kubectl create namespace ${namespace} 2>&1) || \
            error "Failed to create namespace: ${msg}"
        print_log "Namespace ${namespace} created"

        print_log "${yaml_url}"
        yaml_file="file.yaml"
        msg=$(curl --fail -o "${yaml_file}" "${yaml_url}" 2>&1) || \
            error "Failed downloading yaml file: ${yaml_url}"

        print_log "Removing namespace from source yaml, if exists. Using namespace ${namespace} instead."
        sed -i -e '/namespace:/d' ${yaml_file}

        msg=$(kubectl apply --namespace ${namespace} -f ${yaml_file} 2>&1) || \
            error "Failed applying yaml file."

        print_log "Deployment finished, but it may still take a few minutes for the
        service to become available through the load balancer."
        ;;
    stop)
        print_log "Deleting namespace ${namespace} and all resources in it."

        msg=$(kubectl delete namespace ${namespace} 2>&1) || \
            error "Failed to delete the resources: ${msg}"

        print_log "Waiting for namespace to terminate."
        COUNT=0
        MAX=50
        SLEEP_TIME=5
        ERR=0

        while bash -c "kubectl get namespace | grep '${namespace}'"; do
          sleep ${SLEEP_TIME}
          let "COUNT++"
          echo ${COUNT}
          if [ ${COUNT} -gt 50 ]; then
            error "Namespace still shows in list after waiting a long time. Exiting, but may be leaving residual stuff."
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
