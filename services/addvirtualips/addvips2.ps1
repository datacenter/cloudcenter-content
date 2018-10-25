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
$networkmask = $env:networklist


#######################################
#Begin function
#######################################
function Set-NewHostIP
{

	$qualifiedhost = $hostname+"."+$domain
	#
	$urlbody1="https://172.16.201.201/wapi/v2.6/record:host?_return_fields=ipv4addrs"
	$body='{"ipv4addrs":[{"ipv4addr":"func:nextavailableip:0.0.0.0/24"}],"name":"temphost.tempdomain"}' 

	#######################################
	#Replace temp variables
	#######################################
	#$body=$body -replace "0.0.0.0", $network
	#$body=$body -replace "24", $mask
	$body=$body -replace "0.0.0.0/24", $networkmask
	$body=$body -replace "temphost", $hostname
	$body=$body -replace "tempdomain", $domain
	$fullurl = $urlbody1+$urlbody2
	$contentbody="application/json"

	#######################################
	#Get Next Available IP address and allocate it
	#######################################
	Invoke-RestMethod $urlbody1 -Method Post -Body $body -Credential $cred -ContentType $contentbody

	########################################
	#Get IP Address for new IP allocated by Infoblox
	########################################

	$InfobloxURI = "https://172.16.201.201/wapi/v2.6/record:host?name=$qualifiedhost"
	$webrequest = Invoke-WebRequest -Uri $InfobloxURI -Credential $cred -UseBasicParsing
	$b=$webrequest.Content | ConvertFrom-Json
	$refnew = $b._ref
	$b = $b | select @{l='Ref_ID';e={returnmatch -ref $refnew}},@{l='Host';e={($_ | select -ExpandProperty ipv4addrs).host}},@{l='IPV4Addr';e={($_ | select -ExpandProperty ipv4addrs).ipv4addr}}
	#echo $b.IPV4addr

	########################################
	#Set NIC IP and hostname on the OS
	########################################
	$ipaddress = $b.IPV4addr
	$interfacename = Get-NetAdapter -Name "*" | Select -ExpandProperty "Name"
	New-NetIPAddress -IPAddress $ipaddress -InterfaceAlias "Ethernet0" -PrefixLength 24 -SkipAsSource $True
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
    	Set-NewHostIP
    }
}
if ($env:hostrecord2)
{
	if ($env:domainrecord2)
	{
    	$hostname = $env:hostrecord2
    	$domain = $env:domainrecord2
    	Set-NewHostIP
    }
}
if ($env:hostrecord3)
{
	if ($env:domainrecord3)
	{
    	$hostname = $env:hostrecord3
    	$domain = $env:domainrecord3
    	Set-NewHostIP
    }
}
if ($env:hostrecord4)
{
	if ($env:domainrecord4)
	{
    	$hostname = $env:hostrecord4
    	$domain = $env:domainrecord4
    	Set-NewHostIP
    }
}
if ($env:hostrecord5)
{
	if ($env:domainrecord5)
	{
    	$hostname = $env:hostrecord5
    	$domain = $env:domainrecord5
    	Set-NewHostIP
    }
}