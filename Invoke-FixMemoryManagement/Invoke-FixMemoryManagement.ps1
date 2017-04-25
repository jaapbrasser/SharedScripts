function Invoke-FixMemoryManagement {
<#
.Synopsis
Check and fix PoolUsageMemory registry value

.DESCRIPTION
This function checks the value of PoolUsageMaximum in the registry, if it is higher than the PoolUsageMaximum parameter it will be set to 60

.NOTES   
Name        : Invoke-FixMemoryManagement
Author      : Jaap Brasser
Version     : 1.0
DateCreated : 2017-04-25
DateUpdated : 2017-04-25
Blog        : http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.PARAMETER ComputerName
The computer to which will be connected

.EXAMPLE
.\Invoke-FixMemoryManagement.ps1

Description
Dot source the function to memory of the current PowerShell session

.EXAMPLE
Invoke-FixMemoryManagement -PoolUsageMaximum 70 -Verbose

Description
Checks if PoolUsageMaximum is set to 70 or higher, if that is the case it will set it to 60 on the local system

.EXAMPLE
Invoke-FixMemoryManagement -ComputerName server01,server02

Description
Checks if PoolUsageMaximum is set to default value 70 or higher, if that is the case it will set it to 60 for server01 and 02
#>


    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(ValueFromPipeline               = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position                        = 0
        )]
        [string[]] $ComputerName = $env:COMPUTERNAME,
        
        [Parameter(
                   Position                        = 1
        )]
        [int]      $PoolUsageMaximum = 80
    )

    begin {
        $RegistryLocation = 'System\CurrentControlSet\Control\Session Manager\Memory Management\'
        $SelectProperty   = @{
            Property      = @('ComputerName','PoolUsageMaximum','Changed')
        }
    }

    process {
        foreach ($Computer in $ComputerName) {
            $HashProperty     = @{
                ComputerName     = $Computer
                PoolUsageMaximum = $null
                Changed          = $false
            }
            $RegBase = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
            if ($RegBase) {
                $CurrentRegKey = $RegBase.OpenSubKey($RegistryLocation,$true)
                if ($CurrentRegKey) {
                    $HashProperty.PoolUsageMaximum = $CurrentRegKey.GetValue('PoolUsageMaximum')
                    if ($HashProperty.PoolUsageMaximum -ge $PoolUsageMaximum) {
                        if ($PSCmdlet.ShouldProcess($Computer,('Setting PoolUsageMaximum to: 60'))) {
                            $CurrentRegKey.SetValue('PoolUsageMaximum',60,[Microsoft.Win32.RegistryValueKind]::DWord)
                            $HashProperty.Changed  = $true
                        }
                    }
                }get-
            }

            New-Object -TypeName PSCustomObject -Property $HashProperty |
            Select-Object @SelectProperty
        }
    }
}