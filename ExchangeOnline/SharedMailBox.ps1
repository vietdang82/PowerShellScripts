Set-remoteMailbox @alias -EmailAddressPolicyEnabled $false -EmailAddress @{add="$upn"}
Set-remoteMailbox @alias -PrimarySmtpAddress "$upn"

write-Host "Mailbox successfully created" -ForegroundColor Black -BackgroundColor White
Write-Host "Getting Exchange details" -ForegroundColor Black -BackgroundColor White
get-remoteMailbox -identity $alias | Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails

#Give users the chance to run a AAD Sync
Write-Host ""
Write-Host "Please manually run AAD sync to O365." -ForegroundColor Black -BackgroundColor White
Read-Host -prompt "Press enter to continue"
Write-Host "Giving it sometime to Sync" -ForegroundColor Black -BackgroundColor White
Start-Sleep -s 4
Write-Host "." -noNewline
Start-Sleep -s 4
Write-Host "." -noNewline
Start-Sleep -s 4
Write-Host "." -noNewline
Start-Sleep -s 3
Write-Host "." -noNewline

Connect-ExchangeOnline -ShowProgress $true -ConnectionUri https://outlook.office365.com/PowerShell-LiveID -AzureADAuthorizationEndpointUri https://login.microsoft.com/common

Set-Mailbpo $upn -Type Shared