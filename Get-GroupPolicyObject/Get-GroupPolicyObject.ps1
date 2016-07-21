<#
.Synopsis
Queries AD for Group Policy objects

.DESCRIPTION
This script uses the DirectoryServices.DirectorySearcher object to get all or a selection of Group Policy Objects.

.NOTES   
Name: Get-GroupPolicyObject.ps1
Author: Jaap Brasser
Version: 1.0
DateCreated: 2013-07-30
DateUpdated: 2013-07-30

.LINK
http://www.jaapbrasser.com

.PARAMETER DisplayName
Optional parameter that contains a LDAP search filter for the displayname property of the group policy objects. Wildcards are allowed.

.EXAMPLE
.\Get-GroupPolicyObject.ps1

Description:
Will display all group policy objects.

.EXAMPLE
.\Get-GroupPolicyObject.ps1 -DisplayName Default*

Description:
Will displays the group policy objects which displaynames start with Default
#>
param(
    [Parameter()]
    [string]$DisplayName
)

# Defining the parameters for the AD Query
$GPOSearcher = New-Object DirectoryServices.DirectorySearcher -Property @{
    Filter = '(objectClass=groupPolicyContainer)'
    PageSize = 100
}

# If the DisplayName parameter is specified, then update the LDAP Search filter
if ($DisplayName) {
    $GPOSearcher.Filter = "(&(objectClass=groupPolicyContainer)(displayname=$DisplayName))"
}

# Execute query and output as custom objects
$GPOSearcher.FindAll() | ForEach-Object {
    New-Object -TypeName PSCustomObject -Property @{
        'DisplayName' = $_.properties.displayname -join ''
        'DistinguishedName' = $_.properties.distinguishedname -join ''
        'CommonName' = $_.properties.cn -join ''
        'FilePath' = $_.properties.gpcfilesyspath -join ''
    } | Select-Object -Property DisplayName,CommonName,FilePath,DistinguishedName
}