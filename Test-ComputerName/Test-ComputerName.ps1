<#
.Synopsis
Check connectivity of a system

.DESCRIPTION
This function pings and opens a connection to the default RDP port to verify connectivity, futhermore it will check if a DNS entry exists and whether there is a computeraccount

.NOTES   
Name: Test-ComputerName
Author: Jaap Brasser
Version: 1.0
DateUpdated: 2013-08-23

.LINK
http://www.jaapbrasser.com

.PARAMETER ComputerName
The computer to which connectivity will be checked

.EXAMPLE
Test-ComputerName

Description:
Will perform the ping, RDP, DNS and AD checks for the local machine

.EXAMPLE
Test-ComputerName -ComputerName server01,server02

Description:
Will perform the ping, RDP, DNS and AD checks for server01 and server02
#>
Function Test-ComputerName {
    param (
        [CmdletBinding()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    begin {
        $SelectHash = @{
         'Property' = @('Name','ADObject','DNSEntry','PingResponse','RDPConnection')
        }
    }

    process {
        foreach ($CurrentComputer in $ComputerName) {
            # Create new Hash
            $HashProps = @{
                'Name' = $CurrentComputer
                'ADObject' = $false
                'DNSEntry' = $false
                'RDPConnection' = $false
                'PingResponse' = $false
            }
        
            # Perform Checks
            switch ($true)
            {
                {([adsisearcher]"samaccountname=$CurrentComputer`$").findone()} {$HashProps.ADObject = $true}
                {$(try {[system.net.dns]::gethostentry($CurrentComputer)} catch {})} {$HashProps.DNSEntry = $true}
                {$(try {$socket = New-Object Net.Sockets.TcpClient($CurrentComputer, 3389);if ($socket.Connected) {$true};$socket.Close()} catch {})} {$HashProps.RDPConnection = $true}
                {Test-Connection -ComputerName $CurrentComputer -Quiet -Count 1} {$HashProps.PingResponse = $true}
                Default {}
            }

            # Output object
            New-Object -TypeName 'PSCustomObject' -Property $HashProps | Select-Object @SelectHash
        }
    }

    end {
    }
}