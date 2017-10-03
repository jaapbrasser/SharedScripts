function Get-WifiProfilePassword {
<#
.SYNOPSIS
Retrieves one or all wifi passwords

.DESCRIPTION 
Uses netsh to retrieve all wifi profiles and then extract the corrosponding passwords

.PARAMETER WifiProfile
The name of the network profile to be retrieved, by default all profiles are retrieved

.NOTES
Name:        Get-WifiProfilePassword
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
Retrieves all the wifi passwords for each saved network on this system

.EXAMPLE
"Wifi Profile 1","Jaap's wifi" | Get-WifiProfilePassword

Description
-----------
Retrieves the wifi passwords for "Wifi Profile 1" and "Jaap's wifi" by using pipelining

.EXAMPLE
Get-WifiProfilePassword -WifiProfile "Wifi Profile 1","Jaap's wifi"

Description
-----------
Retrieves the wifi passwords for "Wifi Profile 1" and "Jaap's wifi"
#>


    param(
        [Parameter(
            Mandatory         = $false,
            ValueFromPipeline = $true
        )]
        [string[]] $WifiProfile
    )

    begin {
        if (-not (Get-Command -Name netsh.exe -CommandType Application -ErrorAction SilentlyContinue)) {
            throw 'Netsh not found on this system, script terminated'
        }
    }

    process {
        if ($WifiProfile) {
            foreach ($CurrentWifi in $WifiProfile) {
                $Hash = [ordered]@{
                    WifiName = $CurrentWifi
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