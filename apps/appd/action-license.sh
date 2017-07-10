#!/bin/bash -x
exec > >(tee -a /var/tmp/action-license_$$.log) 2>&1

echo ${action_appd_license} > /home/appduser/AppDynamics/Controller/license.lic