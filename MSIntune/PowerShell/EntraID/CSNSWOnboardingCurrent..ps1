<#
.SYNOPSIS
A script to create a new Catholic Scools NSW user in the cecnsw.catholic.edu.au domain.

.DESCRIPTION
This script will create a standardised user with all expected Active Direcory properties set as per CSNSW requirements.

Currently the script sets the following properties:

    * SAM Account Name as Firstname.Surname
    * Email addrss in the CSNSW.CATHOLIC.EDU.AU Domain
    * User Principal Name using CSNSW email address
    * Address details for CSNSW
    * Direct phone number based on allocated user extension
    * Job title
    * Direct Report (Manager)

.EXAMPLE
New-CSNswUser_v2.ps1 -noprompt -firstname Robert -middleinitial J -surname Smith -password MyP@ssW0Rd -jobtitle "Lead Singer - The Cure" -manager manager@thecure.com -extension 123

Command Line Only:
In this mode all paramaters must be specified for the script to function allowing for a single command to set all options for the new user.

.EXAMPLE
New-CSNswUser_v2.ps1 -noprompt

Command Line Prompted
In this mode no other parameters need to be specified, all paramaters will be collected during the running of the scripts via command line prompts.

.EXAMPLE
New-CSNswUser_v2.ps1 -gui

GUI Mode
In this mode a graphical user interface will be presented for the collection of the required parameters, you can specify several of the paramters via the command line.

New-CSNswUser_v2.ps1 -gui -firstname Robert -middleinitial J -surname Smith -jobtitle "Lead Singer - The Cure" -extension 123

These paramaters will be ignored in this mode:

    * password
    * manager

.PARAMETER gui
Launches the script in Graphical mode.

    -gui

    NOTE: When specified the other following paramaters can also be specified
        -firstname
        -middleinitial [Optional]
        -surname
        -jobtitle
        -extension

.PARAMETER noprompt
Launches the script in command line only mode. In this mode all other paramaters must be specified.

    -noprompt

    NOTE: When specified requires the other following paramaters to be specified
        -firstname
        -middleinitial [Optional]
        -surname
        -password
        -jobtitle
        -extension
        -manager

.PARAMETER firstname
A string value representing the users first name

    -firstname Robert

.PARAMETER middleinitial
An Optional string value representing the users middle initial, if this is excluded the initial will be created as the letter 'X'.

.PARAMETER surname
A string value representing the users Surname (Last Name).

    -surname Smith

.PARAMETER password
A string value representing the initial user password to be set.

This is a required paramater when the script is run in noprompt mode. In gui mode this paramater is ignored.

    -password MyP@ssW0rd

.PARAMETER jobtitle
A string value representing the users current job title. This is a required paramater when the script is run in noprompt mode.

    -jobtitle "Lead Singer - The Cure"

.PARAMETER extension
A string value representing the users personal phone extension

    -extension 555

.PARAMETER manager
A string value representing the users managers User Principal Name

    -manager manager@thecure.com

.NOTES
Yes the fact that you can use this script in 3 ways i a little bit of overkill, but the developer was trying out some new powershell
techniques at the time. So there!

.LINK
http://www.csnsw.catholic.edu.au
#>

# Revisions
# 1.1 - (24/07/19 by Tony Cook) Updated username to be firstname.surname rather than the old 3 letter sam account name


param (

    [switch]$gui = $false,
    [switch]$noprompt = $false,
    [string]$firstname,
    [string]$middleinitial,
    [string]$surname,
    [string]$password,
    [string]$jobtitle,
    [string]$manager,
    [string]$extension
)

