function Invoke-RunAsPowerShell7 {
<#
.Synopsis
Run a command in PowerShell 7

.DESCRIPTION
Downloads PowerShell 7 from GitHub, expands the archive and runs the specified command in PowerShell 7

.NOTES   
Name: Invoke-RunAsPowerShell7
Author: Jaap Brasser
Version: 1.0
DateUpdated: 2020-05-24

.LINK
https://www.jaapbrasser.com

.EXAMPLE
Invoke-RunAsPowerShell7 -Command '$PSVersionTable'

Description:
Downloads PowerShell 7 from GitHub, expands the archive and runs the specified command in PowerShell 7
#>
    param(
        # The command that will be run in PowerShell 7
        [string] $Command
    )

    [Net.ServicePointManager]::SecurityProtocol = ([Net.ServicePointManager]::SecurityProtocol).tostring() + ', Tls12'
    Invoke-WebRequest https://github.com/PowerShell/PowerShell/releases/download/v7.0.1/PowerShell-7.0.1-win-x64.zip -OutFile $env:temp\pwsh.zip
    $GUID = (New-Guid).Guid
    Expand-Archive $env:temp\pwsh.zip -DestinationPath $env:temp\$guid
    & "$env:temp\$guid\pwsh.exe" -c $Command
}