#!/usr/bin/env bash

while getopts ":h:u:p:n:i:o:" opt; do
  case $opt in
    h)
        tower_ip=$OPTARG
      ;;
    u)
        tower_un=$OPTARG
      ;;
    p)
        tower_pass=$OPTARG
      ;;
    n)
        instance_name=$OPTARG
      ;;
    i)
        inventory_id=$OPTARG
      ;;
    o)
        cmd=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


case ${cmd} in
    add)
        curl -k -X POST \
          https://${tower_ip}/api/v1/hosts/ \
          -u ${tower_un}:${tower_pass} \
          -H 'content-type: application/json' \
          -d "{
            \"name\": \"${instance_name}\",
            \"enabled\": \"true\",
            \"inventory\": ${inventory_id}
        }"
        ;;
    remove)
        ;;
    *)
        ;;
esac