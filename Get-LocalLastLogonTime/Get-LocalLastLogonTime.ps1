function Get-LocalLastLogonTime {
<#   
.SYNOPSIS   
Will check local or remote system for the LastLogin of a certain account

.DESCRIPTION 
This script utilizes the WinNT provider to connect to either a local or remote system to establish if and when a user account last logged on that system. If the user is not found or the system does not respond an error will be logged. The function will attempt to output the date as a DateTime object, but if the conversion fails the time will be output as provided by the WinNT provider.

.PARAMETER ComputerName
This can be a single computer name or an array of computer names which will checked for the single user name or list of user names

.PARAMETER UserName
This can be a single user name or an array of user names which will checked for the LastLogin property on the computers specified in the ComputerName parameter

.NOTES   
Name: Get-LocalLastLogonTime
Author: Jaap Brasser
DateUpdated: 2015-06-01
Version: 1.0
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Get-LocalLastLogonTime.ps1

Description
-----------
This command dot sources the script to ensure the Get-LocalLastLogonTime function is available in your current PowerShell session

.EXAMPLE
Get-LocalLastLogonTime -ComputerName localhost -UserName user1,JaapBrasser,administrator

Description
-----------
Will check the system for the LastLogin properties of user1, JaapBrasser and the administrator account.

.EXAMPLE
PowerShell.exe -Command "& {. C:\Scripts\Get-LocalLastLogonTime.ps1; Get-LocalLastLogonTime -ComputerName server1,server2 -UserName JaapBrasser,administrator}"

Description
-----------
Will check server1 and server2 for the LastLogin time of JaapBrasser and administrator. This example is useful for scenarios when scheduling tasks or when executing this PowerShell script from batch files.
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
            Mandatory
    )]
    [string[]]
        $UserName
    )



    begin {
        $SelectSplat = @{
            Property = @('ComputerName','UserName','LastLogin','Error')
        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                foreach ($User in $UserName) {
                    $ObjectSplat = @{
                        ComputerName = $Computer
                        UserName = $User
                        Error = $null
                        LastLogin = $null
                    }
                    $CurrentUser = $null
                    $CurrentUser = try {([ADSI]"WinNT://$computer/$user")} catch {}
                    if ($CurrentUser.Properties.LastLogin) {
                        $ObjectSplat.LastLogin = try {
                                            [datetime](-join $CurrentUser.Properties.LastLogin)
                                        } catch {
                                            -join $CurrentUser.Properties.LastLogin
                                        }
                    } elseif ($CurrentUser.Properties.Name) {
                    } else {
                        $ObjectSplat.Error = 'User not found'
                    }
                    New-Object -TypeName PSCustomObject -Property $ObjectSplat | Select-Object @SelectSplat
                }
            } else {
                $ObjectSplat = @{
                    ComputerName = $Computer
                    Error = 'Ping failed'
                }
                New-Object -TypeName PSCustomObject -Property $ObjectSplat | Select-Object @SelectSplat
            }
        }
    }
}