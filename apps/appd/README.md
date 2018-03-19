# AppDynamics Controller Appliaction and Agent installation scripts

## AppDynamics Controller
- Based on CentOS 7 OS, so ensure that you have CentOS 7.x in the list of supported
 OS in your CentOS service.
- Import the zip file into your instance.
- The application references files from the internet, so would need to be modified slightly
 if you don't have outbound connectivity.

## Agent installation scripts
- appd-service-centos.sh
-- Installs the machine agent on a CentOS or Red Hat based OS. If you want to run this on every
 VM in a region, try using the helper script in /other/helpers/remote_exec.sh which will execute
 script on a VM via SSH.
- appd-php-agent.sh
-- Installs the PHP agent on a VM
-- NOT TESTED, and doesn't seem to work well with the OOB CloudCenter Apache/PHP service
 as the service is running in a container.