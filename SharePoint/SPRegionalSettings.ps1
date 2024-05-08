#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
  
#Config parameters for SharePoint Online Site URL and Timezone description
$SiteURL = "https://catholicschoolsnsw.sharepoint.com/SitePages/Home.aspx"
  
#Get Credentials to connect
$Cred= Get-Credential
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
    
#Set up the context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Ctx.Credentials = $credentials
$Web = $Ctx.Web
  
#Update Regional Settings in sharepoint online using powershell
$Web.RegionalSettings.LocaleId = 1033 # English
$Web.RegionalSettings.WorkDayStartHour = 9
$Web.RegionalSettings.WorkDayEndHour = 6
 
$Web.RegionalSettings.FirstDayOfWeek = 0 # Sunday
$Web.RegionalSettings.Time24 = $False
 
$Web.RegionalSettings.CalendarType = 1 #Gregorian
$Web.RegionalSettings.AlternateCalendarType = 0 #None
 
#64 = Sunday; 32 = Monday; 16 = Tuesday; 8 = Wednesday; 4 = Thursday; 2 = Friday; 1 = Saturday;  All Days = 127; None = 0
$Web.RegionalSettings.WorkDays = 124
 
$Web.Update()
$Ctx.ExecuteQuery()


#Read more: https://www.sharepointdiary.com/2019/06/sharepoint-online-change-regional-settings-using-powershell.html#ixzz8U8Z7hIbW