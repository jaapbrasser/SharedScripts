function New-GitHubMarkdownIndex {
<#
.SYNOPSIS
Confusion to generate an index to be used in markdown files
#>
    param(
        $Path = 'C:\Temp\Events',
        $GitHubUri = 'https://github.com/jaapbrasser/events/tree/master'
    )
    Get-ChildItem -LiteralPath $Path | % {
        $GHPath = $_.FullName -replace [regex]::Escape($Path) -replace '\\','/' -replace '\s','%20'
        "* [$(Split-Path $_ -Leaf)]($GitHubUri$GHPath)"
        $_ | ls -recurse | ? {$_.PSIsContainer -or $_.Extension -eq '.md'} | select -exp fullname | % {
            $Count = ($_ -split '\\').Count-($Path.Split('\').Count+1)
            $GHPath = $_ -replace [regex]::Escape($Path) -replace '\\','/' -replace '\s','%20'
            "$(" "*$Count*2)* [$(Split-Path $_ -Leaf)]($GitHubUri$GHPath)"
        }
    } | clip.exe
}