function Decrypt-SecureString {
param(
    [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
    [System.Security.SecureString]
    $sstr
)

$marshal = [System.Runtime.InteropServices.Marshal]
$ptr = $marshal::SecureStringToBSTR( $sstr )
$str = $marshal::PtrToStringBSTR( $ptr )
$marshal::ZeroFreeBSTR( $ptr )
Return $str
}

function ShowGUI{
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = @'
    <Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" Height="415.925" Width="569.23" ResizeMode="NoResize">
    <Grid Margin="0,1,0,-1">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="379*"/>
            <ColumnDefinition Width="80*"/>
            <ColumnDefinition Width="104*"/>
        </Grid.ColumnDefinitions>
        <Grid HorizontalAlignment="Left" Height="68" Margin="-1,-1,0,0" VerticalAlignment="Top" Width="554" Grid.ColumnSpan="3">
            <Image HorizontalAlignment="Left" Height="56" VerticalAlignment="Top" Width="145" Source="C:\scripts\LGO_CSNSW_RGB_LowRes.jpg" Margin="7,6,0,0"/>
            <Grid HorizontalAlignment="Left" Height="351" Margin="0,67,0,-350" VerticalAlignment="Top" Width="134">
                <Label Content="First Name" HorizontalAlignment="Left" Height="34" Margin="5,2,-4,0" VerticalAlignment="Top" Width="133" FontSize="16" Background="#FF21AAE6" Foreground="White" VerticalContentAlignment="Center" HorizontalContentAlignment="Right"/>
                <Label Content="Middle Initial" HorizontalAlignment="Left" Height="34" Margin="5,39,-4,0" VerticalAlignment="Top" Width="133" FontSize="16" Background="#FF21AAE6" Foreground="White" VerticalContentAlignment="Center" HorizontalContentAlignment="Right"/>
                <Label Content="Surname" HorizontalAlignment="Left" Height="34" Margin="5,76,-4,0" VerticalAlignment="Top" Width="133" FontSize="16" Background="#FF21AAE6" Foreground="White" VerticalContentAlignment="Center" HorizontalContentAlignment="Right"/>
                <Label Content="Password" HorizontalAlignment="Left" Height="34" Margin="5,152,-4,0" VerticalAlignment="Top" Width="133" FontSize="16" Background="#FF21AAE6" Foreground="White" VerticalContentAlignment="Center" HorizontalContentAlignment="Right"/>
                <Label Content="Extension #" HorizontalAlignment="Left" Height="34" Margin="5,189,-4,0" VerticalAlignment="Top" Width="133" FontSize="16" Background="#FF21AAE6" Foreground="White" VerticalContentAlignment="Center" HorizontalContentAlignment="Right"/>
                <Label Content="Manager" HorizontalAlignment="Left" Height="34" Margin="5,226,-4,0" VerticalAlignment="Top" Width="133" FontSize="16" Background="#FF21AAE6" Foreground="White" VerticalContentAlignment="Center" HorizontalContentAlignment="Right"/>
                <Label Content="Job Title" HorizontalAlignment="Left" Height="34" Margin="5,114,-4,0" VerticalAlignment="Top" Width="133" FontSize="16" Background="#FF21AAE6" Foreground="White" VerticalContentAlignment="Center" HorizontalContentAlignment="Right"/>
            </Grid>
        </Grid>
        <TextBox HorizontalAlignment="Left" Height="27" Margin="165,6,0,0" TextWrapping="Wrap" Text="New CSNSW User" VerticalAlignment="Top" Width="196" FontFamily="Global Sans Serif" FontWeight="Bold" FontSize="22"/>
        <TextBlock HorizontalAlignment="Left" Height="21" Margin="166,39,0,0" TextWrapping="Wrap" Text="GUI for the PowerShell New-CSNswUser script." VerticalAlignment="Top" Width="378" Grid.ColumnSpan="3"/>
        <Grid HorizontalAlignment="Left" Height="308" Margin="137,67,0,0" VerticalAlignment="Top" Width="416" Grid.ColumnSpan="3">
            <TextBox Name="txtFirstName" TabIndex="0" HorizontalAlignment="Left" Height="34" TextWrapping="Wrap" VerticalAlignment="Top" Width="406" BorderBrush="#FF0078D7" FontSize="16" MaxLines="1" MaxLength="100" VerticalContentAlignment="Center" Margin="4,2,0,0"/>
            <TextBox Name="txtMiddleInitial" TabIndex="1" HorizontalAlignment="Left" Height="34" TextWrapping="Wrap" VerticalAlignment="Top" Width="406" BorderBrush="#FF0078D7" FontSize="16" MaxLines="1" MaxLength="100" VerticalContentAlignment="Center" Margin="4,39,0,0"/>
            <TextBox Name="txtSurname" TabIndex="2" HorizontalAlignment="Left" Height="34" TextWrapping="Wrap" VerticalAlignment="Top" Width="406" BorderBrush="#FF0078D7" FontSize="16" MaxLines="1" MaxLength="100" VerticalContentAlignment="Center" Margin="4,76,0,0"/>
            <TextBox Name="txtExtension" TabIndex="5" HorizontalAlignment="Left" Height="34" TextWrapping="Wrap" VerticalAlignment="Top" Width="406" BorderBrush="#FF0078D7" FontSize="16" MaxLines="1" MaxLength="100" VerticalContentAlignment="Center" Margin="4,188,0,0"/>
            <ComboBox Name="cboManager" TabIndex="6" HorizontalAlignment="Left" Height="34" Margin="4,226,0,0" VerticalAlignment="Top" Width="406" BorderBrush="#FF0078D7" IsReadOnly="True" FontSize="16" OpacityMask="Black" Background="{x:Null}"/>
            <Button Name="btnOK" Content="OK" TabIndex="7" HorizontalAlignment="Left" Height="34" Margin="283,271,0,0" VerticalAlignment="Top" Width="127"/>
            <Button Name="btnCancel" Content="Cancel" TabIndex="8" HorizontalAlignment="Left" Height="34" Margin="147,271,0,0" VerticalAlignment="Top" Width="127" IsCancel="True"/>
            <TextBox Name="txtJobTitle" TabIndex="3" HorizontalAlignment="Left" Height="34" TextWrapping="Wrap" VerticalAlignment="Top" Width="406" BorderBrush="#FF0078D7" FontSize="16" MaxLines="1" MaxLength="100" VerticalContentAlignment="Center" Margin="4,113,0,0"/>
            <TextBox Name="txtPassword" TabIndex="4" HorizontalAlignment="Left" Height="34" TextWrapping="Wrap" VerticalAlignment="Top" Width="406" BorderBrush="#FF0078D7" FontSize="16" MaxLines="1" MaxLength="100" VerticalContentAlignment="Center" Margin="4,150,0,0"/>
        </Grid>

    </Grid>
</Window>
'@

    #Read XAML
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
    try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
    catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

    #===========================================================================
    # Store Form Objects In PowerShell
    #===========================================================================

    $xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}


    #===========================================================================
    # Set some variables
    #===========================================================================
    $ManagersOU = "OU=Users_CEC,OU=.Liverpool St,DC=cecnsw,DC=catholic,DC=edu,DC=au"
    $adManagers = Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ManagersOU -Properties * | Select-Object DisplayName, UserPrincipalName


    #===========================================================================
    # Add some event handlers and populate controls with data
    #===========================================================================

    $btnOK.Add_Click({
    # event handler for the OK Button click event

        # Validate the form

        $BorderColour = $txtFirstName.BorderBrush
        $isValid = $true

        if ($txtFirstName.Text -eq "") {
            $txtFirstName.BorderBrush = "#FFFF0101"
            $isValid = $false
        } else {
            $txtFirstName.BorderBrush = $BorderColour

        }

        if ($txtMiddleInitial.Text -eq "") {
            $txtMiddleInitial.BorderBrush = "#FFFF0101"
            $isValid = $false
        } else {
            $txtMiddleInitial.BorderBrush = $BorderColour
            
        }

        if ($txtSurname.Text -eq "") {
            $txtSurname.BorderBrush = "#FFFF0101"
            $isValid = $false
        } else {
            $txtSurname.BorderBrush = $BorderColour
            
        }

        if ($txtJobTitle.Text -eq "") {
            $txtJobTitle.BorderBrush = "#FFFF0101"
            $isValid = $false
        } else {
            $txtJobTitle.BorderBrush = $BorderColour
            
        }

        if ($txtPassword.Text -eq "") {
            $txtPassword.BorderBrush = "#FFFF0101"
            $isValid = $false
        } else {
            $txtPassword.BorderBrush = $BorderColour
            
        }

        if ($txtExtension.Text -eq "") {
            $txtExtension.BorderBrush = "#FFFF0101"
            $isValid = $false
        } else {
            $txtExtension.BorderBrush = $BorderColour
            
        }

        if ($cboManager.SelectedIndex -eq -1) {
            $isValid = $false
        } else {
            $mgr = $cboManager.SelectedItem
            $mgr = $mgr.UserPrincipalName


            if ($mgr -eq $null) {
                Throw "Required parameter is missing:  manager"
            } else {
                $adManagerName = Get-ADUser -Filter {UserPrincipalName -eq $mgr} -SearchBase $UsersOU -Properties *
        
                if ($adManagerName -eq $null) {
                    Throw "Unable to get the AD User for $mgr"
                }
            }

        }

        #Write-Host "OK Button Clicked"
        if ($isValid) {
            $Form.Close()
            $securePassword = Convertto-SecureString $txtPassword.Text -AsPlainText -Force
            AddNewUser $txtFirstName.Text $txtMiddleInitial.Text $txtSurname.Text $securePassword $txtJobTitle.Text $adManagerName $txtExtension.Text
        }

    })

    #Populate combo Box

    $cboManager.ItemsSource = $adManagers
    $cboManager.DisplayMemberPath = 'DisplayName'

    $txtFirstname.Text = $firstname
    $txtMiddleInitial.Text = $middleinitial
    $txtSurname.Text = $surname
    $txtExtension.Text = $extension
    $txtPassword.Text = $password
    $txtJobTitle.Text = $jobtitle

    # Manager is ignored as must be select from the list


    #===========================================================================
    # Shows the form
    #===========================================================================
    $Form.ShowDialog() | out-null


    # Check entered details and process the new user addition

}

