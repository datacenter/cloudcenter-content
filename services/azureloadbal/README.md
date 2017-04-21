Azure Load Balancer derivative PaaS service

Currently supports Azure ARM only.

Info:  This service builds all components required for an externally facing Azure Load Balancer.  It will create a public ip, probe, front end IP pool and back end pool.

The load balancer will support scale up and scale down as usual


Things to be aware of:

There is a service parameter for the probe file.  This parameter references a 	html or static file that is required on each webserver.  The load balancer will 	request this file and if it is not found within the polling requirements it will mark the server offline.  If all servers within the availability pool are offline you will receive a 504 gateway error when trying to reach the site.


When deploying an application profile utilizing the Load Balancer you will need to put the servers of the web or application tier into an availability set.  If you do not check the availability set box you will not be able to scale the application as the nodes will not get added to the load balancer.

The load balancer will deploy into an existing Virtual network and subnet that are selected during deployment time so there is no need for outside creation of these objects.

Authentication is completed by utilizing the account information already provided as environment variables within a Cloud Center/Azure deployment.

Deployment Time Dependencies:
1) All tiers of the application should be deployed to the same Resource Group / Network
2) Do not utilize "_" or other special characters in the deployment name.  As Cloud Center may accept these characters as acceptable, Azure will not allow them to be utilized as part of the domain name which is used is the application URL.


TODO:
1) Add support for SSL(443)
2) Adding text update for testing
3) adding another update
4) add one more line