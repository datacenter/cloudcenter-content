#!/bin/bash -x
# Utility script to run arbitrary script remotely with lifecycle action.
. /utils.sh

# Should be URL of script to download and execute on the container.
script=$1

# Supports only single running container on host!
print_log "NOTE: This helper script supports only a single running container on the node."
container_name=`docker ps | awk '{ print $1 }' | tail -n1`
print_log "Container name: ${container_name}"

print_log "Downloading script: ${script} as script.sh"
docker exec -it ${container_name} curl -o script.sh ${script}
docker exec -it ${container_name} chmod +x script.sh
print_log "Executing script.sh"
docker exec -it ${container_name} ./script.sh
print_log "Done executing script.sh"