function ProcessNoPrompt{
    
    #===========================================================================
    # Script was called with the NoPrompt option, need to verify information 
    # and if all good proceed to add the new user.
    #===========================================================================

    # Assign values from supplied parameters

    if ($firstname -eq "") {
        Throw "Required parameter is missing:  firstname"
    } else {
        $FirstName = $firstname
    }

    if ($middleinitial -eq "") {
        Throw "Required parameter is missing:  middleinitial"
    } else {
        $MidInitial = $middleinitial
    }
    
    if ($surname -eq "") {
        Throw "Required parameter is missing:  surname"
    } else {
        $Surname = $surname
    }
    
    if ($password -eq "") {
        Throw "Required parameter is missing:  password"
    } else {
        $InitialPass = ConvertTo-SecureString $password -AsPlainText -force
    }

    if ($jobtitle -eq "") {
        Throw "Required parameter is missing:  jobtitle"
    } else {
        $jobTitle = $jobtitle
    }
    
    if ($extension -eq "") {
        Throw "Required parameter is missing:  extension"
    } else {
        $Extension = $extension
    }
    
    if ($manager -eq "") {
        Throw "Required parameter is missing:  manager"
    } else {
        $adManagerName = Get-ADUser -Filter {UserPrincipalName -eq $manager} -SearchBase $UsersOU -Properties *
        
        if ($adManagerName -eq $null) {
            Throw "Unable to get the AD User for $manager"
        }

    }
    
    # All is fine so proceed
    AddNewUser $FirstName $MidInitial $Surname $InitialPass $jobTitle $adManagerName $Extension
}

