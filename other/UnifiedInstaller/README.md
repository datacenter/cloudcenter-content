# cloudcenter-content

## Other:


### Unified Installer


## Usage

The Unified Installer script will install CCM, CCO and AMQP components.  The script will prompt for the component type you which to install and should be executed on the designated VM for each component.

The script requires editing for each installation with the following changes required:
    1) VM IP address for the designated CCM
    2) VM IP address for the designated CCO
    3) VM IP address for the designated AMQP/Rabbit
    4) Cloud Type ie Amazon, VMWare, etc.
    5) The download key and potentially the download userid.  Password is not stored within the script for security reasons.
    6) The version of Cloud Center you wish to install
    7) The Operating system of the designated VM's.
    
The Unified installer will complete all configuration items except:
    1) Addition the cloud account.
    2) Creation of the Cloud and cloud region
    3) Addition of the CCO to the Cloud Center UI.
    
Installation of a CCM, CCO and AMQP in a single cloud is easily accomplished within 30 minutes utilizing the Unified Installer.
