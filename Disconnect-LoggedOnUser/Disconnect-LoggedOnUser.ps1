function Disconnect-LoggedOnUser {
<#
.SYNOPSIS   
Function to disconnect a RDP session remotely
    
.DESCRIPTION 
This function provides the functionality to disconnect a RDP session remotely by providing the ComputerName and the SessionId
	
.PARAMETER ComputerName
This can be a single computername or an array where the RDP sessions will be disconnected

.PARAMETER Id
The Session Id that that will be disconnected

.NOTES   
Name: Disconnect-LoggedOnUser
Author: Jaap Brasser
DateUpdated: 2015-06-03
Version: 1.0
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
. .\Disconnect-LoggedOnUser.ps1
    
Description 
-----------     
This command dot sources the script to ensure the Disconnect-LoggedOnUser function is available in your current PowerShell session

.EXAMPLE
Disconnect-LoggedOnUser -ComputerName server01 -Id 5

Description
-----------
Disconnect session id 5 on server01

.EXAMPLE
.\Get-LoggedOnUser.ps1 -ComputerName server01,server02 | Where-Object {$_.UserName -eq 'JaapBrasser'} | Disconnect-LoggedOnUser -Verbose

Description
-----------
Use the Get-LoggedOnUser script to gather the user sessions on server01 and server02. Where-Object filters out only the JaapBrasser user account and then disconnects the session by piping the results into Disconnect-LoggedOnUser while displaying verbose information.
#>
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position=0
        )]
        [string[]]
            $ComputerName,
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [int[]]
            $Id
    )

    begin {
        $OldEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
    }

    process {
        foreach ($Computer in $ComputerName) {
            $Id | ForEach-Object {
                Write-Verbose "Attempting to disconnect session $Id on $Computer"
                try {
                    rwinsta $_ /server:$Computer
                    Write-Verbose "Session $Id on $Computer successfully disconnected"
                } catch {
                    Write-Verbose 'Error disconnecting session displaying message'
                    Write-Warning "Error on $Computer, $($_.Exception.Message)"
                }
            }
        }
    }

    end {
        $ErrorActionPreference = $OldEAP
    }
}