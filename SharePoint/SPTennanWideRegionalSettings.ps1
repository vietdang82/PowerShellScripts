#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

#function to change Timezone regional settings of a SharePoint Online site
Function Set-SPOnlineTimeZone([String]$SiteURL,[String]$TimezoneName,[PSCredential]$Cred) {
    Try {
        #Setup Credentials to connect
        $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)

        #Set up the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
        $Ctx.Credentials = $credentials

        #Get the Root web from given URL
        $Web = $Ctx.web
        $Ctx.Load($Web)

        #Get the Time zone to update
        $Timezones = $Web.RegionalSettings.TimeZones
        $Ctx.Load($Timezones)
        $Ctx.ExecuteQuery()
        $NewTimezone = $Timezones | Where {$_.Description -eq $TimezoneName}

        #Update the timezone of the site
        $Web.RegionalSettings.TimeZone = $NewTimezone
        $Web.Update()
        $Ctx.ExecuteQuery()

        Write-host -f Green "Timezone has been updated for "$Web.Url

        #Get all subsites of the web
        $Ctx.Load($Web.Webs)
        $Ctx.executeQuery()

        #Iterate through each subsites and call the function recursively
        Foreach ($Subweb in $Web.Webs){
            #Call the function to set Timezone for the web
            Set-SPOnlineTimeZone -SiteURL $Subweb.URL -TimezoneName $TimezoneName -Cred $AdminCredentials
        }
    }
    Catch [System.Exception]{
        Write-Host -f Red $_.Exception.Message
    }
}


#Parameters
$AdminSiteURL = "https://<tenant>-admin.sharepoint.com/"
$TimezoneName = "(UTC) Coordinated Universal Time"

#Get credentials to connect to SharePoint Online Admin Center
$AdminCredentials = Get-Credential

#Connect to SharePoint Online Tenant Admin
Connect-SPOService -URL $AdminSiteURL -Credential $AdminCredentials

#Get all Site Collections
$SitesCollection = Get-SPOSite -Limit ALL

#Iterate through each site collection
ForEach($Site in $SitesCollection) {
    Write-host -f Yellow "Setting Timezone for Site Collection:"$Site.URL

    #Call the function to set Timezone for the site
    Set-SPOnlineTimeZone -SiteURL $Site.URL -TimezoneName $TimezoneName -cred $AdminCredentials
}