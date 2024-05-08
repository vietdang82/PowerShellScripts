Write-Verbose -Message "Importing User Details..." -Verbose
  # Location of newuser csv file
$newusers = Import-CSV 'C:\users\admin.vincent\documents\windowspowershell\Scripts\newusers.csv'
# Password used for new user accounts
$Password = 'Welcome2CSNSW'
# Default New User Organisational Unit in ADUser
$OrgUnit = "OU=Liverpool,OU=St,OU=Users_CEC,OU=OneDrive,OU=Users,DC=cecnsw,DC=catholic,DC=edu,DC=au"


### Create ActiveDirectory Users
foreach($user in $newusers){
Write-Verbose -Message "Creating User(s) In AD..." -Verbose
## Office Details --- Modify these variables to adjust script
# Sydney
IF($user.office -eq 'Sydney' -AND $user.company -ne 'Avec')
{$streetaddress = 'Level 7, 123 Pitt Street'
$state = 'NSW'
$PostalCode = '2000'
$Country = 'AU'
$Company = $user.company}

}


### !!! Creates New User based on above criteria !!! 
New-ADUser -userprincipalname $user.emailaddress -GivenName $user.firstname -Surname $user.lastname -Name ($user.firstname+" "+$user.lastname) -DisplayName ($user.firstname+" "+$user.lastname) -StreetAddress $streetaddress -state $state -PostalCode $postalcode -Country $Country -OfficePhone $OfficePhone -Fax $fax -Path $OrgUnit -AccountPassword (ConvertTo-SecureString -AsPlaintext ($password) -Force) -Title $user.jobtitle -Office $user.office -City $user.Office -Description $user.jobtitle -Department $user.department -Company $user.company -Enabled 1 -samaccountname ($user.firstname+"."+$user.lastname) -EmailAddress $user.EmailAddress             

### Adds email proxyaddresses -- Modify these variables to adjust script
$username = $user.firstname+"."+$user.lastname

IF($user.company -eq 'Catholic Schools NSW'){
Set-ADuser -identity $username -Add @{Proxyaddresses="SMTP:"+$username+"@csnsw.catholic.edu.au"}
}

### Group Memberships


# Sydney
IF($user.office -eq 'Sydney'){
Add-ADGroupMember -Identity !All_Sydney_Office -Members $username
Add-ADGroupMember -Identity AP_Department_Sydney_M -Members $username
Set-ADUser -identity $username -Add @{employeeType="HD UCC Premium Sydney"}
}

Write-Verbose -Message "Syncing AD Users..." -Verbose
##### Replicate To TIAD02 and TIDC01 #
$User1 = Get-ADUser -Filter * -SearchBase "OU=_New Users,OU=Users,OU=AP,DC=talentint,DC=internal" | Sync-ADObject -Source "TIAD01" -Destination "TIAD02"
cmd /c "repadmin /replicate TIDC01.talentint.internal TIAD02.talentint.internal dc=talentint,dc=internal"



    Start-ADSyncSyncCycle -PolicyType Delta -Verbose
    Write-Verbose -Message "Waiting For Replication..." -Verbose
Start-Sleep -s 90

$User1 = Get-ADUser -Filter * -SearchBase "OU=_New Users,OU=Users,OU=AP,DC=talentint,DC=internal"

If ($User1.Count -eq 0 ){
       Write-Host "No New Users" 
    }

else {


### Configuration Details --- Modify these variables to adjust script
# Service account username used for O365 activites
$serviceun = 'itaccounts@talentint.onmicrosoft.com'
# Service account password stored as secure string in txt file
$servicepw = cat C:\Scripts\password.txt | convertto-securestring
# Licence pack assigned to new users
$licencepack = 'talentint:ENTERPRISEPACK'
# New user org unit
$orgunit = "OU=_New Users,OU=Users,OU=AP,DC=talentint,DC=internal"


Write-Verbose -Message "Connecting To O365..." -Verbose
### !!! Connects to Office365 Admin !!!
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $serviceun, $servicepw
Connect-msolservice -Credential $cred

### !!! Get new AD users !!!
$newusers = Get-ADUser -filter * -searchbase $orgunit | Select name,userprincipalname

Write-Verbose -Message "Adding O365 License..." -Verbose
### !!! Adds licence for each new user in org unit !!!
foreach($user in $newusers){
Set-MsolUser -UserPrincipalName $user.userprincipalname -UsageLocation AU
Set-MsolUserLicense -UserPrincipalName $user.userprincipalname -AddLicenses $licencepack
}
Write-Verbose -Message "Syncing Users..." -Verbose
Start-Sleep -s 180
Write-Verbose -Message "Enabling Litigation Hold on Mailbox..." -Verbose

### Connects to Exchange Online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $Session -AllowClobber

### Enables Litigation Hold on Mailbox
foreach($user in $newusers){
Set-Mailbox $user.userprincipalname -LitigationHoldEnabled $true
#Enable-Mailbox $user -Archive
#IF($user.office -ne 'Birmingham', 'Bristol', 'London', 'Manchester', 'Hunter Charles'){
#Add-MailboxPermission -Identity $user -User mail.admin@talentinternational.com -AccessRights FullAccess -InheritanceType All -AutoMapping $false
#}


}

}
<#
$SessionDetails = @{
        ConfigurationName = "Microsoft.Exchange"
        ConnectionUri = "http://tiex04.talentint.internal/PowerShell/"
        Authentication = "Kerberos"
        #Credential = $UserCredential

}

$Session = New-PSSession @SessionDetails
Import-PSSession $Session -AllowClobber

$NewMailbox = @{

    OrganizationalUnit = "OU=_New Users,OU=Users,OU=AP,DC=talentint,DC=internal" 
    #RecipientTypeDetails = "User"
    Filter = {UserPrincipalName -ne $Null}

}


Get-User @NewMailbox | Enable-Mailbox

#>


### Restores CSV file to default
Remove-item 'C:\Scripts\newusers.csv'
$csv = @"
FirstName,LastName,EmailAddress,Office,JobTitle,Department,Company
"@ >> 'C:\Scripts\newusers.csv'  


######## Move Users To Their OU #
$User1 = Get-ADUser -Filter * -SearchBase "OU=_New Users,OU=Users,OU=AP,DC=talentint,DC=internal" -Properties l | Select SamAccountName,@{Name="City";Expression={$_.l}}

If ($User1.Count -eq 0 ){
       Write-Host "No New Users" 
    }

else {
    $UserName1 = $User1.SamAccountName
    $Usercity = $User1.city
    Get-ADUser $UserName1 | Move-ADObject -TargetPath "OU=$Usercity,OU=Users,OU=AP,DC=talentint,DC=internal"

} 
Write-Verbose -Message "All Done, New User(s) Have Been Created!" -Verbose