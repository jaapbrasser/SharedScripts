function Clear-RecycleBin {
<#
.SYNOPSIS   
Function that clears the contents of the Recycle Bin

.DESCRIPTION 
This function is intended for older systems on which Clear-RecycleBin is not available

.NOTES   
Name       : Get-RecycleBin
Author     : Jaap Brasser
DateCreated: 2017-01-12
DateUpdated: 2017-01-12
Version    : 1.0
Blog       : https://www.jaapbrasser.com

.LINK
https://www.jaapbrasser.com

.EXAMPLE
. .\Clear-RecycleBin.ps1

Description
-----------
This command dot sources the script to ensure the Clear-RecycleBin function is available in your current PowerShell session

.EXAMPLE
Clear-RecycleBin

Description
-----------
Will remove the files and folders in the Recycle Bin for the current user
#>
    [cmdletbinding(SupportsShouldProcess=$true)]
    param()
    (New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() | ForEach-Object {
        Remove-Item -LiteralPath $_.Path -Force -Recurse
    }
}
