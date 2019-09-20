function Write-Emoticon {
    param(
        [int] $Times
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