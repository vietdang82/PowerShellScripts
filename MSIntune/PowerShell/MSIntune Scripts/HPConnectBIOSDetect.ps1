function ClientDetection {
    Param([string]$exception)
   	if($exception -ne "")
	{
		$ReturnCode = "1"
		$ReturnCodeDescription= 'Not compliant due to: '+ $exception
	} 
	
	$Bios_Authentication_Detection_Event ="BIOS_Authentication_Detection_Script"
	$Bios_Update_Detection_Event="BIOS_Update_Detection_Script"
	$Generic_Detection_Event_Name ="Generic_Detection_Script"
	$Prerequisites_Detect_Event = "Prerequisites_Detection_Script"
	$ActiveFreeze_Detection_Event_Name ="FreezeRules_Detection_Script"
	$Bios_Setting_Detection_Event ="BIOS_Setting_Detection_Script"
	switch($Discovery)
	{
	"BiosAuthenticationDiscovery"
	{
		#add BIOS Authentication event :
		
		$BiosAuth = $EventDetails.PsObject.Copy()
		$BiosAuth."11" =$Bios_Authentication_Detection_Event
		$BiosAuth."12" = $currentState
		$BiosAuth."13" = $targetState
		$BiosAuth."16" ="1"
		$BiosAuth."17" =$ReturnCodeDescription
		$Events = @(@{ "22.1" = $BiosAuth })
		Out-File $logFile -Append -InputObject "Bios Authentication Non-Compliance Detection before posting analytics"
		Post_Analytics
	}
	"BiosSettingsDiscovery"
	{
		$BiosAuth = $EventDetails.PsObject.Copy()
		$BiosSetting = $EventDetails.PsObject.Copy()

		#add BIOS Authentication event 
		$BiosAuth."11" = $Bios_Authentication_Detection_Event
		$BiosAuth."12" = $currentState
		$BiosAuth."13" = $targetState
		$BiosAuth."16" = "0"
		$BiosAuth."17" = "BIOS Authentication policy is compliant"
		
		#add BIOS Settings event :
		$BiosSetting."11" = $Bios_Setting_Detection_Event
		$BiosSetting."16" = "1"
		$BiosSetting."17" = $ReturnCodeDescription
		$Events = @{ "22.1" = $BiosAuth }	, @{ "22.1" = $BiosSetting}
		Out-File $logFile -Append -InputObject "Bios Setting Non-Compliance Detection before posting analytics"
		Post_Analytics
	}
	"BiosUpdatesDiscovery"
	{
		$BiosAuth = $EventDetails.PsObject.Copy()
		$BiosSetting = $EventDetails.PsObject.Copy()
		$BiosUpdate = $EventDetails.PsObject.Copy()

		#add BIOS Authentication event 
		$BiosAuth."11" = $Bios_Authentication_Detection_Event
		$BiosAuth."12" = $currentState
		$BiosAuth."13" = $targetState
		$BiosAuth."16" = "0"
		$BiosAuth."17" = "BIOS Authentication policy is compliant"	

		#add BIOS Settings event :
		$BiosSetting."11" = $Bios_Setting_Detection_Event
		$BiosSetting."16" = "0"
		$BiosSetting."17" = "BIOS Setting policy is compliant"	

		#add BIOS Update event :
		$BiosUpdate."11" = $Bios_Update_Detection_Event
		$BiosUpdate."12" = $currentVersionInfo
		$BiosUpdate."13" = $targetVersionInfo
		$BiosUpdate."16" ="1"
		$BiosUpdate."17" =$ReturnCodeDescription		
		$Events = @{ "22.1" = $BiosAuth }	, @{ "22.1" = $BiosSetting}	, @{ "22.1" = $BiosUpdate}
		Out-File $logFile -Append -InputObject "Bios Update Non-Compliance Detection before posting analytics"
		Post_Analytics
	}
	"AllPoliciesCompliant"
	{

		#add BIOS Authentication event :
		$BiosAuth = $EventDetails.PsObject.Copy()
		$BiosSetting = $EventDetails.PsObject.Copy()
		$BiosUpdate = $EventDetails.PsObject.Copy()

		$BiosAuth."11" = $Bios_Authentication_Detection_Event
		$BiosAuth."12" = $currentState
		$BiosAuth."13" = $targetState
		$BiosAuth."16" ="0"
		$BiosAuth."17" ="BIOS Authentication policy is compliant"

		#add BIOS Settings event :
		$BiosSetting."11" = $Bios_Setting_Detection_Event
		$BiosSetting."16" = "0"
		$BiosSetting."17" = "BIOS Setting policy is compliant"	

		#add BIOS Update event :
		$BiosUpdate."11" = $Bios_Update_Detection_Event
		$BiosUpdate."12" = $currentVersionInfo
		$BiosUpdate."13" = $targetVersionInfo 
		$BiosUpdate."16" ="0"
		$BiosUpdate."17" ="BIOS Update policy is compliant"		
		$Events = @{ "22.1" = $BiosAuth }, @{ "22.1" = $BiosSetting}	, @{ "22.1" = $BiosUpdate}
		Out-File $logFile -Append -InputObject "All policies compliance Detection before posting analytics"
		Post_Analytics
	}
	"PreRequisitesDiscovery"
	{
		Out-File $logFile -Append -InputObject "Failed at Pre Requisite detection: $($_.Exception.Message)"
	}
	"ClientDetailsDiscovery"
	{
		Out-File $logFile -Append -InputObject "Failed at Client details detection: $($_.Exception.Message)"
	}
	"FreezeRulesDiscovery"
	{
		$ReturnCodeDescription = "Active Freeze Rules in Detection"
		$freezeStartDate = $freezeStartDate.ToUniversalTime().ToString('yyyy-MM-dd')
		if($freezeEndDate)
		{
			$freezeEndDate = $freezeEndDate.ToUniversalTime().ToString('yyyy-MM-dd')
		}
		$EventDetails."11" = $ActiveFreeze_Detection_Event_Name
		$EventDetails."16" = "0"
		$EventDetails."17" =$ReturnCodeDescription	
		$EventDetails."14" = $freezeStartDate
		$EventDetails."15" = $freezeEndDate
		$Events = @(@{ "22.1" = $EventDetails })
		Out-File $logFile -Append -InputObject "FreezeRules Detection before posting analytics"
		Post_Analytics
	}
	Default 
	{
		$EventDetails."11" = $Generic_Detection_Event_Name
		$EventDetails."16" = "1"
		$EventDetails."17" =$ReturnCodeDescription	
		$Events = @(@{ "22.1" = $EventDetails })
		Out-File $logFile -Append -InputObject "Generic Non-Compliance Detection before posting analytics"
		Post_Analytics
	}
	}
	
}

