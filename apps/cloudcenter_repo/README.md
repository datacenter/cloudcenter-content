# Cisco CloudCenter Package Store

The CloudCenter Package Store appliance is used when installing other components in a network
that cannot download from the internet. In that case you point the installer bin file at the custom
 repo by setting environment variable CUSTOM_REPO prior to executing the installer.

This application deploys an instance of the CloudCenter Package Store. Of course, to work properly,
it must itself be able to download files from the internet. Also of course, you will only be able 
to use this application in an existing CC instance. This applicaiton can be used to create the initial repo in a
DMZ or other similar network, then it can either be referenced in place from the protected network or it can simply be
moved into the protected network. You could also just export the VM and re-import it where needed.

See this page for more information:
http://docs.cliqr.com/display/CCD46/Phase+4%3A+Install+Components

## Usage
1. Download the app zip from GitHub.
1. Import into your instance.
1. This app is built on the OOB CentOS service, which may not be configured for CentOS 7, which is required. Go into
 Admin->Services->CentOS and ensure that CentOS 7.x is among the configured supported images.
1. Ensure that you have a real image mapped to CentOS 7.x in the region that you want to deploy. You may map a RHEL 7
template/AMI and it will probably work, but it hasn't been tested.

## Required parameters:
- cliqrIgnoreAppFailure
    - Default: False
    - Tells CC whether to terminate and cleanup the application if deployment fails.
- gitTag
    - Default: repo0.2
    - Tells the application exactly which tag of code to pull from GitHub.
- Master Repo
    - Default: repo.cliqrtech.com
    - This is used to set which repo you want to sync from. Cisco maintains the default
repo.cliqrtech.com. This might be a useful option if for network reasons you need to chain them
 together or move an already-synced one behind a firewall.
-  User Name
    - The username for downloading the installer bits from Cisco. If you don't have this ask your Cisco account team.
- Password
    - The password that goes with the username
 
## Optional Parameters:
- SSH Private Key
    - The master repo requires a private key for authentication to sync. You need to register the public key from the keypair
    by sending it to whoever owns the master repo. Put the private key here. Otherwise, a new keypair will be generated for you
    and the public key will be shown in the log file, then you can send it to the master repo owner.
 
