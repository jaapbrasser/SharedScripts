function Set-StorageSense {
<#
.SYNOPSIS
Configures the Storage Sense options in Windows 10

.DESCRIPTION 
This function can configure Storage Sense options in Windows 10. It allows to enable/disable this feature

.PARAMETER EnableStorageSense
Enables storage sense setting, automatically cleaning up space on your system

.PARAMETER DisableStorageSense
Disables storage sense setting, not automatically cleaning up space on your system

.PARAMETER RemoveAppFiles
Configures the 'Delete temporary files that my apps aren't using' to either true or false

.PARAMETER ClearRecycleBin
Configures the 'Delete files that have been in the recycle bin for over 30 days' to either true or false

.NOTES   
Name:        Set-StorageSense
Author:      Jaap Brasser
DateCreated: 2017-01-26
DateUpdated: 2017-01-26
Version:     1.0.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
Set-StorageSense -DisableStorageSense

Description
-----------
Disables Storage Sense on the system

.EXAMPLE   
Set-StorageSense -EnableStorageSense -RemoveAppFiles $true

Description
-----------
Enables Storage Sense on the system and sets the 'Delete temporary files that my apps aren't using' to enabled

.EXAMPLE   
Set-StorageSense -DisableStorageSense -RemoveAppFiles $true -ClearRecycleBin $true -Verbose

Description
-----------
Disables Storage Sense on the system and sets both the 'Delete temporary files that my apps aren't using' and the 'Delete files that have been in the recycle bin for over 30 days' to enabled
#>    
    [cmdletbinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='StorageSense On'
        )]
        [switch] $EnableStorageSense,
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='StorageSense Off'
        )]
        [switch] $DisableStorageSense,
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='Configure StorageSense'
        )]
        [bool] $RemoveAppFiles,
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='Configure StorageSense'
        )]
        [bool] $ClearRecycleBin
    )

    begin {
        $RegPath = @{
            StorageSense = '01'
            TemporaryApp = '04'
            RecycleBin   = '08'
        }
        $SetRegistrySplat = @{
            Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\'
            Name  = $null
            Value = $null
        }
        function Set-RegistryValue {
            param(
                [string] $Path,
                [string] $Name,
                [string] $Value
            )
            if (-not (Test-Path -Path $Path)) {
                if ($PSCmdlet.ShouldProcess("$Path$Name : $Value",'Creating registry key')) {
                    $null = New-Item -Path $Path -Force
                }
            }
        
            if ($PSCmdlet.ShouldProcess("$Path$Name : $Value",'Updating registry value'))   {
                $null = Set-ItemProperty @PSBoundParameters -Force
            }
        }
    }

    process {
        switch (1) {
            {$PsCmdlet.ParameterSetName -eq 'StorageSense On'}    {
                $SetRegistrySplat.Name  = $RegPath.StorageSense
                $SetRegistrySplat.Value = 1
                Set-RegistryValue @SetRegistrySplat
            }
            {$PsCmdlet.ParameterSetName -eq 'StorageSense Off'}   {
                $SetRegistrySplat.Name  = $RegPath.StorageSense
                $SetRegistrySplat.Value = 0
                Set-RegistryValue @SetRegistrySplat
            }
            {$PSBoundparameters.Keys -contains 'RemoveAppFiles'}  {
                $SetRegistrySplat.Name  = $RegPath.TemporaryApp
                $SetRegistrySplat.Value = [int]$RemoveAppFiles
                Set-RegistryValue @SetRegistrySplat
            }
            {$PSBoundparameters.Keys -contains 'ClearRecycleBin'} {
                $SetRegistrySplat.Name  = $RegPath.RecycleBin
                $SetRegistrySplat.Value = [int]$ClearRecycleBin
                Set-RegistryValue @SetRegistrySplat
            }
        }
    }
}