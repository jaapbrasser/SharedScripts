<#
.SYNOPSIS   
Function that shows the contents of the Recycle Bin

.DESCRIPTION 
This function is intended to compliment the Clear-RecycleBin cmdlet, which does not provide any functionality to view the files that are stored in the Recycle-Bin

.NOTES   
Name: Get-RecycleBin
Author: Jaap Brasser
DateCreated: 2015-09-24
DateUpdated: 2015-09-24
Version: 1.0
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Get-RecycleBin.ps1

Description
-----------
This command dot sources the script to ensure the Get-RecycleBin function is available in your current PowerShell session

.EXAMPLE
Get-RecycleBin

Description
-----------
Executing this function will display the name, size and path of the files stored in the Recycle Bin for the current user
#>
function Get-RecycleBin {
    (New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() |
	Select-Object Name,Size,Path
}