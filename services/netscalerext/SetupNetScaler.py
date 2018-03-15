import requests, json, sys
import os

def sendPost(url, headers, data):
    '''Generic wrapper for sending POST requests to NetScaler.'''

    global nitro_token

    try:
        response = requests.post(url, headers=headers, data=json.dumps(data),verify=False, timeout=10)
        if response.status_code == 200 or response.status_code == 201:
        #if response.status_code == 200 or response.status_code == 201 or response.status_code == 409 or response.status_code == 404:

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

def sendGet(url, headers, data):
    '''Generic wrapper for sending Get requests to NetScaler.'''

    global nitro_token
    global get_response_text
    global response_data


    try:
        response = requests.get(url, headers=headers, data=json.dumps(data),verify=False, timeout=10)
        if response.status_code == 200 or response.status_code == 201:
            #Setting NITRO Auth Token if it's not set already.
            if nitro_token is None:
                nitro_token = "NITRO_AUTH_TOKEN="+response.cookies.values()[0]
            get_response_text=response.text
        else:
            print("Recieved error status code - "+str(response.status_code))
            print("Error while issueing Get request to: " + url +". Exiting.")
            #Log out only if login passed
            if nitro_token is not None:
                logOut()

            sys.exit(1)
    except:
        print("Error while connecting to NetScaler")
        sys.exit(1)

    return

def sendDelete(url, headers, data):
    '''Generic wrapper for sending Delete requests to NetScaler.'''

    global nitro_token

    try:
        response = requests.delete(url, headers=headers, data=json.dumps(data),verify=False, timeout=10)
        if response.status_code == 200 or response.status_code == 201 or response.status_code == 404:
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

    url = "https://"+resources['nsip']+"/nitro/v1/config/logout"
    headers = {"Content-Type":"application/vnd.com.citrix.netscaler.logout+json", "Cookie":nitro_token}
    data = {"logout":{}}
    sendPost(url, headers, data)

    return

