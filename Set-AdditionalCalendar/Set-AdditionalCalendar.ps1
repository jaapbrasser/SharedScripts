function Set-AdditionalCalendar {
<#
.SYNOPSIS
Configures the additional calendar options

.DESCRIPTION 
This function can configure the calendar options between the three options that are available in Windows 10. Either off, which displays the regular calendar, simplified Chinese lunar calendar or traditional Chinese lunar calendar. The function has three switch options that are mutually exclusive exclusive parameter sets and supports verbose and whatif parameters.

.PARAMETER Off
Does not show any additional calendars

.PARAMETER SimplifiedLunar
Show simplified Chinese lunar calendar

.PARAMETER TraditionalLunar
Show traditional Chinese lunar calendar

.NOTES   
Name:        Set-AdditionalCalendar
Author:      Jaap Brasser
DateCreated: 2017-01-11
DateUpdated: 2017-01-11
Version:     1.0.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
Set-AdditionalCalendar -Off

Description
-----------
Configures the Calendar to the default option, off not displaying any additional calenders

.EXAMPLE   
Set-AdditionalCalendar -SimplifiedLunar

Description
-----------
Configures the Calendar to the show the lunar calendar with simplified Chinese characters

.EXAMPLE   
Set-AdditionalCalendar -TraditionalLunar

Description
-----------
Configures the Calendar to the show the lunar calendar with traditional Chinese characters
#>    
    [cmdletbinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='Additional Calendar Off'
        )]
        [switch] $Off,
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='Simplified Lunar Calendar'
        )]
        [switch] $SimplifiedLunar,
        [Parameter(
            Mandatory=$true, 
            ParameterSetName='Traditional Lunar Calendar'
        )]
        [switch] $TraditionalLunar
    )

    begin {
        $CalendarOption = @{
            Off              = [byte[]](2,0,0,0,88,33,207,247,241,107,210,1,0,0,0,0,67,66,1,0,16,2,0)
            SimplifiedLunar  = [byte[]](2,0,0,0,148,217,114,130,241,107,210,1,0,0,0,0,67,66,1,0,16,4,0)
            TraditionalLunar = [byte[]](2,0,0,0,75,55,152,236,241,107,210,1,0,0,0,0,67,66,1,0,16,6,0)
        }
        $SetRegistrySplat = @{
            Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\$$windows.data.lunarcalendar\Current'
            Force = $true
            Name  = 'Data'
        }
    }

    process {
        if (-not (Test-Path -Path $SetRegistrySplat.Path)) {
            if ($PSCmdlet.ShouldProcess($SetRegistrySplat.Path,'Creating registry key')) {
                $null = New-Item -Path $SetRegistrySplat.Path -Force
            }
        }
        switch ($PsCmdlet.ParameterSetName) {
            'Additional Calendar Off'    {
                $SetRegistrySplat.Value = $CalendarOption.Off
            }
            'Simplified Lunar Calendar'  {
                $SetRegistrySplat.Value = $CalendarOption.SimplifiedLunar
            }
            'Traditional Lunar Calendar' {
                $SetRegistrySplat.Value = $CalendarOption.TraditionalLunar
            }
            default {}
        }

        if ($PSCmdlet.ShouldProcess($SetRegistrySplat.Path,'Updating registry value')) {
            $null = Set-ItemProperty @SetRegistrySplat
        }
    }
}