try
{      
   $logFolder = "$($Env:LocalAppData)\HPConnect\Logs"  
   $logFile = "244a2593-f107-4425-a87f-3d05f0e4e07d"
   $logPathDir = [System.IO.Path]::GetDirectoryName($logFolder)

   if ((Test-Path -Path $logPathDir) -eq $false) {
      New-Item -ItemType Directory -Force -Path $logPathDir | Out-Null
   }
   if ((Test-Path -Path $logFolder) -eq $false) {
      New-Item -ItemType directory -Force -Path $logFolder | Out-Null
      $oldPathDir = "$($Env:ProgramData)\HP\Endpoint"
      if (Test-Path -Path $oldPathDir) {
          Out-File "$logFolder\$logFile" -Append -InputObject "Copying existing logs from ProgramData to AppData"
          Copy-Item -Path "$oldPathDir\Logs\*" -Destination $logFolder -Recurse -ErrorAction Ignore | Out-Null
          Remove-Item -Path $oldPathDir -Recurse -ErrorAction Ignore
      }
   } 
   $date = Get-Date
   $logFile = $logFolder + "\" +  $logFile
   Out-File $logFile -Append -InputObject "====================== Discovery Script ======================"
   Out-File $logFile -Append -InputObject $date
   
    enum PolicyDiscovery
    {
            FreezeRulesDiscovery
            PreRequisitesDiscovery
            BiosAuthenticationDiscovery
            BiosSettingsDiscovery
            BiosUpdatesDiscovery
            ClientDetailsDiscovery
            AllPoliciesCompliant
    }
   $exception = ""
    
   # Pre-requisites, i.e: HP-CMSL instalation
   [PolicyDiscovery]$Discovery =[PolicyDiscovery]::PreRequisitesDiscovery
   Out-File $logFile -Append -InputObject $Discovery
   function Get-LastestCMSLFromCatalog {
    Param([string]$catalog)

    $json = $catalog | ConvertFrom-Json
    $filter = $json."hp-cmsl" | Where-Object { $_.isLatest -eq $true }
    $sort = @($filter | Sort-Object -Property version -Descending)
    $sort[0]
}

# URI to get last HP-CMSL version approved for HP Connect
$preReqUri = 'https://hpia.hpcloud.hp.com/downloads/cmsl/wl/hp-mem-client-prereq.json'
$localDir = "$($Env:LocalAppData)\HPConnect\Tools"
$sharedTools = "$($Env:ProgramFiles)\HPConnect"
$maxTries = 3
$triesInterval = 10

# Read local metadata
$localCatalog = "$localDir\hp-mem-client-prereq.json"
$isLocalLocked = $false
if ([System.IO.File]::Exists($localCatalog) -and [System.IO.Directory]::Exists("$sharedTools\hp-cmsl-wl")) {
    $local = Get-LastestCMSLFromCatalog(Get-Content -Path $localCatalog)
    $isLocalLocked = $local.isLocalLocked -eq $true
    Out-File $logFile -Append -InputObject "Current version of HP-CMSL-WL is $($local.version)"
}
else {
    $new = $true
    New-Item -ItemType Directory -Force -Path $localDir | Out-Null
    New-Item -ItemType Directory -Force -Path $sharedTools | Out-Null
}

if (-not $isLocalLocked) {
    # Download remote metadata
    $userAgent = "hpconnect-script"
    # Removing obsolete protocols SSL 3.0, TLS 1.0 and TLS 1.1
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]([System.Net.SecurityProtocolType].GetEnumNames() | Where-Object { $_ -ne "Ssl3" -and $_ -ne "Tls" -and $_ -ne "Tls11" })

    $failedToDownloadCatalog = $false
    $tries = 0
    while ($tries -lt $maxTries) {
        try {
            $data = Invoke-WebRequest -Uri $preReqUri -UserAgent $userAgent -UseBasicParsing -ErrorAction Stop -Verbose 4>> $logFile
            break
        }
        catch {
            Out-File $logFile -Append -InputObject "Failed to retrieve HP-CMSL-WL catalog ($($tries+1)/$maxTries) : $($_.Exception.Message)"
            if ($tries -lt $maxTries-1) {
                if ($tries -lt $maxTries-1) {
                    # Wait some interval between tries
                    Start-Sleep -Seconds $triesInterval
                }
            }
            else {
                if ($new) {
                    throw "Unable to retrieve HP-CMSL-WL catalog"
                }
                else {
                    Out-File $logFile -Append -InputObject "Unable to retrieve HP-CMSL-WL catalog. The script will continue with the local version"
                    $failedToDownloadCatalog = $true
                }
            }
        }
        $tries = $tries + 1
    }

    if (-not $failedToDownloadCatalog) {
        $catalog = [System.IO.StreamReader]::new($data.RawContentStream).ReadToEnd()
        $remote = Get-LastestCMSLFromCatalog($catalog)

        if ($new -or $remote.version -gt $local.version) {
            throw "A new version of HP-CMSL-WL was found, update local version to $($remote.version)"
        }
    }
}
else {
    Out-File $logFile -Append -InputObject "Using a local locked version of HP-CMSL-WL"
}

