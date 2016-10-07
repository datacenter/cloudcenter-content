#!/usr/bin/env python
import infoblox, sys, requests, os
requests.packages.urllib3.disable_warnings()

#Check to see if command line included enough arguments.
#if (len(sys.argv) < 3):
#	print "Usage: createHost.py <fqdn> <network CIDR>"
#	quit()

#Write environment variables to file for development purposes
f = open('/usr/local/osmosix/callout/ipam2/environment', 'w')
for key in os.environ.keys():
    f.write("%s=%s\n" % (key,os.environ[key]))
f.close()

#Assign command line arguments to named variables
#hostname = "worker" + str(os.getenv('eNV_JOB_ID', 0)) # Use jobID as part of name. If not set, use 0 as default
#domain = "test.com"
#fqdn = hostname + "." + domain #sys.argv[1]
#network = "10.110.50.0/24" #sys.argv[2]

#Setup connection object for Infoblox
#iba_api = infoblox.Infoblox('10.110.1.45', 'admin', 'infoblox', '1.6', 'default', 'default', False)

#try:
	#Create new host record with supplied network and fqdn arguments
#    ip = iba_api.create_host_record(network, fqdn)
#    print "nicCount=1"
#    print "nicIP_0=" + ip
#    print "nicDnsServerList_0=10.110.1.45"
#    print "nicGateway_0=10.110.50.1"
#    print "nicNetmask_0=255.255.255.0"
#    print "linuxDomain="+domain
#    print "linuxHWClockUTC=true"
#    print "linuxTimeZone=Canada/Eastern"
#    print "osHostname="+hostname
#except Exception as e:
#    print e
