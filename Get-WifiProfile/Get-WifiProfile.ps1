function Get-WifiProfilePassword {
<#
.SYNOPSIS
Retrieves one or all wifi passwords

.DESCRIPTION 
Uses netsh to retrieve all wifi profiles and then extract the corrosponding passwords

.PARAMETER WifiProfile
The name of the network profile to be retrieved, by default all profiles are retrieved

.NOTES
Name:        New-ZeroFile
Author:      Jaap Brasser
DateCreated: 2017-10-01
DateUpdated: 2017-10-03
Version:     1.0.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
Get-WifiProfilePassword

Description
-----------
Retrieves all the passwords and profiles
#>


    param(
        [string[]] $WifiProfile
    )

    process {
        if ($WifiProfile) {
            foreach ($CurrentWifi in $WifiProfile) {
                $Hash = [ordered]@{
                    WifiName = ($_ -split '\:',2)[1].Trim()
                }
                $Hash.Password = (-join ((netsh wlan show profile "$($Hash.WifiName)" key=clear) -match 'key c')) -replace '\s*Key Content\s+: '
    
                [pscustomobject]$Hash
            }
        } else {
            (netsh wlan show profile) -match ' : ' | ForEach-Object {
                $Hash = [ordered]@{
                    WifiName = ($_ -split '\:',2)[1].Trim()
                }
                $Hash.Password = (-join ((netsh wlan show profile "$($Hash.WifiName)" key=clear) -match 'key c')) -replace '\s*Key Content\s+: '

                [pscustomobject]$Hash
            } | Sort-Object -Property WifiName
        }
    }
}