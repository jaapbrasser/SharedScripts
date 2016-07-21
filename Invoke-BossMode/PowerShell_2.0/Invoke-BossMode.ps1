function Invoke-BossMode {
<#   
.SYNOPSIS   
Function to show or hide a window using the ShowWindow method

.DESCRIPTION 
This script provides the ability to temporarily show or hide a number of windows. The windows can be set to reappear on pressing enter, a time out or a hidden string that should be entered in the correct order. The use case for this script is to temporarily remove a number of applications from view, allowing to work without distractions.

.PARAMETER ProcessName
This can be a single process name or an array of process names which will be hidden by the function

.PARAMETER TimeOut
Optional parameter, changing the default behaviour of waiting for the enter key and instead having a timer to hide the windows for a certain time
    
.PARAMETER HiddenPassword
Optional parameter, changing the default behaviour of waiting for the enter key and instead setting a hidden string as a password. If 'jaap' as a string is given then the script only shows the windows if the characters are typed in the correct order j a a p, typing jaaap would not unlock the computer but typing jaaapjaap would as the hidden password resets to the first character when an incorrect character is typed.

.PARAMETER NoClear
This parameter can be set to prevent the PowerShell console from being cleared, the default behavior of the script is to clear the PowerShell console

.NOTES   
Name: Invoke-BossMode
Author: Jaap Brasser
DateUpdated: 2015-05-29
Version: 1.1
Blog: http://www.jaapbrasser.com

.LINK
http://www.jaapbrasser.com

.EXAMPLE
. .\Invoke-BossMode.ps1

Description
-----------
This command dot sources the script to ensure the Invoke-BossMode function is available in your current PowerShell session

.EXAMPLE
Get-Process calc,notepad | Invoke-BossMode

Description
-----------
Use Get-Process to retrieve a list of applications and pipe it into the Invoke-BossMode function to hide the windows until enter is pressed

.EXAMPLE
Invoke-BossMode -TimeOut 5 -ProcessName powershell_ise

Description
-----------
Will hide the powershell_ise while clearing the console and the window will be visible again after five seconds

.EXAMPLE
Invoke-BossMode -TimeOut 5 -ProcessName calc,notepad -NoClear

Description
-----------
Will hide the calc and notepad windows while not clearing the console and the windows will be visible again after five seconds

.EXAMPLE
'wordpad','notepad','calc' | Invoke-BossMode -NoClear -TimeOut 10

Description
-----------
Hide wordpad, notepad and calc for 10 seconds without clearing the console

.EXAMPLE
PowerShell.exe -Command "& {. C:\Scripts\Invoke-BossMode.ps1; Invoke-BossMode -TimeOut 5 -ProcessName powershell_ise}"

Description
-----------
Will hide the powershell_ise while clearing the console and the window will be visible again after five seconds. This example can be used when scheduling tasks or for batch files.

.EXAMPLE
'notepad' | Invoke-BossMode -HiddenPassword Jaap

Description
-----------
Pipe the string notepad into Invoke-BossMode and clear the console. The windows will only reappear if the secret password is typed in the correct order in the PowerShell console

.EXAMPLE
function ivb {Invoke-BossMode -ProcessName notepad -TimeOut 2}

Description
-----------
Create a function to run the Invoke-BossMode with a number of pre-defined parameters to quickly be able to Invoke-BossMode without have to type the full command
#>
    [cmdletbinding(SupportsShouldProcess)]
    param (
    [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
    [string[]]
        $ProcessName,
    [int]
        $TimeOut,
    [string]
        $HiddenPassword,
    [switch]
        $NoClear
    )

    begin {
        if (-not $NoClear) {
            Clear-Host
        }
        $TypeSplat = @{
            Name = 'Win'
            NameSpace = 'Native'
            Member = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
        }
        Add-Type @TypeSplat
        [array]$Handles = $null
    }

    process {
        foreach ($Process in $ProcessName) {
            $Temp += $Process
            $Handles += Get-Process $Process -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty MainWindowHandle |
                Select-Object -Unique |
                Where-Object {$_ -ne 0}

        }
        $Handles | ForEach-Object {
            $null = [Native.Win]::ShowWindow($_, 0)
        }
    }

    end {
        if ($TimeOut) {
            Start-Sleep -Seconds $TimeOut
        } elseif ($HiddenPassword) {
            for ($i = 0; $i -lt $HiddenPassword.Length; $i++) { 
                $KeyPress = [System.Console]::ReadKey($true)
                if ($KeyPress.KeyChar -ne $HiddenPassword[$i]) {
                    $i = 0
                }
            }                  
        } else {
            Read-Host 'Press Enter to continue. . .'
        }
        $Handles | ForEach-Object {
            $null = [Native.Win]::ShowWindow($_, 1)
        }
    }
}