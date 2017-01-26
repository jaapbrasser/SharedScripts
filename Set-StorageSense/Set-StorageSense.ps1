function Set-StorageSense {
<#
.SYNOPSIS
Configures the Storage Sense options in Windows 10

.DESCRIPTION 
This function can configure Storage Sense options in Windows 10. It allows to enable/disable this feature

.PARAMETER DisableBlueLight
Disables blue light setting, restoring the colors to regular colors

.PARAMETER EnableBlueLight
Enables blue light setting, lowering blue light emitted

.PARAMETER DisableAutomaticSchedule
Disables automatic day-night schedule based on geographical location

.PARAMETER EnableAutomaticSchedule
Enables automatic day-night schedule based on geographical location

.PARAMETER ColorTemperature
Defines the color temperature of the blue light settings

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
Set-BlueLight -DisableBlueLight

Description
-----------
Disables reduced blue light and restores colors to default

.EXAMPLE   
Set-BlueLight -EnableBlueLight -ColorTemperature MediumShift

Description
-----------
Enables reduced blue light and sets colors to the half way point on the color temperature slider

.EXAMPLE   
Set-BlueLight -EnableAutomaticSchedule

Description
-----------
Enables automatic day-night schedule based on geographical location
#>    
    [cmdletbinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='StorageSense On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin Off'
        )]
        [switch] $DisableStorageSense,
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='StorageSense Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin Off'
        )]
        [switch] $EnableStorageSense,

        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense On'
        )]
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='RemoveAppFiles On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin Off'
        )]
        [switch] $EnableRemoveAppFiles,
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense On'
        )]
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='RemoveAppFiles Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='ClearRecycleBin Off'
        )]
        [switch] $DisableRemoveAppFiles,
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles Off'
        )]
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='ClearRecycleBin On'
        )]
        [switch] $EnableClearRecycleBin,
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='StorageSense On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='RemoveAppFiles Off'
        )]
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='ClearRecycleBin Off'
        )]
        [switch] $DisableClearRecycleBin
    )

    begin {
        $RegPath = @{
            StorageSense = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\01'
            TemporaryApp = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\04'
            RecycleBin   = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\08'
            SpaceHistory = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\SpaceHistory'
        }
        $SetRegistrySplat = @{
            Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\'
            Name  = $null
        }
        function Set-RegistryValue {
            param(
                [string] $Path,
                [string] $Name,
                [string] $Value
            )
            if (-not (Test-Path -Path $Path)) {
                if ($PSCmdlet.ShouldProcess($Path,'Creating registry key')) {
                    $null = New-Item -Path $Path -Force
                }
            }
        
            if ($PSCmdlet.ShouldProcess($Path,'Updating registry value')) {
                $null = Set-ItemProperty @PSBoundParameters -Force
            }
        }
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'StorageSense On'     {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.bluelightreductionstate'
                $SetRegistrySplat.Value = $BlueLightOption.Off
                Set-RegistryValue
            }
            'StorageSense Off'      {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.bluelightreductionstate'
                $SetRegistrySplat.Value = $BlueLightOption.On
                Set-RegistryValue
            }
            'RemoveAppFiles On'     {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.settings'
                $SetRegistrySplat.Value = $BlueLightOption.AutoOff
                Set-RegistryValue
            }
            'RemoveAppFiles Off'      {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.settings'
                $SetRegistrySplat.Value = $BlueLightOption.AutoOn
                Set-RegistryValue
            }
            'ClearRecycleBin On'     {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.settings'
                $SetRegistrySplat.Value = $BlueLightOption.AutoOff
                Set-RegistryValue
            }
            'ClearRecycleBin Off'      {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.settings'
                $SetRegistrySplat.Value = $BlueLightOption.AutoOn
                Set-RegistryValue
            }
        }
    }
}