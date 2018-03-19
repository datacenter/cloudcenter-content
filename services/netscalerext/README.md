# Netscaler External Service

This service uses the Citrix Nitro API to create:
1) Load Balancer(s)
2) Virtual Servers
3) Services
4) SNIPS

This service supports the creation, deletion of these objects as well as scale up and down.

This has been tested with CloudCenter 4.8.1

This service utilizes the netscaler.json file as input.  Replacement is utilized within the service.sh to create values for the netscaler.json file using service parameters and environment variables.

The service will support http or https authentication as well as support for environments utilizing certificate based authentication. It is not required that certificates be loaded into the Docker container, as "verify=false" has been utilized within the python requests module.