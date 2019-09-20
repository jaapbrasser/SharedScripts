function Write-Emoticon {
<#
.SYNOPSIS
Function that writes a series of random unicode animals to the console

.NOTES   
Name:        Write-Emoticon
Author:      Jaap Brasser
DateCreated: 2019-09-20
DateUpdated: 2019-09-20
Version:     1.0.0
Blog:        https://www.jaapbrasser.com
GitHub:      https://www.github.com/jaapbrasser

.EXAMPLE
Write-Emoticon

Description
-----------

Will indefinitely output a string of emoticons

.EXAMPLE
Write-Emoticon -Count 10

Description
-----------

Will output a series of 10 emoticons
#>

    param(
        # Number of emoticons showed, if not specified the function will continue indefinitely
        [int] $Count,
        # Delay in milliseconds, set to 50ms as a default value 
        [int] $Delay = 50
    )
    
    if ($Count) {
        1..$Count | ForEach-Object {
            Write-Host "$(129408..129431 | Get-Random | ForEach-Object {
                [char]::convertfromutf32($_)}) " -NoNewLine -ForegroundColor (1..15|Get-Random)
                Start-Sleep -Milliseconds 50
        }
    } else {
        # Keep on going forever
        while(1) {
            Write-Host "$(129408..129431 | Get-Random | ForEach-Object {
                [char]::convertfromutf32($_)}) " -NoNewLine -ForegroundColor (1..15|Get-Random)
                Start-Sleep -Milliseconds 50
        
        }
    }
}