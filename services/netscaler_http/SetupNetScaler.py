import requests, json, sys

def sendPost(url, headers, data):
    '''Generic wrapper for sending POST requests to NetScaler.'''

    global nitro_token

    try:
        response = requests.post(url, headers=headers, data=json.dumps(data), timeout=10)
        if response.status_code == 200 or response.status_code == 201:
            #Setting NITRO Auth Token if it's not set already.
            if nitro_token is None:
                nitro_token = "NITRO_AUTH_TOKEN="+response.cookies.values()[0]
        else:
            print("Recieved error status code - "+str(response.status_code))
            print("Error while issueing POST request to: " + url +". Exiting.")
            #Log out only if login passed
            if nitro_token is not None:
                logOut()

            sys.exit(1)
    except:
        print("Error while connecting to NetScaler")
        sys.exit(1)

    return

def logOut():
    '''Function to log out of the NetScaler.'''
    global nitro_token
    
    url = "http://"+resources['nsip']+"/nitro/v1/config/logout"
    headers = {"Content-Type":"application/vnd.com.citrix.netscaler.logout+json", "Cookie":nitro_token}
    data = {"logout":{}}
    sendPost(url, headers, data)

    return

##Main begins here##
if __name__ == "__main__":
    #Read command line arguments
    try:
        option = sys.argv[1]
    except:
        print("Please pass an option - \"start\" or \"stop\"")
        sys.exit(1)

    #Common section for start or stop logic
    #Reading the JSON resources file and loading into Dictionary
    with open("netscaler.json", "r") as file:
        resources = json.load(file)

    nitro_token = None
    #Logging into NetScaler and retrieving NITRO Auth Token
    url = "http://"+resources['nsip']+"/nitro/v1/config/login"
    headers = {"Content-Type":"application/vnd.com.citrix.netscaler.login+json"}
    data = {"login":{"username":resources['nsuser'], "password":resources['nspasswd']}}
    sendPost(url, headers, data)
    print("Successfully logged into NetScaler")

    #Flow for setting up the NetScaler
    if option == "start":
        print("Setting up NetScaler")

        #Enabling NS Features
        url = "http://"+resources['nsip']+"/nitro/v1/config/nsfeature?action=enable"
        headers = {"Content-Type":"application/json", "Cookie":nitro_token}
        data = {"nsfeature":{"feature":["LB"]}}
        sendPost(url, headers, data)
        print("Finished enabling features")
   
        #Enabling Interfaces
#        for interface in resources['interfaces']:
#            url = "http://"+resources['nsip']+"/nitro/v1/config/interface?action=enable"
#            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
#            data = {"interface":{"id":interface}}
#            sendPost(url, headers, data)
#            print("Finished enabling interface "+interface)

        #Adding SNIPs
        for snip in resources['snips']:
            url = "http://"+resources['nsip']+"/nitro/v1/config/nsip"
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = {"nsip":{"ipaddress":snip, "netmask":resources['snipmask']}}
            sendPost(url, headers, data)
            print("Finished adding IP address ")

        #Adding VIPs
        url = "http://"+resources['nsip']+"/nitro/v1/config/lbvserver"
        headers = {"Content-Type":"application/json", "Cookie":nitro_token}
        data = {"lbvserver":{"name":"V1", "servicetype":"HTTP", "ippattern":resources['lbvserver'], "ipmask":"255.255.255.255", "lbmethod":"ROUNDROBIN", "port":"80"}}
        sendPost(url, headers, data)
        print("Finished adding LB Vserver")

        #Adding Services
        for index, service in enumerate(resources['services']):
            #Adding service
            url = "http://"+resources['nsip']+"/nitro/v1/config/service"
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = {"service":{"name":"S"+str(index), "ip":service, "servicetype":"HTTP", "port":"80"}}
            sendPost(url, headers, data)
            #Binding service to Vserver
            url = "http://"+resources['nsip']+"/nitro/v1/config/lbvserver_service_binding"
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = {"lbvserver_service_binding":{"name":"V1", "servicename":"S"+str(index)}}
            sendPost(url, headers, data)

            print("Finished adding service "+service)

        print("Finished setting up the NetScaler")

    #Flow for tearing down the NetScaler
    if option == "stop":
        print("Tearing down NetScaler")
        #Clearing config
        url = "http://"+resources['nsip']+"/nitro/v1/config/nsconfig?action=clear"
        headers = {"Content-Type":"application/json", "Cookie":nitro_token}
        data = {"nsconfig":{"force":True, "level":"full"}}
        sendPost(url, headers, data) 
        print("Finished clearing config and tearing down NetScaler")

    #Logging out of NetScaler
    logOut()
    print("Successfully logged out of NetScaler")

