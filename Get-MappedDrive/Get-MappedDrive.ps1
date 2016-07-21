Function Get-MappedDrive {
<#
.SYNOPSIS   
This function will return the mapped network drives
    
.DESCRIPTION 
This function requires PowerShell 2.0 and utilizes the Wscript.Network COM object to enumerate the
locally mapped network drives. The output of the Wscipt.Network COM object is a collection of strings.
This function takes those strings and converts it into objects.

.NOTES   
Name:        Get-MappedDrive
Author:      Jaap Brasser
DateCreated: 2014-07-22
Version:     1.0
DateUpdated: -

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
Get-MappedDrive

Description 
-----------     
Returns the mapped network drives as objects. The output is separated in two properties: LocalPath and NetworkPath.
#>
    (New-Object -ComObject WScript.Network).EnumNetworkDrives() | ForEach-Object -Begin {
        $CreateObject = $false
    } -Process {
        if ($CreateObject) {
            $HashProps.NetworkPath = $_
            New-Object -TypeName PSCustomObject -Property $HashProps
            $CreateObject = $false
        } else {
            $HashProps = @{
                LocalPath = $_
            }
            $CreateObject =$true
        }
    }
}