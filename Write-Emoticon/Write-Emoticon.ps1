function Write-Emoticon {
    param(
        $NumberOfEmoticons
    )    
}
while(1){Write-Host "$(129408..129431|get-Random|%{[char]::convertfromutf32($_)}) " -NoNewLine -ForegroundColor (1..15|Get-Random);start-sleep -Milliseconds 50}
