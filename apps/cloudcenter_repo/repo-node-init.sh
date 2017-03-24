#!/bin/bash -x
exec > >(tee -a /var/tmp/repo-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

dlFile () {
    agentSendLogMessage  "Attempting to download $1"
    if [ -n "$dlUser" ]; then
        agentSendLogMessage  "Found user ${dlUser} specified. Using that and specified password for download auth."
        wget --no-check-certificate --user $dlUser --password $dlPass $1
    else
        agentSendLogMessage  "Didn't find username specified. Downloading with no auth."
        wget --no-check-certificate $1
    fi
    if [ "$?" = "0" ]; then
        agentSendLogMessage  "$1 downloaded"
    else
        agentSendLogMessage  "Error downloading $1"
        exit 1
    fi
}

agentSendLogMessage "Username: $(whoami)" # Should execute as cliqruser
agentSendLogMessage "Working Directory: $(pwd)"

defaultGitTag="repo"
if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

agentSendLogMessage  "CloudCenter release ${ccRel} selected."

agentSendLogMessage  "Installing OS Prerequisits wget vim java-1.8.0-openjdk nmap"
sudo mv /etc/yum.repos.d/cliqr.repo ~
sudo yum install -y wget rsync

# Download necessary files
cd /tmp
agentSendLogMessage  "Downloading installer files."
dlFile https://download.cliqr.com/release-4.7.1.1-20170206.2/installer/repo_installer.bin

sudo chmod +x repo_installer.bin
agentSendLogMessage  "Running repo installer"
sudo ./repo_installer.bin centos7 ${OSMOSIX_CLOUD} repo

if [ -n "${privateKey}" ]; then
    agentSendLogMessage  "Found private key. Using it to sync. Remember to send the corresponding
    public key to whoever owns the master repo (${masterRepo}) and ask them to add it.
    If repo.cliqrtech.com, then send to Cisco TAC for CloudCenter."
    echo "${privateKey}" > key
    chmod 400 key
    ssh-keygen -y -f /tmp/key > /tmp/key.pub
    sudo mv key /home/repo/.ssh/id_rsa
    sudo mv key.pub /home/repo/.ssh/id_rsa.pub
    sudo chown repo:repo /home/repo/.ssh/id_rsa
    sudo chown repo:repo /home/repo/.ssh/id_rsa.pub

else
     agentSendLogMessage  "No private key submitted. Generating one automatically."
     agentSendLogMessage $(sudo cat /home/repo/.ssh/id_rsa.pub)
     agentSendLogMessage  "Send this to whoever owns the master repo (${masterRepo}) and ask them to add it.
     If repo.cliqrtech.com, then send to Cisco TAC for CloudCenter. Once it's registered, come back
     and login to this VM and run /usr/bin/sync_repo.sh to sync the repo."
fi

agentSendLogMessage  "Adding ${masterRepo} SSH fingerprint to known_hosts"
sudo su repo -c "ssh-keyscan ${masterRepo} >> ~/.ssh/known_hosts"

SLEEP_TIME=30

agentSendLogMessage  "Waiting for SSH key to be registered with master.
Trying every ${SLEEP_TIME} seconds. I'll wait forever..."

result=1
while [ "${result}" -ne "0" ]; do
    sudo su repo -c "ssh repo@${masterRepo} -q rsync --version"
    result=$?
    sleep ${SLEEP_TIME}
done

agentSendLogMessage  "Syncing repo. This will take a while, maybe 15-60 minutes.
 If you want to see what's going on, login and look at /tmp/repo_sync.log"
sudo su repo -c "/usr/bin/repo_sync.sh"