function GuidedNewUserSetup{

    #===========================================================================
    # Script is launced in Prompted mode, Ask for the details required
    #===========================================================================


    Do{
    $FirstName = Read-Host -Prompt 'Input the users First Name?'
    }
    Until ($FirstName -ne "")

    $MidInitial = Read-Host -Prompt 'Input the users Middle initial?'
    If ($MidInitial -eq "") {
        $MidInitial ="X"
    } else {
        $MidInitial = $MidInitial.Substring(0,1)
        $MidInitial = $MidInitial.ToUpper()
    }

    Do{
        $Surname = Read-Host -Prompt 'Input the users Surname?'
        }
        Until ($Surname -ne "")

    $PassConfirmClr = "__Nothing__"
    While ($InitialPassClr -ne $PassConfirmClr){
        Do{
            $InitialPass = Read-Host -Prompt 'Input the users initial password?' -AsSecureString
            }
            Until ($InitialPass -ne "")

        Do {
            $PassConfirm = Read-Host -Prompt 'Please confirm the password?' -AsSecureString
            }
            Until ($InitialPass -ne "")

           $InitialPassClr = Decrypt-SecureString($InitialPass)
           $PassConfirmClr = Decrypt-SecureString($PassConfirm)

        }

    $Extension = Read-Host -Prompt "Please enter the users phone extension"
    $phoneNum = "(02) 9287 1$Extension"

    $confirm = ""
    while ($confirm -notlike "y") {
        $jobTitle = Read-Host -Prompt "Enter the users Job Title"
        $confirm = Read-host -Prompt "Is the Job Title '$jobTitle' correct (Y/N)?"
    }

    $iterations = -1
    while ($adManagerName.Name -eq $null){
        $iterations++
        if ($iterations -gt 0) {
            Write-Host "Unable to locate the specified manager`n" -ForegroundColor Red
        }

        $managerName = Read-Host -Prompt "What is the users Managers UPN?"
        $adManagerName = Get-ADUser -Filter {UserPrincipalName -eq $managerName} -SearchBase $UsersOU -Properties *
    }    

    AddNewUser $FirstName $MidInitial $Surname $InitialPass $jobTitle $adManagerName $Extension
   

}

