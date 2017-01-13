function Set-BlueLight {
<#
.SYNOPSIS
Configures the Blue light options on Windows 10

.DESCRIPTION 
This function can configure the Blue light options on a Windows 10 system.

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
Name:        Set-BlueLight
Author:      Jaap Brasser
DateCreated: 2017-01-13
DateUpdated: 2017-01-13
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
            ParameterSetName='BlueShift Off'
        )]
        [switch] $DisableBlueLight,
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='BlueShift On'
        )]
        [switch] $EnableBlueLight,
                [Parameter(
            Mandatory=$true, 
            ParameterSetName='Automatic Off'
        )]
        [switch] $DisableAutomaticSchedule,
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='Automatic On'
        )]
        [switch] $EnableAutomaticSchedule,
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='BlueShift On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='BlueShift Off'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='Automatic On'
        )]
        [Parameter(
            Mandatory=$false, 
            ParameterSetName='Automatic Off'
        )]
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='Color Temperature'
        )]
        [ValidateSet('NoShift', 'MinimumShift', 'MediumShift', 'LargeShift', 'MaximumShift')]
        [string] $ColorTemperature
    )

    begin {
        $BlueLightOption = @{
            Off          = [byte[]](2,0,0,0,147,250,216,91,185,109,210,1,0,0,0,0,67,66,1,0,208,10,2,198,20,202,236,227,222,149,183,155,233,1,0)
            On           = [byte[]](2,0,0,0,128,208,150,171,186,109,210,1,0,0,0,0,67,66,1,0,16,0,208,10,2,198,20,221,137,219,220,170,183,155,233,1,0)
            AutoOn       = [byte[]](2,0,0,0,89,63,239,213,232,109,210,1,0,0,0,0,67,66,1,0,2,1,202,20,14,21,0,202,30,14,7,0,207,40,188,62,202,50,14,16,46,54,0,202,60,14,8,46,46,0,0)
            AutoOff      = [byte[]](2,0,0,0,175,164,252,55,235,109,210,1,0,0,0,0,67,66,1,0,202,20,14,21,0,202,30,14,7,0,207,40,188,62,202,50,14,16,46,54,0,202,60,14,8,46,46,0,0)
            NoShift      = [byte[]](2,0,0,0,255,124,43,3,82,107,210,1,0,0,0,0,67,66,1,0,2,1,202,20,14,21,0,202,30,14,7,0,207,40,168,70,202,50,14,16,46,49,0,202,60,14,8,46,47,0,0)
            MinimumShift = [byte[]](2,0,0,0,224,193,179,114,82,107,210,1,0,0,0,0,67,66,1,0,2,1,202,20,14,21,0,202,30,14,7,0,207,40,236,57,202,50,14,16,46,49,0,202,60,14,8,46,47,0,0)
            MediumShift  = [byte[]](2,0,0,0,49,229,185,33,82,107,210,1,0,0,0,0,67,66,1,0,2,1,202,20,14,21,0,202,30,14,7,0,207,40,200,42,202,50,14,16,46,49,0,202,60,14,8,46,47,0,0)
            LargeShift   = [byte[]](2,0,0,0,22,255,5,128,82,107,210,1,0,0,0,0,67,66,1,0,2,1,202,20,14,21,0,202,30,14,7,0,207,40,138,27,202,50,14,16,46,49,0,202,60,14,8,46,47,0,0)
            MaximumShift = [byte[]](2,0,0,0,199,91,231,198,81,107,210,1,0,0,0,0,67,66,1,0,2,1,202,20,14,21,0,202,30,14,7,0,207,40,208,15,202,50,14,16,46,49,0,202,60,14,8,46,47,0,0)
        }
        $SetRegistrySplat = @{
            Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\{0}\Current'
            Force = $true
            Name  = 'Data'
        }
        function Set-RegistryValue {
            if (-not (Test-Path -Path $SetRegistrySplat.Path)) {
                if ($PSCmdlet.ShouldProcess($SetRegistrySplat.Path,'Creating registry key')) {
                    $null = New-Item -Path $SetRegistrySplat.Path -Force
                }
            }
        
            if ($PSCmdlet.ShouldProcess($SetRegistrySplat.Path,'Updating registry value')) {
                $null = Set-ItemProperty @SetRegistrySplat
            }
        }
    }

    process {
        switch ($PsCmdlet.ParameterSetName) {
            'BlueShift Off'     {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.bluelightreductionstate'
                $SetRegistrySplat.Value = $BlueLightOption.Off
                Set-RegistryValue
            }
            'BlueShift On'      {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.bluelightreductionstate'
                $SetRegistrySplat.Value = $BlueLightOption.On
                Set-RegistryValue
            }
            'Automatic Off'     {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.settings'
                $SetRegistrySplat.Value = $BlueLightOption.AutoOff
                Set-RegistryValue
            }
            'Automatic On'      {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.settings'
                $SetRegistrySplat.Value = $BlueLightOption.AutoOn
                Set-RegistryValue
            }
            {$ColorTemperature} {
                $SetRegistrySplat.Path  = $SetRegistrySplat.Path -f '$$windows.data.bluelightreduction.settings'
                $SetRegistrySplat.Value = $BlueLightOption.$ColorTemperature
                Set-RegistryValue
            }
        }
    }
}