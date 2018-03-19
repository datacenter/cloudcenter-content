Azure Instance Resize - Action Library

Currently supports Azure ARM only.

There are two files which are utilized for this action library.  The azcli2.py script is used to installthe Azure 2.0 CLI.  Azure built this script to be installed via a curl command and present interactive prompts to the end user.  Since this is not feasible the pythong script has been hacked to take the default installation values.  Overtime this script may become obsolete, so please be aware of it's hacked nature.  The azurevmresize.sh script will install the pre-req's required for the CLI as well as the CLI.  It will also present Azure login credentials required.  These variables must be created within the action library definition.

Action Library configuration.  Since there is no import/export for action libraries you must manually create the action library per these steps:
1) Navigate to the Action Library page and select the "New Action" button.
2) Enter the Type as: Command or Script
3) Name the action: Resize Azure VM
4) Provide a description
5) The default timeout of 20 minutes seems to be satisfactory
6) Select "Externally" for the execute action
7) Toggle the "Sync VM Info" to "YES" - This is optional and only works if there is a wait command in the shell script to make sure the VM is up and running.  You can toggle this to "NO" and issue a manual sync after the resize runs as well.
8) The Object Mapping settings will vary dependingon your environment but should only include Azure cloud regions for "CloudCenter Deployed VM's"
9) Within the Action Definition the "Execute from Bundle" should be disabled
10) The executable command should be: https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/action%20libraries/azurevmresize/azurevmresize.sh
11) There are three required custom fields
	a) Instance Size
		Display Name: Instance Size
		Param Name: instancesize
		Help Text: Size of Requested Instance
		Type: List
		List of Values: This list may vary depending on the cloud regions being supported by this action.  You should go to the cloud region within your tenant and open        the list of instances.  From this list you can copy/paste the instance types you want to support with this action.  The case of these names is very important.         DO NOT COPY INSTANCE NAMES FROM OUTSIDE ClOUDCENTER.
		Default Value: set to one of the instances from the list
		Required Field: YES
	b) Azure Cloud Account
		Field Visibility: set to off
		Display Name: Azure Cloud Account
		Param Name: CliqrCloudAccountName
		Help Text: blank
		Type: string
		Default value: This should be the email address for the Azure account you will utilize.  This should be the same cloud account that is being utilized to deploy         VM's into this Azure region.
	c) Azure Cloud Account PWD
		Field Visibility: set to off
		Display Name: Azure Cloud Account PWD
		Param Name: CliqrCloudAccountPwd
		Help Text: blank
		Type: Password with Confirmation
		Default: enter the appropriate password
		Confirm: confirm password