function AddNewUser($sFirstName, $sInitial, $sSurname, $sPassword, $sJobTitle, $sManager, $sExtension) {

    #===========================================================================
    # Function to add the new user regardsless of execution mode
    #===========================================================================

     # Prep new variables based on the collected user details
    $NewEmail = $sFirstName + "." + $sSurname + "@" + $EmailDomain
    # $NewUserName = $sFirstName.Substring(0,1) + $sInitial + $sSurname.Substring(0,1)
    $NewUserName = $sFirstName + "." + $sSurname
    $NewUPN = $NewEmail
    $UserDisplayName = $sFirstName + " " + $sSurname
    $UserDescription = $UserDisplayName + " (" + $NewUserName + ")"
    $adManagerName = $sManager
    $jobTitle = $sJobTitle
    $phoneNum = "(02) 9287 1$sExtension"

    # Show the settings that are about to be used

    Write-Host "`n--------------------------------------------------------"
    Write-Host "Creating the user $FirstName $MidInitial $Surname"
    Write-Host "--------------------------------------------------------"
    Write-Host ""
    Write-Host "The following information will be used:"
    Write-Host ""
    Write-Host "Display Name:         $UserDisplayName"
    Write-Host "SAM Account Name:     $newUserName"
    Write-Host "Email Address:        $NewEmail"
    Write-Host "User Principal Name:  $NewUPN"
    Write-Host "Description:          $UserDescription"
    Write-Host "Managers Name:        $($adManagerName.Name)"
    Write-Host "Job Title:            $jobTitle"
    Write-Host "PO Box:               $($address.POBox)"
    Write-Host "Address:              $($address.Street)"
    Write-Host "                      $($address.City), $($address.State) $($address.zip)"
    Write-Host "Country:              $($address.Country)"
    Write-Host "Phone Number:         $phoneNum"
    Write-Host "--------------------------------------------------------`n`n"


    $confirm = ""
    while ($confirm -eq "") {
        $confirm = Read-host -Prompt "Create the user (Y/N)?"
    }

if ($confirm -like "Y") {
    Write-Host 'Creating the user'

    $NewUser = New-ADUser `
        -Confirm `
        -AccountPassword $sPassword `
        -DisplayName $UserDisplayName `
        -Description $UserDescription `
        -EmailAddress $NewEmail `
        -GivenName $FirstName `
        -Name $UserDisplayName `
        -Surname $Surname `
        -StreetAddress $address.Street `
        -POBox $address.POBox `
        -PostalCode $address.Zip `
        -City $address.City `
        -State $address.State `
        -Country $address.Country `
        -HomePage $webPage `
        -Company $companyName `
        -Title $jobTitle `
        -Manager $adManagerName `
        -SamAccountName $NewUserName `
        -UserPrincipalName $NewUPN `
        -Path $UsersOU `
        -PassThru

    # Update the Proxy Addresses fro the new user
    Write-Host 'Updating User Attributes'

    $NewUser.ProxyAddresses.Add("SMTP:$($NewEmail)")

    Write-host "Setting Phone Numbers..."
    $NewUser.telephoneNumber = $phoneNum
    $NewUser.ipPhone = $phoneNum

    Set-ADUser -Instance $NewUser

    #Add Group Memberships
    #TODO: parameterise the default printers
    Add-ADGroupMember -Identity "All CSNSW Staff" -Members $NewUserName 
    Add-ADGroupMember -Identity "CEC Workstation" -Members $NewUserName 
    Add-ADGroupMember -Identity "Level 9 Default Printers" -Members $NewUserName 
	Add-ADGroupMember -Identity "Microsoft 365 A5" -Members $NewUserName
	
    # Synchronise group members for Complispace
    Write-Host "Syncing CompliSpace Group Members" -ForegroundColor Yellow
    & "$PSScriptRoot\Sync-ComplispaceUsers.ps1"
}

# Clean Up
$adManagerName = $null
$NewUser = $null

Write-Host "Complete!" -ForegroundColor Yellow
}

