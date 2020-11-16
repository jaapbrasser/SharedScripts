function Get-TypeAccelerator {
<#
.SYNOPSIS
Display all available PowerShell type accelerators
.DESCRIPTION
Display all available PowerShell type accelerators, sorted alphabetically
.EXAMPLE
Get-TypeAccelerator

Returns all available PowerShell type accelerators:
```
Key                          Value
---                          -----
adsi                         System.DirectoryServices.DirectoryEntry
adsisearcher                 System.DirectoryServices.DirectorySearcher...
```
#>
    [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::Get.GetEnumerator() | Sort-Object -Property Key
}