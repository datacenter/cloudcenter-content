# Cisco CloudCenter Custom Repo

The CloudCenter custom repo appliance is used when installing other components in a network
that cannot download from the internet. In that case you point the installer bin file at the custom
 repo by setting environment variable CUSTOM_REPO prior to executing the installer.

This application deploys an instance of the CloudCenter custom repo. Of course, to work properly,
it must itself be able to download files from the internet. Also of course, you will only be able 
to use this application in an existing CC instance.

Required parameters:
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
 
 Optional Parameters:
 -  