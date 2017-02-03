function Start-ShowSleep {
<#
.SYNOPSIS
Suspends a script will displaying visual countdown

.DESCRIPTION
This script is manipulating the console to show a countdown timer for interactive scripts to give the user an idea of how long the wait is. I would not recommend writing interactive scripts but for the fringe case where you are actually looking at your script execution this might be helpful.

.PARAMETER Seconds
The number of seconds this command will suspend activity for

.NOTES
Name:        Start-ShowSleep
Author:      Jaap Brasser
DateCreated: 2017-02-03
DateUpdated: 2017-02-03
Version:     1.0.0
Blog:        http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE   
Start-ShowSleep -Seconds 3 

Description
-----------
Sleeps for 3 seconds while displaying visual countdown for the user
#>
    param(
        [int] $Seconds
    )
    1..$Seconds | ForEach-Object -Begin {
        $CursorPos = $host.ui.rawui.cursorposition
    } -Process {
        $host.ui.rawui.cursorposition = $CursorPos
        Write-Host (' '*30) -NoNewline
        $WriteSplat = @{
            Object    = '{0} second{1} remaining...' -f ($Seconds-$_+1),$(if ($Seconds-$_+1 -gt 1){'s'})
            NoNewLine = $true
        }
        $host.ui.rawui.cursorposition = $CursorPos
        Write-Host @WriteSplat
        Start-Sleep -Seconds 1
    } -End {
        ''
    }
}