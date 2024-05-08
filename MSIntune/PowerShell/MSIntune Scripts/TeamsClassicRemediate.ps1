function Uninstall-TeamsClassic($TeamsPath) {
    try {
        $process = Start-Process -FilePath "$TeamsPath\Update.exe" -ArgumentList "--uninstall /s" -PassThru -Wait -ErrorAction STOP

        if ($process.ExitCode -ne 0) {
            Write-Error "Uninstallation failed with exit code $($process.ExitCode)."
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

# Remove Teams Machine-Wide Installer
Write-Host "Removing Teams Machine-wide Installer"
## Get all subkeys and match the subkey that contains "Teams Machine-Wide Installer" DisplayName.
$MachineWide = Get-ItemProperty -Path $registryPath | Where-Object -Property DisplayName -eq "Teams Machine-Wide Installer"

if ($MachineWide) {
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/x ""$($MachineWide.PSChildName)"" /qn" -NoNewWindow -Wait
}
else {
    Write-Host "Teams Machine-Wide Installer not found"
}

# Get all Users
$AllUsers = Get-ChildItem -Path "$($ENV:SystemDrive)\Users"

# Process all Users
foreach ($User in $AllUsers) {
    Write-Host "Processing user: $($User.Name)"

    # Locate installation folder
    $localAppData = "$($ENV:SystemDrive)\Users\$($User.Name)\AppData\Local\Microsoft\Teams"
    $programData = "$($env:ProgramData)\$($User.Name)\Microsoft\Teams"

    if (Test-Path "$localAppData\Current\Teams.exe") {
        Write-Host "  Uninstall Teams for user $($User.Name)"
        Uninstall-TeamsClassic -TeamsPath $localAppData
    }
    elseif (Test-Path "$programData\Current\Teams.exe") {
        Write-Host "  Uninstall Teams for user $($User.Name)"
        Uninstall-TeamsClassic -TeamsPath $programData
    }
    else {
        Write-Host "  Teams installation not found for user $($User.Name)"
    }
}

# Remove old Teams folders and icons
$TeamsFolder_old = "$($ENV:SystemDrive)\Users\*\AppData\Local\Microsoft\Teams"
$TeamsIcon_old = "$($ENV:SystemDrive)\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Microsoft Teams*.lnk"
Get-Item $TeamsFolder_old | Remove-Item -Force -Recurse
Get-Item $TeamsIcon_old | Remove-Item -Force -Recurse