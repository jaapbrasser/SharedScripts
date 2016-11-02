<#   
.SYNOPSIS   
Active Directory Script that queries for user accounts that have unchanged passwords for the past 90 days
    
.DESCRIPTION 
This script will return the samaccountname, pwdlastset and if an account is currently enabled or disabled. This script is part of the Active Directory Friday section of my blog.

.NOTES   
Name:        Get-UnchangedPwdLastSet.ps1
Author:      Jaap Brasser
Version:     1.0.0
DateCreated: 2013-07-26
DateUpdated: 2016-11-02
Site:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com/active-directory-friday-find-user-accounts-that-have-not-changed-password-in-90-days/

.PARAMETER PwdAge
The number of days since the password has been changed. This value defaults to 90

.PARAMETER SearchBase
The LDAP path of the OU that you would like to limit the search to

.EXAMPLE
.\Get-UnchangedPwdLastSet.ps1

Description
-----------
Returns the users that have unchanged passwords for longer than 90 days

.EXAMPLE
.\Get-UnchangedPwdLastSet.ps1 -PwdAge 180 -SearchBase 'LDAP://OU=Business,DC=jaapbrasser,DC=com'

Description
-----------
Returns the users with unchanged passwords for longer than 180 in the Business OU. This is a recursive search
#>
param (
    [int]    $PwdAge = 90,
    [ValidatePattern('(?# OU Path should start with "LDAP://")^LDAP://.*')]
    [string] $SearchBase
)
$PwdDate = (Get-Date).AddDays(-$PwdAge).ToFileTime()

$SearcherProps = @{
    Filter   = "(&(objectclass=user)(objectcategory=person)(pwdlastset<=$PwdDate))"
    PageSize = 500
}

if ($SearchBase) {
    $SearcherProps.SearchRoot = $SearchBase
}

(New-Object DirectoryServices.DirectorySearcher -Property $SearcherProps).FindAll() | ForEach-Object {
    New-Object -TypeName PSCustomObject -Property @{
        samaccountname = $_.Properties.samaccountname -join ''
        pwdlastset     = [datetime]::FromFileTime([long](-join $_.Properties.pwdlastset))
        enabled        = -not [bool]([long](-join $_.properties.useraccountcontrol) -band 2)
    }
}