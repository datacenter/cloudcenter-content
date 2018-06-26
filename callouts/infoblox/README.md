# Infoblox

Infoblox callout integration script examples.

These scripts are _examples_ only, and are _not_ officially supported.

You should expect to have to modify these scripts to suit your
environment and requirements.

Notes:
* This script requires that Windows on VMware use a Guest
Customization Specification.
* You MUST create two Extensible attributes in Infoblox and assign
values for them to each network you want to use. 
    * networkId: Must match the networkId being passed into the script from
    CloudCenter. In VMware this is the name of the Port Group.
    * Gateway: The gateway to use for that network.
* This script was written for VMware and will require slight
modifications to be used with OpenStack.
* You should reasonably expect to make modifications to this script
to suit their environment and requirements.
* The script logs to /usr/local/cliqr/callout/callout.log
* Likely there will be missing packages that throw errors like
“failed to import…” See below for instructions on using virtualenv

## Usage
* Ensure that you are following all of the general callout configuration
steps documented here:
[Official Docs](https://docs.cloudcenter.cisco.com/display/CCD482/Callout+Scripts)
* Copy the ipam.py and dealloc.py scripts to their respective callout
folders.
* Ensure these files are executable and owned by cliqruser.
    ```
    chmod +x ipam.py
    chown -R cliqruser:cliqruser /usr/local/cliqr/callout
    ```
* Modify your callout.conf files and ensure they have the correct name,
topic, and executable file.

### Using virtualenv
These Python scripts have module dependencies. The easiest way to
accommodate this is to use Python virtualenv. This will allow you to
install packages from cliqruser in an isolated way.

As root:
```bash
yum install python-pip -y
pip install pip --upgrade
pip install virtualenv
su cliqruser
```

As cliqruser:
```bash
# Move to home dir.
cd ~
# Create a new Python virtual environment in directory ~/callouts
virtualenv callouts
# Activate the environment
source /home/cliqruser/callouts/bin/activate
# Upgrade pip
pip install pip --upgrade
# Install required modules
pip install argparse logging requests netaddr --upgrade
```

Double-check your #! in the first line of your scripts to ensure that it
matches the output from `which python` while your virtualenv is still
active.

## Infoblox Setup
Each network has separate network configurations. In particular, each
subnet will typically run in exactly one VLAN/network/PortGroup. Also,
each of these networks will have it's own Gateway.

CloudCenter knows which network (Port Group) you selected for
deployment, but not which subnet corresponds to this Port Group. On the
other hand, Infoblox knows about your subnets, but not which Port Groups
they go to.

To solve this, the best way is to document the PortGroup and Gateway
that go with each subnet in Infoblox itself, using Extensible
Attributes. These scripts assume that you are doing so. Specifically, 
these scripts rely on two Extensible Attributes that must be assigned
to each subnet that you want to use:
* networkId: Must match the networkId being passed into the script from
CloudCenter. In VMware this is the name of the Port Group.
* Gateway: The gateway to use for that network.

This ipam.py script will first search all subnets in Infoblox, filtering
on the networkId that is provided by CloudCenter. From that subnet, the
script will get the gateway attribute and create a new host
record with the next available IP from that subnet. The script will use
that IP, along with the Gateway, to configure the server being deployed. 


# Advanced Usage
Instead of putting the Python files directly on the CCO, put them in a
source control system instead, such as GitHub, GitLab or BitBucket.

Add a wrapper script such as the ipam.sh script, which downloads the .py
script from source control and executes it.

Ensure that the download link you use in the wrapper script includes
a code tag, not a branch. This will ensure platform stability.

Advantages:
* Can use a single script in source control for multiple CCOs/regions.
* Simplify maintenance.
* Code auditability (and all the other goodness that comes from
proper source control).

Important dis-advantage:
* Your source control system becomes a break-point for the platform.