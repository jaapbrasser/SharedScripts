function Get-OUwithGPOLink {
<#  
.SYNOPSIS   
Function that enchances the output of Get-ADOrganizationalUnit with human readable GPO names
    
.DESCRIPTION 
This function requires PowerShell v2 with the ActiveDirectory module. This function is written as
an extensions to the functionality of Get-ADOrganizationUnit and adds an additional property
'FriendlyGPODisplayName' which can be used to identify which GPOs are attached to an OU
	
.PARAMETER Name 
This can either be a string or an array of strings that the funtion will query for. Wildcards are
allowed.

.NOTES   
Name:        Get-OUWithGPOLink
Author:      Jaap Brasser
DateCreated: 2014-07-20
Version:     1.0
DateUpdated: -

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
Get-OUWithGPOLink

Description 
-----------     
Will returns all OUs

.EXAMPLE
'Domain*','Computers' | Get-OUWithGPOLink

Description
-----------
Will search for all OUs matching the Domain* name and an OU named Computers
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [Parameter( ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        $Name
    )
    Begin {
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
        } catch {
            Throw "Active Directory module could not be loaded. $($_.Exception.Message)"
        }
    } Process {
        $Name | ForEach-Object {
            Get-ADOrganizationalUnit -Filter "Name -like `'$_`'" -Properties name,distinguishedName,gpLink |
            Select-Object -Property *,@{
                label = 'FriendlyGPODisplayName'
                expression = {
                    $_.LinkedGroupPolicyObjects | ForEach-Object {
                        -join ([adsi]"LDAP://$_").displayName
                    }
                }
            }
        }
    }
}