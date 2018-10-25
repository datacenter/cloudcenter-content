. 'c:\Program Files\osmosix\etc\cliqr.ps1'
. 'c:\temp\userenv.ps1'

cd c:\opt\

#######################################
#Ignore Certificate Errors
#######################################
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#######################################
#Set Global Variables
#######################################
$infobloxusername = $env:infobloxuser
$infobloxpassword = $env:infobloxpassword
$secpassword = ConvertTo-SecureString -String $infobloxpassword -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $infobloxusername, $secpassword



#######################################
#Begin function
#######################################
function Delete-HostandIP
{

	$qualifiedhost = $hostname+"."+$domain

	#######################################
	#Replace temp variables
	#######################################

	$urlbody1=$urlbody1 -replace "temphost", $hostname
	$urlbody1=$urlbody1 -replace "tempdomain", $domain
	$contentbody="application/json"


	#######################################
	#Delete each host record
	#######################################
	$Result = Invoke-RestMethod -Credential $cred -Method Get -Uri "https://172.16.201.201/wapi/v2.6/record:host?name=$qualifiedhost"
	$Result = $Result._ref.split("/")[1]
	Invoke-RestMethod -Credential $cred -Method DELETE -Uri "https://172.16.201.201/wapi/v2.6/record:host/$Result"

}


###########################################
#Check if parameters are no null.
#If not null then set the host and domain
#domain and call the function to get the
#next ip.  Then set the host record and add
#the ip to the deploying host OS
###########################################

if ($env:hostrecord1)
{
	if ($env:domainrecord1)
	{
    	$hostname = $env:hostrecord1
    	$domain = $env:domainrecord1
    	Delete-HostandIP
    }
}
if ($env:hostrecord2)
{
	if ($env:domainrecord2)
	{
    	$hostname = $env:hostrecord2
    	$domain = $env:domainrecord2
    	Delete-HostandIP
    }
}
if ($env:hostrecord3)
{
	if ($env:domainrecord3)
	{
    	$hostname = $env:hostrecord3
    	$domain = $env:domainrecord3
    	Delete-HostandIP
    }
}
if ($env:hostrecord4)
{
	if ($env:domainrecord4)
	{
    	$hostname = $env:hostrecord4
    	$domain = $env:domainrecord4
    	Delete-HostandIP
    }
}
if ($env:hostrecord5)
{
	if ($env:domainrecord5)
	{
    	$hostname = $env:hostrecord5
    	$domain = $env:domainrecord5
    	Delete-HostandIP
    }
}