#===========================================================================
# Main Script
#===========================================================================

#===========================================================================
# Global variables for the script
#===========================================================================

if ($gui.IsPresent) {
    $gui = $true
}

if ($noprompt.IsPresent) {
    $noprompt = $true
}


$EmailDomain = "csnsw.catholic.edu.au"
$UsersOU = "OU=Users_CEC,OU=.Liverpool St,DC=cecnsw,DC=catholic,DC=edu,DC=au"

$NewUserName
$NewEmail
$NewProxyAddress
$NewUPN

$webPage = "http://www.csnsw.catholic.edu.au"
$companyName = "Catholic Schools NSW"
$address = New-Object -TypeName PSObject

$address | Add-Member -MemberType NoteProperty -Name Street -Value "L7, 123 Pitt St"
$address | Add-Member -MemberType NoteProperty -Name POBox -Value "PO Box 20768 World Square NSW 2002"
$address | Add-Member -MemberType NoteProperty -Name City -Value "Sydney"
$address | Add-Member -MemberType NoteProperty -Name State -Value "NSW"
$address | Add-Member -MemberType NoteProperty -Name Zip -Value "2000"
$address | Add-Member -MemberType NoteProperty -Name Country -Value "AU"

if ($gui){

    ShowGui

} elseif ($noprompt) {
    
    ProcessNoPrompt

} else {
    
    GuidedNewUserSetup

}
