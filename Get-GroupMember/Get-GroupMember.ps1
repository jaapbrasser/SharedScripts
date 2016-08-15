function Get-GroupMember {
<#
.SYNOPSIS   
Retrieves the members of a local group
    
.DESCRIPTION 
The script can use a remote of local ComputerName as input and will list the group members

.PARAMETER ComputerName
The name of the computer(s) that will be queried their respective group members
	
.PARAMETER LocalGroup
The name of the local group

.NOTES   
Name       : Get-GroupMember.ps1
Author     : Jaap Brasser
Version    : 1.0.1
DateCreated: 2016-08-02
DateUpdated: 2016-08-15

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Get-GroupMember.ps1

Description
-----------
This command dot sources the script to ensure the Get-GroupMember function is available in your current PowerShell session

.EXAMPLE   
Get-GroupMember Administrators

Description
-----------
Gets the group members of the Administrators group on the local system

.EXAMPLE   
Get-GroupMember -ComputerName 'Server01','Server02' -LocalGroup Administrators

Description
-----------
Gets the group members of the Administrators group on both Server01 and Server02

.EXAMPLE   
Get-GroupMember -ComputerName 'Server01','Server02' -LocalGroup Administrators,Users

Description
-----------
Gets the group members of the Administrators and the Users groups on both Server01 and Server02
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Group')]
        [string[]]
            $LocalGroup,
        [Alias('CN','Computer')]
        [string[]]
            $ComputerName = '.'
    )

    foreach ($Computer in $ComputerName) {
        Write-Verbose "Checking membership of localgroup: '$LocalGroup' on $Computer"
	    try {
            foreach ($Group in $LocalGroup) {
                ([adsi]"WinNT://$Computer/$Group,group").psbase.Invoke('Members') | ForEach-Object {
                    New-Object -TypeName PSCustomObject -Property @{
                        ComputerName = $Computer
                        LocalGroup   = $Group
                        Member       = $_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null)
                    }
                }
                Write-Verbose "Successfully checked membership of local group: '$LocalGroup' on $Computer"
            }
	    } catch {
		    Write-Warning $_
	    }
    }	
}