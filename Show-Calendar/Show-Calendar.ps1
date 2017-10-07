Function Show-Calender {
    Param(
        $Week,
        $Month,
        $Year
    )
    $SplatDate = @{}
    switch ($true)
    {
        {$Week} {$SplatDate.Week = $Week}
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

Show-Calender   