#!/bin/bash

# Generates a VM name based on the job and app tier name, plus a UUID for uniqueness.
echo "vmName=${eNV_parentJobName}-${eNV_cliqrAppTierName}-`uuidgen`"