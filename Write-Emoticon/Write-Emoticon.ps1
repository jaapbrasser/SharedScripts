function Write-Emoticon {
    param(
        # Number of emoticons showed
        [int] $Times,
        # Delay in milliseconds, set to 50ms as a default value 
        [int] $Delay = 50
    )
    
    if ($Times) {
        1..$Times | ForEach-Object {
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