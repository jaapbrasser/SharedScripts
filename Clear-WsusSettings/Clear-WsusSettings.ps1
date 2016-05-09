function Clear-WsusSettings {
<#
.SYNOPSIS   
Clears the Wsus settings from the registry
    
.DESCRIPTION 
This function removes several values regarding WSUS from the registry, temporarily allowing a local administrative users to download patches from Microsoft Update instead of the regularly defined WSUS server. If group policies are setup for this machine the WSUS settings might be reapplied depending on the GPO configuration.
	
.NOTES   
Name       : Clear-WsusSettings
Author     : Jaap Brasser
Version    : 1.0.0
DateCreated: 2016-05-09
DateCreated: 2016-05-09
Blog       : http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Clear-WsusSettings.ps1

Description
-----------
This command dot sources the script to ensure the Clear-WsusSettings function is available in your current PowerShell session

.EXAMPLE   
Clear-WsusSettings

Description
-----------
Will purge the defined registry settings in the WindowsUpdate key

.EXAMPLE   
Clear-WsusSettings -WhatIf

Description
-----------
Will display which changes will be made in the registry without actually making any changes
#>
    [cmdletbinding(SupportsShouldProcess=$true)]
    param ()
    $ErrorActionPreference = 'SilentlyContinue'
    Remove-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -Force -Name WUServer
    Remove-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -Force -Name TargetGroup
    Remove-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -Force -Name WUStatusServer
    Remove-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate' -Force -Name TargetGroupEnable
    Set-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -Value 0 -Force -Name UseWUServer
    Set-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' -Value 0 -Force -Name NoAutoUpdate
    Set-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate'    -Value 0 -force -Name DisableWindowsUpdateAccess
    Restart-Service -Name wuauserv
}