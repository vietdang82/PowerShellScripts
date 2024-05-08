#Parameter
$TenantAdminURL = "https://Crescent-admin.sharepoint.com"
$LocaleId = 2057 # UK
$TimeZoneId = 2 # London
 
#Function to Set Regional Settings on SharePoint Online Web
Function Set-RegionalSettings
{
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ValueFromPipeline = $True)] $Web
    )
  
    Try {
        Write-host -f Yellow "Setting Regional Settings for:"$Web.Url
        #Get the Timezone
        $TimeZone = $Web.RegionalSettings.TimeZones | Where-Object {$_.Id -eq $TimeZoneId}
        #Update Regional Settings
        $Web.RegionalSettings.TimeZone = $TimeZone
        $Web.RegionalSettings.LocaleId = $LocaleId
        $Web.Update()
        Invoke-PnPQuery
        Write-host -f Green "`tRegional Settings Updated for "$Web.Url
    }
    Catch {
        write-host "`tError Setting Regional Settings: $($_.Exception.Message)" -foregroundcolor Red
    }
}
 
#Connect to Admin Center
$Cred = Get-Credential
Connect-PnPOnline -Url $TenantAdminURL -Credentials $Cred
   
#Get All Site collections - Exclude: Seach Center, Mysite Host, App Catalog, Content Type Hub, eDiscovery and Bot Sites
$SitesCollections = Get-PnPTenantSite | Where -Property Template -NotIn ("SRCHCEN#0", "REDIRECTSITE#0", "SPSMSITEHOST#0", "APPCATALOG#0", "POINTPUBLISHINGHUB#0", "EDISC#0", "STS#-1")
   
#Loop through each site collection
ForEach($Site in $SitesCollections)
{
    #Connect to site collection
    Connect-PnPOnline -Url $Site.Url -Credentials $Cred
  
    #Call the Function for all webs
    Get-PnPSubWeb -Recurse -IncludeRootWeb -Includes RegionalSettings, RegionalSettings.TimeZones | ForEach-Object { Set-RegionalSettings $_ }
}


#Read more: https://www.sharepointdiary.com/2019/06/sharepoint-online-change-regional-settings-using-powershell.html#ixzz8U8ZV9t6g