# Import CMSL modules from local folder
Out-File $logFile -Append -InputObject "Import CMSL from $sharedTools\hp-cmsl-wl"
$modules = @(
    'HP.Private',
    'HP.Utility',
    'HP.ClientManagement',
    'HP.Firmware',
    'HP.Notifications',
    'HP.Retail',
    'HP.Softpaq',
    'HP.Sinks',
    'HP.Repo',
    'HP.Consent',
    'HP.SmartExperiences'
)
foreach ($m in $modules) {
    if (Get-Module -Name $m) { Remove-Module -Force $m }
}
foreach ($m in $modules) {
    try {
        Import-Module -Force "$sharedTools\hp-cmsl-wl\modules\$m\$m.psd1" -ErrorAction Stop
    }
    catch {
        $exception = $_.Exception
        Out-File $logFile -Append -InputObject "Failed to import module $m"
        throw $exception
    }
}

   # Gather client device details for Posting Analytics
   [PolicyDiscovery]$Discovery =[PolicyDiscovery]::ClientDetailsDiscovery
    Out-File $logFile -Append -InputObject "Gather client device details"
   	# function for compression
	function Compress-Data 
	{
		<#
		.Synopsis
			Compresses data
		.Description
			Compresses data into a GZipStream
		.Link
			Expand-Data
		.Link
			http://msdn.microsoft.com/en-us/library/system.io.compression.gzipstream.aspx
		.Example
			$rawData = (Get-Command | Select-Object -ExpandProperty Name | Out-String)
			$originalSize = $rawData.Length
			$compressed = Compress-Data $rawData -As Byte
			"$($compressed.Length / $originalSize)% Smaller [ Compressed size $($compressed.Length / 1kb)kb : Original Size $($originalSize /1kb)kb] "
			Expand-Data -BinaryData $compressed
		#>
		[OutputType([String],[byte])]
		[CmdletBinding(DefaultParameterSetName='String')]
		param(
		# A string to compress
		[Parameter(ParameterSetName='String',
			Position=0,
			Mandatory=$true,
			ValueFromPipelineByPropertyName=$true)]
		[string]$String,
    
		# A byte array to compress.
		[Parameter(ParameterSetName='Data',
			Position=0,
			Mandatory=$true,
			ValueFromPipelineByPropertyName=$true)]
		[Byte[]]$Data,
    
		# Determine how the data is returned.
		# If set to byte, the data will be returned as a byte array. If set to string, it will be returned as a string.
		[ValidateSet('String','Byte')]
		[String]$As = 'string'   
		)
    
		process {
           
			if ($psCmdlet.ParameterSetName -eq 'String') {
				$Data= foreach ($c in $string.ToCharArray()) {
					$c -as [Byte]
				}            
			}
        
			#region Compress Data
			$ms = New-Object IO.MemoryStream                
			$cs = New-Object System.IO.Compression.GZipStream ($ms, [Io.Compression.CompressionMode]"Compress")
			$cs.Write($Data, 0, $Data.Length)
			$cs.Close()
			#endregion Compress Data
        
			#region Output CompressedData
			if ($as -eq 'Byte') {
				$ms.ToArray()
            
			} elseif ($as -eq 'string') {
				[Convert]::ToBase64String($ms.ToArray())
			}
			$ms.Close()
			#endregion Output CompressedData        
		}
	}
		
	# function to post analytics
	function Post_Analytics {
	# post client analytics 
	try
	{
		$payload = ([PSCustomObject]@{ 
		  hpcunit = $Unit      
		  events =  $Events
		});

		#Adding this for viewing json format of data
		$jsonOutput = $payload | ConvertTo-Json -Depth 5
		$json = $payload | ConvertTo-Json -Depth 5 -Compress
		#Compression Gzip
		$compressed = Compress-Data $json -As Byte
		#Encode the data
		$Base64 = [Convert]::ToBase64String($compressed)
		$partitionKey = [guid]::NewGuid().ToString() + "-w"
		$body =  ([PSCustomObject]@{ 
		  Data = $Base64      
		  PartitionKey =  $partitionKey
		});
		$postdata = $body | ConvertTo-Json -Depth 5;
		Invoke-WebRequest -Uri $clientAnalyticsUrl -UseBasicParsing -Method Put -Body $postdata -ContentType "application/json" | Out-Null		
		Out-File $logFile -Append -InputObject "Successfully posted analytics."
	}
    catch
	{		
		Out-File $logFile -Append -InputObject "Failed to post client analytics : $($_.Exception.Message)"           
	}
	}

	# Params
	$clientAnalyticsUrl ='https://9nki28cu03.execute-api.us-west-2.amazonaws.com/prod/w'	
	$UOID = '43c01865-a091-4ea9-adee-6ba5e69e291f'	

   # Prepare OS and device details for posting Client analytics
	$HPCmslInfo = (Get-HPCMSLEnvironment)
	$OSName = $HPCmslInfo.OsName
	$OSBuildNumber =$HPCmslInfo.OsBuildNumber
	$OSVersion =$HPCmslInfo.OsVersion
	$OSArchitecture = $HPCmslInfo.OSArchitecture	
	$OSDisplayVersion =$HPCmslInfo.OsVer	
	$PowerShellBitness = $HPCmslInfo.Bitness	
	$ProductId = $HPCmslInfo.CsSystemSKUNumber
	$SerialNumber = Get-HPDeviceSerialNumber
	$DeviceUUID = Get-HPDeviceUUID
	$CmslVersion =$local.version
	$SMBIOSVersion = Get-HPBIOSSettingValue -Name "System BIOS Version"	
	$PlatformName = Get-HPBIOSSettingValue -Name "Product Name"
	
	# get powershell version
	$PSVersion = $HPCmslInfo.PSVersion
	$Major = $PSVersion.Major
	$Minor = $PSVersion.Minor
	$Build = $PSVersion.Build
	$Revision = $PSVersion.Revision
	$PowershellVersion = ($Major,$Minor,$Build,$Revision) -Join "."
	
	# Get Unit details 
	$OS = Get-CimInstance -ClassName Win32_OperatingSystem
	$Culture = [System.Globalization.CultureInfo]::GetCultures("SpecificCultures") | Where {$_.LCID -eq $OS.OSLanguage}
	$RegionInfo = New-Object System.Globalization.RegionInfo $Culture.Name
	$CountryCode = $RegionInfo.TwoLetterISORegionName
	$OSLanguage =$OS.OSLanguage
	$OSDetail = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion")
	$OSReleaseId =$OSDetail.ReleaseId
	$UnitModel =Get-HPDeviceModel
	$HPProductID=Get-HPDeviceProductID
	$UnitPlatformID = Get-HPDeviceProductID

	#TODO Confirm below 2 param details :
	$UnitCollectionID =  [guid]::NewGuid()
	$SessionID = [guid]::NewGuid()

	# 2022-04-10T14:59:30-05:00
	$Date = (Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmss')
	$Version = "1.0"
	$Provider = "HP Connect"
	$ProviderVersion = "v1.0"
	$EventCategory = "Usage"
	$EventType = "Status"	

	$ReturnCodeDescription =""
	$ReturnCode = 0

	# initialize unit

	<#
	"V": "Version/1.0",
    "DT": "UTC DateTime/20230206T114825",
    "0": "Serial Number/5CD7255X1Z",
    "1": "Product ID/4AZ74EA",
    "2": "UUID (unique identifier for each device)/dc682c16-fed1-4f9a-9c2a-baa8e2634d3a",
    "3": "CountryCode/US",
    "4": "Provider/HP Connect",
    "5": "Provider version/v1.0",
    "6": "Unit model/HP Zbook 15 G6",
    "7": "Unit platform id/860F",
    "8": "UnitCollectionID/7E05B021-89D4-45B5-8DB7-C343A98C3145"
	#>

	$Unit =@{
        V =$Version
	    DT= $Date
	    "0" = $SerialNumber
		"1" = $ProductId
	    "2" = $DeviceUUID
	    "3" = $CountryCode
	    "4" = $Provider
	    "5" = $ProviderVersion
	    "6" = $UnitModel
	    "7" = $UnitPlatformID
	    "8" = $UnitCollectionID	
      }	


	<#
	 "app_hpconnect_client": {
        "TZ": "UTC DateTime/20230206T114825",
        "1": "UOID - Unique OrganizationID/Guid",
        "2": "OSVersion/10.0.19044",
        "3": "PowerShellVersion/5.1.19041.1320",
        "4": "CMSL Version/ 1.6.9.0",
        "5": "Platform name/HP Elite 1040",
        "6": "Powershellbitness/32",
        "7": "SMBIOSBIOSVersion/R92 Ver. 01.10.01",
        "9": "EventType /Status",
        "10": "ProductName/HP Connect",
        "11": "EventName/BIOS_Update_Detection_Script",
        "12": "CurrentState/Password",
        "13": "TargetState/SPM",
        "14": "FreezeStartDate/2023-02-06",
        "15": "FreezeEndDate/2023-02-16",
        "16": "ReturnCode/1",
        "17": "ReturnCodeDescription/Not compliant, failure due to ...",
        "18": "OSName/Microsoft Windows 10 Enterprise",
        "19": "OSBuildNumber/19044",
        "20": "OSArchitecture/64-bit",
        "21": "OSLanguage/1033",
        "22": "OSDisplayVersion/21H2",
        "23": "OSReleaseID/2009"
      }
	#>

	$EventDetails = New-Object -TypeName PsObject -Property @{
	     DT = $Date
		"1" = $UOID
		"2" = $OSVersion
		"3" = $PowershellVersion
		"4" = $CmslVersion
		"5" = $PlatformName
		"6" = $PowerShellBitness
		"7" = $SMBIOSVersion
		"8" = $EventCategory
		"9" = $EventType
		"10" = $Provider
		"11" = ""
		"12" = "N/A"
		"13" = "N/A"
		"14" = $freezeStartDate
		"15" = $freezeEndDate
		"16" = $ReturnCode
		"17" = $ReturnCodeDescription
		"18" = $OSName
		"19" = $OSBuildNumber
		"20" = $OSArchitecture		
		"21" = $OSLanguage
		"22" = $OSDisplayVersion
		"23" = $OSReleaseId
	}	

     # Process freeze rules (if any)
   [PolicyDiscovery]$Discovery =[PolicyDiscovery]::FreezeRulesDiscovery
   Out-File $logFile -Append -InputObject $Discovery
      

   # Replace this with combined & ordered discovery scripts from various policy types
   # Authentication policy script
   [PolicyDiscovery]$Discovery =[PolicyDiscovery]::BiosAuthenticationDiscovery
   Out-File $logFile -Append -InputObject $Discovery
   

   # BIOS setting policy scripts
   [PolicyDiscovery]$Discovery =[PolicyDiscovery]::BiosSettingsDiscovery
   Out-File $logFile -Append -InputObject $Discovery
   

   # BIOS update policy scripts
   [PolicyDiscovery]$Discovery =[PolicyDiscovery]::BiosUpdatesDiscovery
   Out-File $logFile -Append -InputObject $Discovery
       $UpdatesTable = @{'generic' = [pscustomobject]@{UpdateBehavior='LatestCritical';RebootType='Immediately';};}

    if ([System.String]::IsNullOrEmpty($UpdatesTable)) {
        throw "BIOS update table has not been defined properly"
    }

    # This parameter above must be replaced with the table containing the BIOS update policy content.
    # After being replaced, the table definition must have the following format:
    # $UpdatesTable = @{'<systemId>|<product name>|<biosFamily>]' = [pscustomobject]{'<UpdateBehavior>', '<TargetVersion>', '<Reboot>'}, ... }

    # Get the system board ID.
    [string]$systemId = Get-HPBIOSSettingValue -Name "System Board ID"

    # Get the product name.
    [string]$productName = Get-HPBIOSSettingValue -Name "Product Name"

    # Get the current BIOS version.
    [string]$biosVersionFull = Get-HPBIOSSettingValue -Name "System BIOS Version"
    [string]$currentVersion = Get-HPBIOSVersion
    $currentVersionInfo ="CurrentVersion_" + $currentVersion
    $targetVersionInfo = "N/A"

    # Get the current system BIOS family.
    [string]$biosFamily = $biosVersionFull.Substring(0, 3)

    Out-File $logFile -Append -InputObject "System board ID: $($systemId), BIOS family: $($biosFamily), product name: $($productName)"
    Out-File $logFile -Append -InputObject "Current BIOS version (full): $($biosVersionFull)"

    # Get the details of the BIOS update policy for this system ID and BIOS family.
    $selectedRecord = $UpdatesTable.GetEnumerator() | Where-Object -Property Name -Match "$($systemId)\|(.*)\|$($biosFamily)"

    if ($selectedRecord -eq $null)
    {
        Out-File $logFile -Append -InputObject "BIOS update policy not specified for this platform"
        $selectedRecord = $UpdatesTable.GetEnumerator() | Where-Object { $_.Key -eq "generic" }
        if ($selectedRecord -eq $null) {
            Out-File $logFile -Append -InputObject "Generic BIOS update policy not specified"
        }         
    }

    if ($selectedRecord) {
        # The object in the first found record should have the following fields: UpdateBehavior, TargetVersion, Reboot.
        Out-File $logFile -Append -InputObject "Selected BIOS update policy: '$($selectedRecord[0].Key)' = $($selectedRecord[0].Value)"
        $biosUpdatePolicy = $selectedRecord[0].Value

        # If the policy is Latest, check if the current version is the latest.
        [string]$updateBehavior = $biosUpdatePolicy.UpdateBehavior

        [string]$targetVersion = ""
        $targetVersion = $biosUpdatePolicy.TargetVersion
        $targetVersionInfo = $updateBehavior + "_" + $targetVersion
        Out-File $logFile -Append -InputObject "Target Version :  $($targetVersionInfo)"

        # Possible values of update behavior: Latest, LatestCritical, SpecificVersion
        # For the required update behavior in the policy, get the target BIOS update version.

        if ($updateBehavior -eq "SpecificVersion") {
            $targetVersion = $biosUpdatePolicy.TargetVersion
            $update = Get-HPBIOSWindowsUpdate -Family $biosFamily -Version $targetVersion
        }
        else {
            $update = Get-HPBIOSWindowsUpdate -Family $biosFamily -Severity $updateBehavior
            $targetVersion = $update.Version
        }        

        # If current BIOS version is lower than the target, then return not compliant.
        if ($targetVersion.Length -gt 0)
        {
            
            $targetVersionInfo = $updateBehavior + "_" + $targetVersion
            # Compare the versions, not the version strings.
            [System.Version]$targetVersionObject = [System.Version]$targetVersion
            [System.Version]$currentVersionObject = [System.Version]$currentVersion

            if ($currentVersionObject -lt $targetVersionObject)
            {      
                throw "The current bios version [$($currentVersion)] is older than the $($updateBehavior) [$($targetVersion)], return NOT compliant"
            }
        }
    }

    Out-File $logFile -Append -InputObject "BIOS update policy is compliant"



   # Post Analytics with compliance detection details   
   [PolicyDiscovery]$Discovery =[PolicyDiscovery]::AllPoliciesCompliant  
   Out-File $logFile -Append -InputObject $Discovery
   ClientDetection($exception)
   Write-Output ""
   exit 0 # intune health script , 0 means success 1 means failure
}
catch{

   # Post Analytics with non-compliance detection details   
   Out-File $logFile -Append -InputObject $_.Exception.Message
   $exception = $_.Exception.Message
   $exception
   ClientDetection($exception)
   throw
}

