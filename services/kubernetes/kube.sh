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
        print_log "${yaml_url}"
        kubectl apply -f ${yaml_url} || \
            error "Failed applying yaml file."

        print_log "Deployment finished, but it may still take a few minutes for the
        service to become available through the load balancer."
        ;;
    stop)
        # TODO: Need to figure out a bit different way to do this, since this yaml file may have changed or inaccessible
        # or otherwise not appropriate for deleting the resources.
        print_log "${yaml_url}"
        kubectl delete -f ${yaml_url} || \
            error "Failed applying yaml file."

        print_log "YAML file deleted."
        ;;
    update)
        ;;
    *)
        exit 127
        ;;
esac
