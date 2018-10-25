This service creates additional virtual IP addresses on a Windows server.  The service integrates with Infoblox to
allocate a designated number of IP addresses.  This process allocates new IP addresses in Infoblox and creates new Host records.

Once the host records are created, the additional virtual IP addresses are added to the local Operating system using the
base NIC defined during initial provisioning.

The removevips.ps1 file will clean up Infoblox when a VM is destroyed, removing all of the host records and releasing the IP addresses in Infoblox.

The service is configured to allow for 5 additional IP addresses to be configured.  This can be adjusted to accomodate additional IP if needed.
This can be accomplished by adding additional host and domain fields to the service definition.  Then add additional if statements in the addvips2.ps1 and the removevips.ps1 files (this is toward the bottom)

The host and domain parameters must be populated or they are skipped.

The Networklist field is prepopulated with a list of networks in this form: 0.0.0.0/0.  The list of networks to be utilized should be taken from Infoblox and manually populated into this parameter.  Ideally a webservice call would be utilized from C3 to automatically populate this.  This could be a future enhancement.

The network must align to the same network that is selected during the VMWare details selection at deployment time.

The scripts also need to be updated with the proper Infoblox IP address as that is still hardcoded in the script.


Potential enhancments:
1) web services call to infoblox to auto populate the networklist field
2) parameterize Infoblox server IP address