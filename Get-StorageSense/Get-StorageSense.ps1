function Get-StorageSense {
<#
.SYNOPSIS
Retrieves Storage Sense options in Windows 10

.DESCRIPTION 
This function can retrieve Storage Sense options in Windows 10

.NOTES   
Name:        Get-StorageSense
Author:      Jaap Brasser
DateCreated: 2017-01-26
DateUpdated: 2017-01-26
Version:     1.0.0
Blog:        https://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
Get-StorageSense

Description
-----------
Retrieves all storage sense configuration and recently cleaned data from the current system
#>    
    $ErrorActionPreference = 'SilentlyContinue'
    $HashProperties = [ordered]@{
        StorageSenseEnabled    = (Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\' -Name 01) -as [bool]
        RemoveAppFilesEnabled  = (Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\' -Name 04) -as [bool]
        ClearRecycleBinEnabled = (Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\' -Name 08) -as [bool]
    }

    if (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\SpaceHistory') {
        $HashProperties.SpaceHistory = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\SpaceHistory').psbase.properties |
        Where-Object {$_.Name -match '\d{8}'} | ForEach-Object {
            [pscustomobject]@{
                Date             = [datetime]::ParseExact($_.Name,'yyyyMMdd',$null)
                StorageCleanedGB = [math]::Round(($_.Value / 1GB * 1000000),2)
            }
        }
    }

    [pscustomobject]$HashProperties
}