PARENT_JOB_NAME = os.getenv('parentJobName')
SVC_TYPE_PORT = os.getenv('svc_type_port')
LB_METHOD = os.getenv('lb_method')

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

    requests.packages.urllib3.disable_warnings()

    nitro_token = None
    #Logging into NetScaler and retrieving NITRO Auth Token
    url = "https://"+resources['nsip']+"/nitro/v1/config/login"
    headers = {"Content-Type":"application/vnd.com.citrix.netscaler.login+json"}
    data = {"login":{"username":resources['nsuser'], "password":resources['nspasswd']}}
    sendPost(url, headers, data)
    print("Successfully logged into NetScaler")

    #Flow for setting up the NetScaler
    if option == "start":
        print("Setting up NetScaler")

        #Enabling NS Features
        url = "https://"+resources['nsip']+"/nitro/v1/config/nsfeature?action=enable"
        headers = {"Content-Type":"application/json", "Cookie":nitro_token}
        data = {"nsfeature":{"feature":["LB"]}}
        sendPost(url, headers, data)
        print("Finished enabling features")

        #Adding SNIPs
        for snip in resources['snips']:
            url = "https://"+resources['nsip']+"/nitro/v1/config/nsip"
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = {"nsip":{"ipaddress":snip, "netmask":resources['snipmask']}}
            sendPost(url, headers, data)
            print("Finished adding IP address ")

        #Adding VIPs
        if SVC_TYPE_PORT == "80":
            svctypeval = "HTTP"
            portval = "80"
        elif SVC_TYPE_PORT == "443":
            svctypeval = "SSL"
            portval = "443"
        url = "https://"+resources['nsip']+"/nitro/v1/config/lbvserver"
        headers = {"Content-Type":"application/json", "Cookie":nitro_token}
        data = {"lbvserver":{"name":PARENT_JOB_NAME, "servicetype":svctypeval, "ippattern":resources['lbvserver'], "ipmask":"255.255.255.255", "lbmethod":LB_METHOD, "port":portval}}
        sendPost(url, headers, data)
        print("Finished adding LB Vserver")

        #Adding Services
        for index, service in enumerate(resources['services']):
            #Adding service
            url = "https://"+resources['nsip']+"/nitro/v1/config/service"
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = {"service":{"name":"S"+str(index), "ip":service, "servicetype":svctypeval, "port":portval}}
            sendPost(url, headers, data)
            #Binding service to Vserver
            url = "https://"+resources['nsip']+"/nitro/v1/config/lbvserver_service_binding"
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = {"lbvserver_service_binding":{"name":PARENT_JOB_NAME, "servicename":"S"+str(index)}}
            sendPost(url, headers, data)

            print("Finished adding service "+service)

        print("Finished setting up the NetScaler")

    #Flow for deleting services, vip, snips
    elif option == "stop":
        #Deleting Services
        for index, service in enumerate(resources['services']):
            #Deleting service
            url = "https://"+resources['nsip']+"/nitro/v1/config/service/"+"S"+str(index)
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = ""
            # data = {"service":{"name":"S"+str(index), "ip":service, "servicetype":"HTTP", "port":"80"}}
            sendDelete(url, headers, data)

            print("Finished Deleting service "+service)

        #Deleting VIPs
        url = "https://"+resources['nsip']+"/nitro/v1/config/lbvserver/" + PARENT_JOB_NAME
        headers = {"Content-Type":"application/json", "Cookie":nitro_token}
        data = ""
        sendDelete(url, headers, data)
        print("Finished deleting LB Vserver")

        # Deleting SNIPs
        for snip in resources['snips']:
            url = "https://"+resources['nsip']+"/nitro/v1/config/nsip/"+snip
            headers = {"Content-Type":"application/json", "Cookie":nitro_token}
            data = ""
            # data = {"nsip":{"ipaddress":snip, "netmask":resources['snipmask']}}
            sendDelete(url, headers, data)
            print("Finished Removing IP address(s) ")

        print("Finished Removing NetScaler Configuration")

    #Flow for updating services when scaling up & down
    elif option == "update":
        #Get all services bound to this load balancer
        url = "https://"+resources['nsip']+"/nitro/v1/config/lbvserver_binding/"+PARENT_JOB_NAME
        headers = {"Content-Type":"application/json", "Cookie":nitro_token}
        data = ""
        sendGet(url, headers, data)

        # Take response from loadbalances service binding call.  Parse the IP's that are currently configured
        # as part of the service and load them into an array.
        lbarray = []
        t=json.loads(get_response_text)
        for binding in t['lbvserver_binding']:
            for servicebinding in binding['lbvserver_service_binding']:
                lbarray.append(servicebinding.get('ipv46'))

        # Add IP's from netscaler.json file to servicesarray
        servicesarray = []
        for index, service in enumerate(resources['services']):
            servicesarray.append(service)

        # Compare the loadbalancer Services(netscaler.json) arra to the array(lbarray) and create an array
        # of the IP's which need to be added to the loadbalancer
        addServers = []
        for ipservices in servicesarray:
           if not any(iplb == ipservices for iplb in lbarray):
               addServers.append(ipservices)

        # Compare the loadbalancer array(lbarray) to the Services(netscaler.json) array and create an array
        # of the IP's which need to be removed from the loadbalancer
        removeServers = []
        for ipservices in lbarray:
           if not any(iplb == ipservices for iplb in servicesarray):
               removeServers.append(ipservices)

        ascount = len(addServers)
        rmcount = len(removeServers)
        lbcount = len(lbarray)
        servicescount = len(servicesarray)

        #Add servers to load balancer
        if ascount > rmcount:
            #Add IP services to load balancer and bind
            addsvcnt = lbcount
            for index, service in enumerate(addServers):
                #Adding services
                if SVC_TYPE_PORT == "80":
                    svctypeval = "HTTP"
                    portval = "80"
                elif SVC_TYPE_PORT == "443":
                    svctypeval = "SSL"
                    portval = "443"
                url = "https://"+resources['nsip']+"/nitro/v1/config/service"
                headers = {"Content-Type":"application/json", "Cookie":nitro_token}
                data = {"service":{"name":"S"+str(addsvcnt), "ip":service, "servicetype":svctypeval, "port":portval}}
                sendPost(url, headers, data)
                #Binding service to Vserver
                url = "https://"+resources['nsip']+"/nitro/v1/config/lbvserver_service_binding"
                headers = {"Content-Type":"application/json", "Cookie":nitro_token}
                data = {"lbvserver_service_binding":{"name":PARENT_JOB_NAME, "servicename":"S"+str(addsvcnt)}}
                sendPost(url, headers, data)
                addsvcnt += 1
        elif rmcount > ascount:
            for x in range((lbcount - 1), (servicescount -1), -1):
                #Deleting service
                url = "https://"+resources['nsip']+"/nitro/v1/config/service/"+"S"+str(x)
                headers = {"Content-Type":"application/json", "Cookie":nitro_token}
                data = ""
                sendDelete(url, headers, data)
                print("Finished Deleting service "+service)

    #Logging out of NetScaler
    logOut()
    print("Successfully logged out of NetScaler")

