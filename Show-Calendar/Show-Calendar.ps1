Function Show-Calendar {
<#
.Synopsis
Displays the calendar in a short text based way

.DESCRIPTION
Displays either the current month or another month which can be specified by usiong the -Year and -Month parameters

.NOTES   
Name       : Get-RemoteProgram
Author     : Jaap Brasser
Version    : 1.1
DateCreated: 2019-08-05
Blog       : http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
Show-Calendar

Description:
Shows the of the current month

.EXAMPLE
Show-Calendar -Month 9 -Year 1983

Description:
Shows the calendar for September 1983
#>
    Param(
        # The month number of which the calendar should be displayed, can be used in combination with the -Year parameter
        [validaterange(1,12)]
        [int] $Month,
        # The year of which the calendar should be displayed, can be used in combination with the -Month parameter
        [validaterange(1,9999)]
        [int] $Year
    )
    $SplatDate = @{}
    switch ($true)
    {
        {$Month} {$SplatDate.Month = $Month}
        {$Year} {$SplatDate.Year = $Year}
    }
    # Get the date for the month or year required
    $CurrentDate = Get-Date @SplatDate
    # Display 'Header' row containing the padded name of the month and the days of the week
    if ($CurrentDate.Year -eq (Get-Date).Year) {
        $DisplayMonth = $CurrentDate.ToString('MMMM')
    } else {
        $DisplayMonth = "$($CurrentDate.ToString('MMMM')) $($CurrentDate.Year)"
    }
    
    "$($DisplayMonth.PadLeft(20-(20-$DisplayMonth.Length)/2-.5).PadRight(20))"
    ([Enum]::GetNames([System.DayOfWeek]) | ForEach-Object {
        $_.Substring(0,2)
    }) -join ' '
    # Display the day numbers
    $PositionFirstDay = [int](Get-Date -Day 1 -Month $CurrentDate.Month -Year $CurrentDate.Year).DayOfWeek
    $LastDay = (Get-Date -Day 1 -Month ($CurrentDate.Month+1) -Year $CurrentDate.Year).AddDays(-1).Day
    [string]$DisplayLine = '   '*$PositionFirstDay
    for ($DayCount = 1; $DayCount -le $LastDay; $DayCount++) {
        $DisplayLine += "$(([string]$DayCount).PadLeft(2)) "
        if (-not (($DayCount + $PositionFirstDay) % 7)) {
            $DisplayLine
            $DisplayLine = ''
        }
    }
    $DisplayLine
}