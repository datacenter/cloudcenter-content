#!/bin/bash

. /utils.sh

$(env)

export VMTURBO_URL="172.16.202.242"
export VMTURBO_USER="administrator"
export VMTURBO_PASSWORD="welcome2cliqr"
export VMTURBO_RESOURCE="http://${VMTURBO_USER}:$VMTURBO_PASSWORD@${VMTURBO_URL}"

#pre fixing a datacenter in the sample
if [ -z ${dcName} ];
then
    export dcName=${eNV_Cloud_Setting_UserDataCenterName}
fi

export dcName=${eNV_Cloud_Setting_UserDataCenterName}
export vmTagsList="Name:myVm"
export UserDataCenterName="$dcName"
export UserClusterName="CliQr"
export UserResourcePoolName="Eng"
export RootFolderName="vm"
export UserFolderName="CliqrUser-id"
export RootDiskResizable="false"
export FullClone="true"
export VmRelocationEnabled="true"
export LocalDataStoreEnabled="true"
export SystemFolderName="CliqrTemplates"
export networkList="10-DEV (DSwitch)"

export instanceNameVar=`echo CliqrTier_"${eNV_cliqrAppTierName}"_instanceType`
eval instanceName='$'${instanceNameVar}

getProfileId() {
    result=`curl -s -X GET $VMTURBO_RESOURCE/vmturbo/api/templates | grep ${instanceName}`
    export profileId=`echo $result | awk -F uuid=\" '{printf $2}' | awk -F \" '{printf $1}'`
}
getProfileId

getDatacenterId() {
        DATACENTER=$1
    result=`curl -s -X GET ${VMTURBO_RESOURCE}/vmturbo/api/markets/Market/entities | grep \"DataCenter\" | grep ${DATACENTER}`
    export dcId=`echo ${result} | awk -F uuid=\" '{printf $2}' | awk -F \" '{printf $1}'`
}
getDatacenterId "${dcName}"


#echo "dcId=$dcId"

getReservation() {
    reservationName="reserve-${RANDOM}"
    export reserveId=`curl -s -X POST ${VMTURBO_RESOURCE}/vmturbo/api/reservations -d "reservationName=${reservationName}&templateName=${profileId}&count=1&segmentationUuid[]=${dcId}"`
}
getReservation
sleep 3

getHostAndDS() {
    result=`curl -s -X GET ${VMTURBO_RESOURCE}/vmturbo/api/deployitems/${reserveId}`
    export datastore=`echo ${result} |  awk -F datastore=\" '{printf $2}' | awk -F \" '{printf $1}'`-cluster
    export host=`echo ${result} |  awk -F host=\" '{printf $2}' | awk -F \" '{printf $1}'`
}
getHostAndDS
export UserDatastoreCluster="${datastore}"
export UserHost="$host"

content="{\"UserDataCenterName\":\"$dcName\",\"UserClusterName\":\"$UserClusterName\",\"UserResourcePoolName\":\"$UserResourcePoolName\",\"vmTagsList\":\"$vmTagsList\",\"UserDatastoreCluster\":\"$UserDatastoreCluster\",\"RootFolderName\":\"$RootFolderName\",\"UserFolderName\":\"$UserFolderName\", \"RootDiskResizable\":\"$RootDiskResizable\",\"FullClone\":\"$FullClone\", \"VmRelocationEnabled\":\"$VmRelocationEnabled\",\"LocalDataStoreEnabled\":\"$LocalDataStoreEnabled\",\"SystemFolderName\":\"$SystemFolderName\",\"networkList\":\"$networkList\", \"UserHost\":\"$UserHost\",\"nodeInfo\":\"UserDataCenterName:$dcName, UserClusterName: $UserClusterName, UserDatastoreCluster:$UserDatastoreCluster, networkList: $networkList \"}"

print_ext_service_result "${content}"