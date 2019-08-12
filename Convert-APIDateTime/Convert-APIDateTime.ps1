function Convert-APIDateTime {
<#
.SYNOPSIS
Function to convert specific date time format from API endpoint to a datetime object

.EXAMPLE
Convert-APIDateTime "Thu Aug 08 20:31:36 UTC 2019" 

Thursday, August 8, 2019 8:31:36 PM
#>
    [cmdletbinding()]
    param(
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $DateTimeString
    )

    begin {
        [System.Globalization.DateTimeFormatInfo]::InvariantInfo.get_abbreviatedmonthnames() | ForEach-Object -Begin {
            $MonthHash = @{}
            $Count = 0
        } -Process {
            $Count++
            if ($_) {
                $MonthHash.$_ = $Count.ToString().Padleft(2,'0')
            }
        }
    }

    process {
        $NewDateTimeString = $DateTimeString.Substring(4) -replace 'UTC '
        $MonthHash.GetEnumerator() | ForEach-Object {
            $NewDateTimeString = $NewDateTimeString -replace $_.Key,$_.Value
        }

        try {
            [DateTime]::ParseExact($NewDateTimeString,'MM dd HH:mm:ss yyyy',$null)
        } catch {
            Write-Error $_
        }
    }
}